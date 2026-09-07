"use strict";

const BUILD_VERSION = "__QURAN_OFFLINE_VERSION__";
const PREFIX = "quran-haven-shell-v1-";
const CONTROL_CACHE = "quran-haven-shell-control-v1";
const META_PATH = "/_quran_shell_metadata";
const STATE_PATH = "/_quran_shell_state";
const MANIFEST_PATH = "/offline-manifest.json";
const INDEX_SOURCE_PATH = "/offline-index.bin";
const MAX_TOTAL = 160 * 1024 * 1024;
const MAX_STORED = 320 * 1024 * 1024;
const MAX_FILE = 64 * 1024 * 1024;
const MAX_MANIFEST = 2 * 1024 * 1024;
let operation = null;
let storagePersistence = null;
const metadataMemory = new Map();

function failure(code) { const error = new Error(code); error.code = code; return error; }
function originURL(path) { return self.location.origin + path; }
function versionOK(value) { return typeof value === "string" && /^[a-f0-9]{64}$/.test(value); }
function cacheName(version) { if (!versionOK(version)) throw failure("invalid_manifest"); return PREFIX + version; }

function staticPath(path) {
  if (typeof path !== "string" || !path.startsWith("/") || path.includes("\\") || path.includes("?") || path.includes("#")) return false;
  let decoded;
  try { decoded = decodeURIComponent(path); } catch (_) { return false; }
  if (decoded.split("/").slice(1).some(part => !part || part.startsWith("."))) return false;
  if (/\.(map|symbols|pem|key|p12|jks)$/i.test(decoded)) return false;
  return /^\/(assets|icons)\//.test(path) || new Set([
    "/index.html", "/flutter_bootstrap.js", "/main.dart.js", "/flutter.js",
    "/manifest.json", "/favicon.png", "/version.json",
    "/canvaskit/canvaskit.js", "/canvaskit/canvaskit.wasm",
    "/canvaskit/chromium/canvaskit.js", "/canvaskit/chromium/canvaskit.wasm",
  ]).has(path);
}

function validateManifest(value) {
  if (!value || value.schemaVersion !== 1 || !versionOK(value.version) || !Array.isArray(value.files) || !value.files.length || value.files.length > 10000) throw failure("invalid_manifest");
  let bytes = 0;
  const seen = new Set();
  for (const entry of value.files) {
    if (!entry || !staticPath(entry.path) || seen.has(entry.path) || !Number.isSafeInteger(entry.bytes) || entry.bytes <= 0 || entry.bytes > MAX_FILE || !versionOK(entry.sha256)) throw failure("invalid_manifest");
    const url = new URL(entry.path, self.location.origin);
    if (url.origin !== self.location.origin || url.pathname !== entry.path) throw failure("invalid_manifest");
    bytes += entry.bytes;
    seen.add(entry.path);
  }
  if (bytes !== value.totalBytes || bytes > MAX_TOTAL || !["/index.html", "/flutter_bootstrap.js", "/main.dart.js", "/assets/AssetManifest.bin"].every(path => seen.has(path))) throw failure("invalid_manifest");
  return value;
}

async function storedMeta(name) {
  if (!(await caches.keys()).includes(name)) { metadataMemory.delete(name); return null; }
  if (metadataMemory.has(name)) return metadataMemory.get(name);
  const response = await (await caches.open(name)).match(originURL(META_PATH));
  if (!response) return null;
  try {
    const meta = await response.json();
    validateManifest(meta.manifest);
    if (meta.complete !== true || name !== cacheName(meta.manifest.version)) return null;
    metadataMemory.set(name, meta);
    return meta;
  } catch (_) { return null; }
}

async function activeVersion() {
  if (!(await caches.keys()).includes(CONTROL_CACHE)) return null;
  const response = await (await caches.open(CONTROL_CACHE)).match(originURL(STATE_PATH));
  if (!response) return null;
  try {
    const state = await response.json();
    return versionOK(state.version) && await storedMeta(cacheName(state.version)) ? state.version : null;
  } catch (_) { return null; }
}

