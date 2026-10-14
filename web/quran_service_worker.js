"use strict";

const BUILD_VERSION = "__QURAN_OFFLINE_VERSION__";
const PREFIX = "quran-haven-shell-v1-";
const CONTROL_CACHE = "quran-haven-shell-control-v1";
const META_PATH = "/_quran_shell_metadata";
const STATE_PATH = "/_quran_shell_state";
const MANIFEST_PATH = "/offline-manifest.json";
const INDEX_SOURCE_PATH = "/offline-index.bin";
const PRIVACY_SOURCE_PATH = "/offline-privacy.bin";
const MAX_TOTAL = 160 * 1024 * 1024;
const MAX_STORED = 320 * 1024 * 1024;
const MAX_FILE = 64 * 1024 * 1024;
const MAX_MANIFEST = 2 * 1024 * 1024;
const DOWNLOAD_CONCURRENCY = 3;
const MAX_BATCH_BYTES = 12 * 1024 * 1024;
const AUDIO_CACHE = "quran-haven-audio-v1";
const AUDIO_META = "/_quran_audio_metadata/";
const MAX_AUDIO_FILE = 256 * 1024 * 1024;
const MAX_AUDIO_STORED = 1024 * 1024 * 1024;
// Approved catalogue roots only. No caller-supplied host, query, auth or redirect.
const AUDIO_ROOTS = [
  "https://audio-cdn.tarteel.ai/quran/surah/abdulBasit/murattal/mp3/",
  "https://audio-cdn.tarteel.ai/quran/surah/minshawy/murattal/mp3/",
  "https://download.quranicaudio.com/quran/mahmood_khaleel_al-husaree_iza3a/",
  "https://download.quranicaudio.com/quran/ahmed_ibn_3ali_al-3ajamy/",
  "https://download.quranicaudio.com/quran/maher_almu3aiqly/year1440/",
  "https://audio-cdn.tarteel.ai/quran/surah/saudAlShuraim/murattal/mp3/",
  "https://audio-cdn.tarteel.ai/quran/surah/ghamadi/murattal/mp3/",
  "https://download.quranicaudio.com/quran/mustafa_al3azzawi/",
  "https://download.quranicaudio.com/quran/nasser_bin_ali_alqatami/",
  "https://cdn.mp3quran.net/audio/peshawa-kurdi/r1/",
  "https://cdn.mp3quran.net/audio/shirzad-taher/r1/",
  "https://cdn.mp3quran.net/audio/abdulrahman-oosi/r1/",
  "https://cdn.mp3quran.net/audio/wadee-yamani/r1/",
  "https://download.quranicaudio.com/quran/yasser_ad-dussary/",
  "https://download.quranicaudio.com/quran/abdullaah_3awwaad_al-juhaynee/",
  "https://download.quranicaudio.com/quran/fares/",
  "https://download.quranicaudio.com/quran/muhammad_ayyoob_hq/",
  "https://cdn.mp3quran.net/audio/maher-muaiqly/r1/",
  "https://cdn.mp3quran.net/audio/ahmad-nufais/r1/",
  "https://cdn.mp3quran.net/audio/yasser-dosari/r1/",
  "https://download.quranicaudio.com/quran/ali_jaber/",
  "https://cdn.mp3quran.net/audio/mishary-alafasy/r1/",
  "https://cdn.mp3quran.net/audio/abdulrahman-sudais/r1/",
  "https://cdn.mp3quran.net/audio/abubakr-shatri/r1/",
  "https://cdn.mp3quran.net/audio/ali-hudhaifi/r1/",
  "https://cdn.mp3quran.net/audio/abdullah-basfar/r1/",
  "https://cdn.mp3quran.net/audio/hani-rifai/r1/",
  "https://cdn.mp3quran.net/audio/salah-budair/r1/",
  "https://cdn.mp3quran.net/audio/abdulmohsen-qasim/r1/",
];
let audioOperation = null;
let operation = null;
let storagePersistence = null;
const metadataMemory = new Map();