async function setActive(version) {
  if (!await storedMeta(cacheName(version))) throw failure("not_prepared");
  const cache = await caches.open(CONTROL_CACHE);
  await cache.put(originURL(STATE_PATH), new Response(JSON.stringify({version}), {headers: {"Content-Type": "application/json"}}));
}

async function status(extra = {}) {
  const active = await activeVersion();
  const prepared = versionOK(BUILD_VERSION) ? await storedMeta(cacheName(BUILD_VERSION)) : null;
  let missing = false;
  if (!operation) {
    for (const version of new Set([active, prepared?.manifest.version].filter(Boolean))) {
      const name = cacheName(version);
      const meta = await storedMeta(name);
      const savedKeys = new Set((await (await caches.open(name)).keys()).map(request => new URL(request.url).pathname));
      if (!meta || meta.manifest.files.some(entry => !savedKeys.has(entry.path))) missing = true;
    }
  }
  return {
    supported: true,
    state: operation ? "preparing" : prepared ? (active === BUILD_VERSION ? "ready" : "updateReady") : "unprepared",
    version: BUILD_VERSION, activeVersion: active,
    offlineReady: active !== null,
    totalBytes: prepared?.manifest.totalBytes || 0,
    completedBytes: prepared?.manifest.totalBytes || 0,
    completedFiles: prepared?.manifest.files.length || 0,
    totalFiles: prepared?.manifest.files.length || 0,
    persisted: storagePersistence,
    ...(missing ? {state: "error", errorCode: "cache_missing", offlineReady: false} : {}),
    ...extra,
  };
}

async function publish(value) {
  for (const client of await self.clients.matchAll({type: "window"})) {
    client.postMessage({type: "quran-offline-status", status: value});
  }
  return value;
}

async function readLimited(response, limit, signal) {
  if (!response.ok || response.type === "opaque" || response.redirected) throw failure("download_failed");
  if (!response.body) throw failure("download_failed");
  const reader = response.body.getReader();
  const chunks = [];
  let size = 0;
  try {
    while (true) {
      if (signal?.aborted) throw failure("cancelled");
      const result = await reader.read();
      if (result.done) break;
      size += result.value.byteLength;
      if (size > limit) throw failure("integrity_failed");
      chunks.push(result.value);
    }
  } catch (error) {
    await reader.cancel().catch(() => {});
    throw error;
  } finally { reader.releaseLock(); }
  const bytes = new Uint8Array(size);
  let offset = 0;
  for (const chunk of chunks) { bytes.set(chunk, offset); offset += chunk.byteLength; }
  return bytes;
}

async function download(path, limit, signal) {
  if (path !== MANIFEST_PATH && path !== INDEX_SOURCE_PATH && !staticPath(path)) throw failure("invalid_manifest");
  const controller = new AbortController();
  const cancel = () => controller.abort();
  if (signal?.aborted) cancel();
  signal?.addEventListener("abort", cancel, {once: true});
  const timer = setTimeout(cancel, 60000);
  try {
    const response = await fetch(originURL(path), {credentials: "omit", cache: "no-store", redirect: "error", signal: controller.signal});
    return {bytes: await readLimited(response, limit, controller.signal), contentType: response.headers.get("Content-Type") || "application/octet-stream"};
  } catch (error) {
    if (controller.signal.aborted && !signal?.aborted) throw failure("download_failed");
    throw error;
  } finally {
    clearTimeout(timer);
    signal?.removeEventListener("abort", cancel);
  }
}

async function digest(bytes) {
  return Array.from(new Uint8Array(await crypto.subtle.digest("SHA-256", bytes)), byte => byte.toString(16).padStart(2, "0")).join("");
}

async function prepare(requestingClientId, pageVersion) {
  if (operation) return status();
  const controller = new AbortController();
  const current = {controller, removed: false, done: null};
  operation = current;
  let name;
  let committed = false;
  let repairing = false;
  const run = (async () => {
    try {
      if (!versionOK(BUILD_VERSION)) throw failure("invalid_manifest");
      name = cacheName(BUILD_VERSION);
      const existingMeta = await storedMeta(name);
      if (existingMeta) {
        repairing = true;
        const existingCache = await caches.open(name);
        let intact = true;
        for (const entry of existingMeta.manifest.files) {
          if (controller.signal.aborted) throw failure("cancelled");
          const saved = await existingCache.match(originURL(entry.path));
          if (!saved) { intact = false; break; }
          try {
            const bytes = await readLimited(saved, entry.bytes, controller.signal);
            if (bytes.byteLength !== entry.bytes || await digest(bytes) !== entry.sha256) { intact = false; break; }
          } catch (_) { intact = false; break; }
        }
        if (intact) { committed = true; return; }
        // Repair this exact release in place: every replacement is individually
        // hash-verified before put(), so valid remaining files survive failure.
      }
      const downloaded = await download(MANIFEST_PATH, MAX_MANIFEST, controller.signal);
      let manifest;
      try { manifest = validateManifest(JSON.parse(new TextDecoder().decode(downloaded.bytes))); }
      catch (_) { throw failure("invalid_manifest"); }
      if (manifest.version !== BUILD_VERSION) throw failure("update_required");
      let existingBytes = 0;
      for (const existing of await caches.keys()) {
        if (existing.startsWith(PREFIX) && existing !== name) existingBytes += (await storedMeta(existing))?.manifest.totalBytes || 0;
      }
      if (existingBytes + manifest.totalBytes > MAX_STORED) throw failure("storage_full");
      if (self.navigator.storage?.estimate) {
        const estimate = await self.navigator.storage.estimate();
        if (Number.isFinite(estimate.quota) && Number.isFinite(estimate.usage) && estimate.quota - estimate.usage < manifest.totalBytes * 1.1) throw failure("storage_full");
      }
      // An incomplete prior attempt is never active and can be replaced safely.
      if (!repairing) await caches.delete(name);
      const cache = await caches.open(name);
      let completed = 0;
      let bytesDone = 0;
      for (const entry of manifest.files) {
        if (controller.signal.aborted) throw failure("cancelled");
        // Keep index.html's original manifest hash. Only its fixed transport
        // alias avoids HTML-aware CDN rewriting; no arbitrary source URL is
        // accepted from the manifest and the alias is never an offline key.
        const sourcePath = entry.path === "/index.html" ? INDEX_SOURCE_PATH : entry.path;
        const file = await download(sourcePath, entry.bytes, controller.signal);
        if (file.bytes.byteLength !== entry.bytes || await digest(file.bytes) !== entry.sha256) throw failure("integrity_failed");
        const contentType = entry.path === "/index.html" ? "text/html; charset=utf-8" : file.contentType;
        await cache.put(originURL(entry.path), new Response(file.bytes, {headers: {"Content-Type": contentType}}));
        completed++;
        bytesDone += entry.bytes;
        await publish(await status({completedFiles: completed, totalFiles: manifest.files.length, completedBytes: bytesDone, totalBytes: manifest.totalBytes}));
      }
      if (controller.signal.aborted) throw failure("cancelled");
      await cache.put(originURL(META_PATH), new Response(JSON.stringify({complete: true, manifest}), {headers: {"Content-Type": "application/json"}}));
      metadataMemory.delete(name);
      committed = true;
      if (!await activeVersion() && pageVersion === BUILD_VERSION) {
        const readers = await self.clients.matchAll({type: "window", includeUncontrolled: true});
        // A new worker may have claimed older, pre-PWA tabs. Do not switch
        // their asset source after a first download; require explicit activation.
        if (!readers.some(client => client.id !== requestingClientId && new URL(client.url).origin === self.location.origin)) {
          await setActive(BUILD_VERSION);
        }
      }
    } catch (error) {
      if (name && !committed && !repairing) { await caches.delete(name); metadataMemory.delete(name); }
      const code = controller.signal.aborted ? "cancelled" : error.name === "QuotaExceededError" ? "storage_full" : error.code || "download_failed";
      current.error = code;
    } finally { operation = null; }
  })();
  current.done = run;
  await run;
  return publish(await status(current.error ? {state: current.error === "cancelled" ? "cancelled" : "error", errorCode: current.error} : {}));
}