function failure(code) { const error = new Error(code); error.code = code; return error; }
function originURL(path) { return self.location.origin + path; }
function releaseURL(path) {
  const url = new URL(originURL(path));
  // A CDN can retain an older asset at an unchanged Flutter filename. A fixed
  // release key bypasses that stale object without trusting manifest URLs.
  if (versionOK(BUILD_VERSION)) url.searchParams.set("quran_release", BUILD_VERSION);
  return url.href;
}
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
    "/manifest.json", "/favicon.png", "/version.json", "/privacy.html",
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
  if (path !== MANIFEST_PATH && path !== INDEX_SOURCE_PATH && path !== PRIVACY_SOURCE_PATH && !staticPath(path)) throw failure("invalid_manifest");
  const controller = new AbortController();
  const cancel = () => controller.abort();
  if (signal?.aborted) cancel();
  signal?.addEventListener("abort", cancel, {once: true});
  const timer = setTimeout(cancel, 60000);
  try {
    // One bounded retry for a failed network/stream transport. The original
    // 60-second deadline and cancellation apply to both attempts. HTTP errors,
    // redirected/opaque responses, size/hash failures and quota never retry.
    for (let attempt = 0; attempt < 2; attempt++) {
      try {
        const response = await fetch(releaseURL(path), {credentials: "omit", cache: "no-store", redirect: "error", signal: controller.signal});
        return {bytes: await readLimited(response, limit, controller.signal), contentType: response.headers.get("Content-Type") || "application/octet-stream"};
      } catch (error) {
        if (attempt !== 0 || error.name !== "TypeError" || controller.signal.aborted) throw error;
      }
    }
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

function audioURL(value) {
  if (typeof value !== "string" || value.length > 512) throw failure("invalid_audio");
  const url = new URL(value);
  if (url.href !== value || url.search || url.hash || url.username || url.password || url.port) throw failure("invalid_audio");
  const root = AUDIO_ROOTS.find(prefix => value.startsWith(prefix));
  const suffix = root && value.slice(root.length);
  const number = suffix && /^\d{3}\.mp3$/.test(suffix) ? Number(suffix.slice(0, 3)) : 0;
  if (number < 1 || number > 114) throw failure("invalid_audio");
  return value;
}

async function audioMetaURL(url) { return originURL(AUDIO_META + await digest(new TextEncoder().encode(url))); }
async function audioMetadata(url) {
  if (!(await caches.keys()).includes(AUDIO_CACHE)) return null;
  const cache = await caches.open(AUDIO_CACHE);
  const saved = await cache.match(await audioMetaURL(url));
  const recording = await cache.match(url);
  if (!saved || !recording) return null;
  try {
    const meta = await saved.json();
    if (meta.schemaVersion !== 1 || audioURL(meta.url) !== url || !versionOK(meta.sha256)
      || !Number.isSafeInteger(meta.bytes) || meta.bytes < 3 || meta.bytes > MAX_AUDIO_FILE
      || !Number.isInteger(meta.surahNumber) || meta.surahNumber < 1 || meta.surahNumber > 114
      || !url.endsWith('/' + String(meta.surahNumber).padStart(3, '0') + '.mp3')
      || typeof meta.readerName !== "string" || meta.readerName.length > 160
      || typeof meta.surahName !== "string" || meta.surahName.length > 160) return null;
    return meta;
  } catch (_) { return null; }
}
async function listAudio() {
  if (!(await caches.keys()).includes(AUDIO_CACHE)) return [];
  const cache = await caches.open(AUDIO_CACHE);
  const entries = [];
  for (const request of await cache.keys()) {
    let url;
    try { url = audioURL(request.url); } catch (_) { continue; }
    const meta = await audioMetadata(url);
    if (meta) entries.push(meta);
  }
  return entries.sort((a, b) => a.readerName.localeCompare(b.readerName) || a.surahNumber - b.surahNumber);
}
async function audioPublish(value) {
  const result = {supported: true, ...value};
  for (const client of await self.clients.matchAll({type: "window"})) client.postMessage({type: "quran-audio-status", status: result});
  return result;
}
async function verifiedAudio(url) {
  audioURL(url);
  const meta = await audioMetadata(url);
  if (!meta) return null;
  const response = await (await caches.open(AUDIO_CACHE)).match(url);
  const bytes = await readLimited(response, meta.bytes);
  return bytes.byteLength === meta.bytes && await digest(bytes) === meta.sha256 ? meta : null;
}
async function downloadAudio(details) {
  const url = audioURL(details.url);
  if (!Number.isInteger(details.surahNumber) || !url.endsWith('/' + String(details.surahNumber).padStart(3, '0') + '.mp3')
    || typeof details.readerName !== "string" || !details.readerName.trim() || details.readerName.length > 160
    || typeof details.surahName !== "string" || !details.surahName.trim() || details.surahName.length > 160) throw failure("invalid_audio");
  if (audioOperation) throw failure("audio_busy");
  const existing = await verifiedAudio(url);
  if (existing) return audioPublish({state: "ready", entry: existing});
  const controller = new AbortController();
  const current = {controller, url, done: null};
  audioOperation = current;
  const timer = setTimeout(() => controller.abort(), 10 * 60 * 1000);
  const work = (async () => {
    let committed = false;
    let wrote = false;
    let cache;
    try {
      const response = await fetch(url, {mode: "cors", credentials: "omit", cache: "no-store", redirect: "error", signal: controller.signal});
      if (!response.ok || response.type === "opaque" || response.redirected || !response.body) throw failure("audio_download_failed");
      const declared = Number(response.headers.get("Content-Length")) || 0;
      if (declared > MAX_AUDIO_FILE) throw failure("audio_too_large");
      const existingBytes = (await listAudio()).reduce((total, entry) => total + entry.bytes, 0);
      const estimate = self.navigator.storage?.estimate ? await self.navigator.storage.estimate() : null;
      const remaining = estimate && Number.isFinite(estimate.quota) && Number.isFinite(estimate.usage) ? estimate.quota - estimate.usage : Infinity;
      if (declared && (existingBytes + declared > MAX_AUDIO_STORED || remaining < declared * 1.1)) throw failure("storage_full");
      const reader = response.body.getReader(), chunks = [];
      let size = 0;
      try {
        while (true) {
          if (controller.signal.aborted) throw failure("cancelled");
          const item = await reader.read();
          if (item.done) break;
          size += item.value.byteLength;
          if (size > MAX_AUDIO_FILE) throw failure("audio_too_large");
          if (existingBytes + size > MAX_AUDIO_STORED || remaining < size * 1.1) throw failure("storage_full");
          chunks.push(item.value);
          await audioPublish({state: "downloading", url, completedBytes: size, totalBytes: declared});
        }
      } catch (error) { await reader.cancel().catch(() => {}); throw error; }
      finally { reader.releaseLock(); }
      const bytes = new Uint8Array(size);
      let offset = 0; for (const chunk of chunks) { bytes.set(chunk, offset); offset += chunk.byteLength; }
      chunks.length = 0;
      const isMp3 = size >= 3 && ((bytes[0] === 0x49 && bytes[1] === 0x44 && bytes[2] === 0x33) || (bytes[0] === 0xff && (bytes[1] & 0xe0) === 0xe0));
      if (!isMp3 || (declared && size !== declared)) throw failure("audio_download_failed");
      const meta = {schemaVersion: 1, url, readerName: details.readerName, surahNumber: details.surahNumber, surahName: details.surahName, bytes: size, sha256: await digest(bytes)};
      if (controller.signal.aborted) throw failure("cancelled");
      cache = await caches.open(AUDIO_CACHE);
      await cache.put(url, new Response(bytes, {headers: {"Content-Type": "audio/mpeg"}})); wrote = true;
      if (controller.signal.aborted) throw failure("cancelled");
      await cache.put(await audioMetaURL(url), new Response(JSON.stringify(meta), {headers: {"Content-Type": "application/json"}}));
      committed = true;
      return audioPublish({state: "ready", entry: meta, completedBytes: size, totalBytes: size});
    } catch (error) {
      if (wrote && !committed) { await cache.delete(url); await cache.delete(await audioMetaURL(url)); }
      const code = controller.signal.aborted ? "cancelled" : error.name === "QuotaExceededError" ? "storage_full" : error.code || "audio_download_failed";
      return audioPublish({state: code === "cancelled" ? "cancelled" : "error", errorCode: code});
    } finally { clearTimeout(timer); audioOperation = null; }
  })();
  current.done = work;
  return work;
}
async function audioCommand(action, details) {
  if (action === "list") return {supported: true, state: "idle", entries: await listAudio()};
  if (action === "download") return downloadAudio(details);
  if (action === "cancel") { const current = audioOperation; if (current) { current.controller.abort(); await current.done; } return {supported: true, state: "cancelled"}; }
  const url = audioURL(details.url);
  if (action === "has") return {supported: true, state: "idle", entry: await verifiedAudio(url)};
  if (action === "remove") {
    if (audioOperation?.url === url) { const current = audioOperation; current.controller.abort(); await current.done; }
    if ((await caches.keys()).includes(AUDIO_CACHE)) { const cache = await caches.open(AUDIO_CACHE); await cache.delete(url); await cache.delete(await audioMetaURL(url)); }
    return audioPublish({state: "removed", url});
  }
  throw failure("invalid_audio");
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
      for (let next = 0; next < manifest.files.length;) {
        if (controller.signal.aborted) throw failure("cancelled");
        const batch = [];
        let batchBytes = 0;
        while (next < manifest.files.length && batch.length < DOWNLOAD_CONCURRENCY) {
          const entry = manifest.files[next];
          // A single large file retains the previous per-file limit, but is
          // never downloaded alongside others. Bound small-file memory too.
          if (batch.length && batchBytes + entry.bytes > MAX_BATCH_BYTES) break;
          batch.push(entry);
          batchBytes += entry.bytes;
          next++;
        }
        const results = await Promise.allSettled(batch.map(async entry => {
          if (controller.signal.aborted) throw failure("cancelled");
          // The index alias is fixed policy, never a manifest-supplied URL.
          const isHTML = entry.path === "/index.html" || entry.path === "/privacy.html";
          const sourcePath = entry.path === "/index.html" ? INDEX_SOURCE_PATH : entry.path === "/privacy.html" ? PRIVACY_SOURCE_PATH : entry.path;
          const file = await download(sourcePath, entry.bytes, controller.signal);
          if (file.bytes.byteLength !== entry.bytes || await digest(file.bytes) !== entry.sha256) throw failure("integrity_failed");
          if (controller.signal.aborted) throw failure("cancelled");
          const contentType = isHTML ? "text/html; charset=utf-8" : file.contentType;
          await cache.put(originURL(entry.path), new Response(file.bytes, {headers: {"Content-Type": contentType}}));
          completed++;
          bytesDone += entry.bytes;
        }));
        // All in-flight puts settle BEFORE failure/cancellation cleanup. No
        // late write can recreate a cache after it has been removed.
        const rejected = results.find(result => result.status === "rejected");
        if (rejected) throw rejected.reason;
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
  if (event.data?.type === "quran-audio-command" && event.ports?.[0]) {
    event.waitUntil((async () => {
      const source = event.source;
      if (!source?.id) return;
      const client = await self.clients.get(source.id);
      if (!client || new URL(client.url).origin !== self.location.origin) return;
      let result;
      try { result = await audioCommand(event.data.action, event.data); }
      catch (error) { result = {supported: true, state: "error", errorCode: error.code || "storage_unavailable"}; }
      event.ports[0].postMessage(result);
    })());
    return;
  }
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

function verifiedVideoResponse(bytes, cached, entry, request) {
  const headers = new Headers(cached.headers);
  headers.set("Content-Type", "video/mp4");
  headers.set("Accept-Ranges", "bytes");
  headers.set("ETag", '"' + entry.sha256 + '"');
  headers.delete("Content-Encoding");
  const range = request.headers.get("Range");
  const ifRange = request.headers.get("If-Range");
  if (!range || (ifRange && ifRange !== headers.get("ETag"))) {
    headers.set("Content-Length", String(bytes.byteLength));
    return new Response(bytes, {status: 200, headers});
  }
  const match = /^bytes=(\d*)-(\d*)$/.exec(range);
  let start, end;
  if (match && (match[1] || match[2])) {
    if (!match[1]) {
      const suffix = Number(match[2]);
      if (Number.isSafeInteger(suffix) && suffix > 0) {
        start = Math.max(0, bytes.byteLength - suffix);
        end = bytes.byteLength - 1;
      }
    } else {
      start = Number(match[1]);
      end = match[2] ? Number(match[2]) : bytes.byteLength - 1;
    }
  }
  if (!Number.isSafeInteger(start) || !Number.isSafeInteger(end)
      || start < 0 || start >= bytes.byteLength || end < start) {
    headers.set("Content-Range", "bytes */" + bytes.byteLength);
    headers.set("Content-Length", "0");
    return new Response(null, {status: 416, headers});
  }
  end = Math.min(end, bytes.byteLength - 1);
  const slice = bytes.slice(start, end + 1);
  headers.set("Content-Range", `bytes ${start}-${end}/${bytes.byteLength}`);
  headers.set("Content-Length", String(slice.byteLength));
  return new Response(slice, {status: 206, headers});
}

self.addEventListener("fetch", event => {
  const request = event.request;
  if (request.method !== "GET" || request.headers.has("Authorization") || request.headers.has("Cookie")) return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin || url.hash) return;
  const requestedVersion = url.searchParams.get("quran-release");
  // The policy is one public document; its bounded language selector changes
  // only display, not its bytes. Do not intercept any other caller query.
  const privacyLanguage = url.pathname === "/privacy.html" && url.searchParams.size === 1
    && ["ar", "en", "es"].includes(url.searchParams.get("lang"));
  if (url.search && !privacyLanguage && (url.searchParams.size !== 1 || !versionOK(requestedVersion))) return;
  const path = url.pathname === "/" && request.mode === "navigate" ? "/index.html" : url.pathname;
  if (!staticPath(path)) return;
  event.respondWith((async () => {
    try {
      const active = await activeVersion();
      if (active && (!requestedVersion || requestedVersion === active)) {
        const name = cacheName(active);
        const meta = await storedMeta(name);
        const entry = meta.manifest.files.find(entry => entry.path === path);
        if (entry) {
          const cached = await (await caches.open(name)).match(originURL(path));
          if (cached) {
            try {
              const bytes = await readLimited(cached.clone(), entry.bytes);
              if (bytes.byteLength === entry.bytes && await digest(bytes) === entry.sha256) {
                // Native/web tutorial players seek with Range. Slice only after
                // checking the entire saved file, never enroll a partial video.
                return /^\/assets\/assets\/tutorials\/(ar|en|es)\/[a-z-]+\.mp4$/.test(path)
                  ? verifiedVideoResponse(bytes, cached, entry, request)
                  : cached;
              }
            } catch (_) { /* Never serve corrupt stored Quran or application bytes. */ }
            await (await caches.open(name)).delete(originURL(path));
          }
          // Browser eviction is a cache miss, never an invented offline success.
          await publish(await status({state: "error", errorCode: "cache_missing", offlineReady: false}));
        }
      }
    } catch (_) { /* Storage denial must not prevent normal online reading. */ }
    // Online assets also need release separation when no complete local shell
    // exists yet. CacheStorage keys stay canonical and remain hash-verified.
    return fetch(requestedVersion ? url.href : releaseURL(path), {headers: request.headers, credentials: "omit", cache: "no-store", redirect: "error"});
  })());
});