async function cancel() {
  const current = operation;
  if (current) { current.controller.abort(); await current.done; }
  return publish(await status({state: "cancelled", errorCode: "cancelled"}));
}

async function remove() {
  await cancel();
  for (const name of await caches.keys()) {
    if (name === CONTROL_CACHE || name.startsWith(PREFIX)) { await caches.delete(name); metadataMemory.delete(name); }
  }
  return publish(await status());
}

async function activate(requestingClientId) {
  const readers = await self.clients.matchAll({type: "window", includeUncontrolled: true});
  if (readers.some(client => client.id !== requestingClientId && new URL(client.url).origin === self.location.origin)) {
    throw failure("other_tabs_open");
  }
  await setActive(BUILD_VERSION);
  await self.skipWaiting();
  // Activation is explicit and no other app tab is using a previous release.
  // The new version is already complete; retire only older complete shell
  // releases now, allowing future updates without growing storage indefinitely.
  for (const name of await caches.keys()) {
    if (name.startsWith(PREFIX) && name !== cacheName(BUILD_VERSION) && await storedMeta(name)) {
      await caches.delete(name);
      metadataMemory.delete(name);
    }
  }
  return publish(await status());
}

self.addEventListener("install", () => {
  // No app bundle is downloaded on installation. Updates wait for user action
  // while an older tab is open; the previous complete cache remains intact.
});
self.addEventListener("activate", event => event.waitUntil(self.clients.claim()));
self.addEventListener("message", event => {
  if (event.data?.type !== "quran-offline-command" || !event.ports?.[0]) return;
  const work = (async () => {
    const source = event.source;
    if (!source?.id) return;
    const client = await self.clients.get(source.id);
    if (!client || new URL(client.url).origin !== self.location.origin) return;
    const action = event.data.action;
    if (["prepare", "status"].includes(action) && typeof event.data.persisted === "boolean") storagePersistence = event.data.persisted;
    const actions = {status, prepare, cancel, remove, activate};
    const handler = Object.prototype.hasOwnProperty.call(actions, action) ? actions[action] : null;
    if (!handler) return;
    try {
      const result = action === "activate" ? await handler(source.id)
        : action === "prepare" ? await handler(source.id, event.data.pageVersion)
        : await handler();
      event.ports[0].postMessage(result);
    }
    catch (error) {
      const code = ["other_tabs_open", "not_prepared", "invalid_manifest"].includes(error.code) ? error.code : "storage_unavailable";
      let result = {state: "error", supported: true, offlineReady: false, version: BUILD_VERSION, errorCode: code};
      try { result = await status({state: "error", errorCode: code}); } catch (_) { /* Storage itself is unavailable. */ }
      event.ports[0].postMessage(result);
    }
  })();
  event.waitUntil(work);
});

self.addEventListener("fetch", event => {
  const request = event.request;
  if (request.method !== "GET" || request.headers.has("Authorization") || request.headers.has("Cookie")) return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin || url.search || url.hash) return;
  const path = url.pathname === "/" && request.mode === "navigate" ? "/index.html" : url.pathname;
  if (!staticPath(path)) return;
  event.respondWith((async () => {
    try {
      const active = await activeVersion();
      if (active) {
        const name = cacheName(active);
        const meta = await storedMeta(name);
        const entry = meta.manifest.files.find(entry => entry.path === path);
        if (entry) {
          const cached = await (await caches.open(name)).match(originURL(path));
          if (cached) {
            try {
              const bytes = await readLimited(cached.clone(), entry.bytes);
              if (bytes.byteLength === entry.bytes && await digest(bytes) === entry.sha256) return cached;
            } catch (_) { /* Never serve corrupt stored Quran or application bytes. */ }
            await (await caches.open(name)).delete(originURL(path));
          }
          // Browser eviction is a cache miss, never an invented offline success.
          await publish(await status({state: "error", errorCode: "cache_missing", offlineReady: false}));
        }
      }
    } catch (_) { /* Storage denial must not prevent normal online reading. */ }
    return fetch(request);
  })());
});
