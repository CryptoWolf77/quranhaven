/* Network-free Node tests exercise the real worker with browser API mocks. */
"use strict";
const assert = require("node:assert/strict");
const {webcrypto, createHash} = require("node:crypto");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const test = require("node:test");

const source = fs.readFileSync(path.join(__dirname, "../web/quran_service_worker.js"), "utf8");
const VERSION = "a".repeat(64);
const NEXT = "b".repeat(64);
const ORIGIN = "https://quranhaven.org";

class MockCaches {
  constructor() { this.values = new Map(); }
  async keys() { return [...this.values.keys()]; }
  async delete(name) { return this.values.delete(name); }
  async open(name) {
    if (!this.values.has(name)) this.values.set(name, new Map());
    const entries = this.values.get(name);
    return {
      match: async key => entries.get(typeof key === "string" ? key : key.url)?.clone(),
      put: async (key, value) => entries.set(typeof key === "string" ? key : key.url, value.clone()),
      keys: async () => [...entries.keys()].map(url => new Request(url)),
      delete: async key => entries.delete(typeof key === "string" ? key : key.url),
    };
  }
}

function manifest(version = VERSION) {
  const contents = new Map([
    ["/index.html", "<html>Quran Haven</html>"],
    ["/flutter_bootstrap.js", "bootstrap"],
    ["/main.dart.js", "application"],
    ["/assets/AssetManifest.bin", "public-assets"],
  ]);
  const files = [...contents].map(([path, text]) => ({path, bytes: Buffer.byteLength(text), sha256: createHash("sha256").update(text).digest("hex")}));
  return {contents, data: {schemaVersion: 1, version, totalBytes: files.reduce((sum, file) => sum + file.bytes, 0), files}};
}

function harness(options = {}) {
  const listeners = {};
  const messages = [];
  const requests = [];
  const caches = options.caches || new MockCaches();
  const fixture = manifest(options.version || VERSION);
  let offline = false;
  let corrupt = false;
  let activated = false;
  let blockAsset = null;
  const context = vm.createContext({
    Request, Response, Headers, URL, Uint8Array, TextDecoder, TextEncoder,
    AbortController, crypto: webcrypto, console, setTimeout, clearTimeout,
    self: {
      location: {origin: ORIGIN},
      navigator: {storage: {estimate: async () => ({quota: 1024 ** 3, usage: 0})}},
      addEventListener: (name, handler) => { listeners[name] = handler; },
      skipWaiting: async () => { activated = true; },
      clients: {
        claim: async () => {},
        get: async id => ({id, url: ORIGIN + "/"}),
        matchAll: async () => [{id: "reader", url: ORIGIN + "/", postMessage: message => messages.push(message)}],
      },
    },
    caches,
    fetch: async (input, init = {}) => {
      const url = typeof input === "string" ? input : input.url;
      requests.push({url, init});
      if (offline) throw new Error("offline");
      const pathname = new URL(url).pathname;
      if (pathname === "/offline-manifest.json") return new Response(JSON.stringify(fixture.data));
      if (blockAsset && pathname !== "/offline-manifest.json") await blockAsset(init.signal);
      if (fixture.contents.has(pathname)) return new Response(corrupt ? "corrupt" : fixture.contents.get(pathname), {headers: {"Content-Type": pathname.endsWith(".js") ? "application/javascript" : "text/html"}});
      return new Response("not found", {status: 404});
    },
  });
  vm.runInContext(source.replace("__QURAN_OFFLINE_VERSION__", options.version || VERSION), context);
  return {
    context, caches, messages, requests, fixture,
    setOffline: value => { offline = value; },
    setCorrupt: value => { corrupt = value; },
    setBlockAsset: value => { blockAsset = value; },
    activated: () => activated,
    call: async action => {
      let result;
      let work;
      listeners.message({source: {id: "reader"}, data: {type: "quran-offline-command", action, persisted: true, pageVersion: options.version || VERSION},
        ports: [{postMessage: value => { result = value; }}], waitUntil: promise => { work = promise; }});
      await work;
      return result;
    },
    fetch: async (pathname, {method = "GET", headers = {}, mode = "cors", origin = ORIGIN} = {}) => {
      let promise;
      listeners.fetch({request: {url: origin + pathname, method, headers: new Headers(headers), mode}, respondWith: value => { promise = value; }});
      return promise ? {intercepted: true, response: await promise} : {intercepted: false};
    },
  };
}

test("installation and status never download the bundle", async () => {
  const app = harness();
  assert.equal((await app.call("status")).state, "unprepared");
  assert.equal(app.requests.length, 0);
});

test("explicit prepare verifies all files and survives a worker restart offline", async () => {
  const app = harness();
  const done = await app.call("prepare");
  assert.equal(done.state, "ready");
  assert.equal(done.completedBytes, app.fixture.data.totalBytes);
  assert.equal(done.completedFiles, 4);
  assert.equal(done.persisted, true);
  assert.ok(app.messages.some(message => message.status.state === "preparing"));
  assert.ok(app.requests.every(request => request.init.credentials === "omit" && request.init.redirect === "error"));
  const restarted = harness({caches: app.caches});
  restarted.setOffline(true);
  const loaded = await restarted.fetch("/", {mode: "navigate"});
  assert.equal(loaded.intercepted, true);
  assert.match(await loaded.response.text(), /Quran Haven/);
  assert.equal(restarted.requests.length, 0);
});

test("auth, API, Quran content, health, arbitrary navigation and queries are never intercepted", async () => {
  const app = harness();
  await app.call("prepare");
  for (const [pathname, options] of [
    ["/v1/tafsir/es.json.gz", {}], ["/api/login", {}], ["/health", {}],
    ["/account", {mode: "navigate"}], ["/index.html?token=private", {}],
    ["/main.dart.js", {headers: {Authorization: "Bearer private"}}],
    ["/main.dart.js", {headers: {Cookie: "private-session"}}],
    ["/main.dart.js", {method: "PUT"}], ["/main.dart.js", {origin: "https://api.quranhaven.org"}],
    ["/assets/../account", {}], ["/assets/.env", {}],
  ]) assert.equal((await app.fetch(pathname, options)).intercepted, false, pathname);
});

test("corruption fails without replacing the prior complete release", async () => {
  const previous = harness();
  await previous.call("prepare");
  const next = harness({version: NEXT, caches: previous.caches});
  next.setCorrupt(true);
  const result = await next.call("prepare");
  assert.equal(result.state, "error");
  assert.equal(result.errorCode, "integrity_failed");
  assert.equal(result.activeVersion, VERSION);
  assert.ok(!(await next.caches.keys()).includes("quran-haven-shell-v1-" + NEXT));
});

test("new release is staged before explicit activation then retires older complete caches", async () => {
  const previous = harness();
  await previous.call("prepare");
  const next = harness({version: NEXT, caches: previous.caches});
  assert.equal((await next.call("prepare")).state, "updateReady");
  assert.equal(next.activated(), false);
  assert.equal((await next.call("status")).activeVersion, VERSION);
  assert.ok((await next.caches.keys()).includes("quran-haven-shell-v1-" + VERSION));
  assert.equal((await next.call("activate")).activeVersion, NEXT);
  assert.equal(next.activated(), true);
  assert.ok(!(await next.caches.keys()).includes("quran-haven-shell-v1-" + VERSION));
});

test("cancel removes partial work; removal touches only shell-owned caches", async () => {
  const app = harness();
  await app.caches.open("quran-haven-tafsir-v1");
  await app.caches.open("unrelated-reader-data");
  let blocked;
  const started = new Promise(resolve => { blocked = resolve; });
  app.setBlockAsset(signal => new Promise((resolve, reject) => {
    blocked();
    signal.addEventListener("abort", () => reject(new Error("aborted")), {once: true});
  }));
  const preparation = app.call("prepare");
  await started;
  await app.call("cancel");
  assert.equal((await preparation).state, "cancelled");
  assert.equal((await app.call("status")).offlineReady, false);
  await app.call("remove");
  assert.deepEqual((await app.caches.keys()).sort(), ["quran-haven-tafsir-v1", "unrelated-reader-data"]);
});

test("invalid manifests cannot enroll sensitive paths or duplicate files", async () => {
  for (const illegal of ["/v1/auth/login", "/v1/tafsir/es.json.gz", "/assets/.env", "//other.example/file", "/assets/%2e%2e/account"] ) {
    const app = harness();
    app.fixture.data.files[0].path = illegal;
    assert.equal((await app.call("prepare")).errorCode, "invalid_manifest");
  }
  const app = harness();
  app.fixture.data.files[1].path = app.fixture.data.files[0].path;
  assert.equal((await app.call("prepare")).errorCode, "invalid_manifest");
});

test("bootstrap uses direct registration, stable bridge and no automatic prepare", () => {
  const bootstrap = fs.readFileSync(path.join(__dirname, "../web/flutter_bootstrap.js"), "utf8");
  new vm.Script(bootstrap.replace("{{flutter_js}}", "").replace("{{flutter_build_config}}", ""));
  assert.match(bootstrap, /navigator\.serviceWorker\.register\("quran_service_worker.js"/);
  assert.doesNotMatch(bootstrap, /serviceWorkerSettings\s*:/);
  assert.match(bootstrap, /window\.quranOffline = Object\.freeze/);
  assert.match(bootstrap, /return command\("prepare", \{persisted\}\)/);
  assert.match(bootstrap, /navigator\.storage\.persist\(\)/);
});

test("evicted shell entries are not reported as ready", async () => {
  const app = harness();
  await app.call("prepare");
  await (await app.caches.open("quran-haven-shell-v1-" + VERSION)).delete(ORIGIN + "/main.dart.js");
  const state = await app.call("status");
  assert.equal(state.errorCode, "cache_missing");
  assert.equal(state.offlineReady, false);
  assert.equal((await app.call("prepare")).state, "ready");
  app.setOffline(true);
  assert.equal(await (await app.fetch("/main.dart.js")).response.text(), "application");
});

test("quota rejection preserves existing downloads", async () => {
  const app = harness();
  app.context.self.navigator.storage.estimate = async () => ({quota: 1, usage: 0});
  const state = await app.call("prepare");
  assert.equal(state.errorCode, "storage_full");
  assert.equal(app.requests.length, 1);
});

test("corrupt cached bytes are never served and explicit preparation repairs them", async () => {
  const app = harness();
  await app.call("prepare");
  const cache = await app.caches.open("quran-haven-shell-v1-" + VERSION);
  await cache.put(ORIGIN + "/main.dart.js", new Response("corrupt"));
  const response = await app.fetch("/main.dart.js");
  assert.equal(await response.response.text(), "application");
  assert.equal((await app.call("status")).errorCode, "cache_missing");
  assert.equal((await app.call("prepare")).state, "ready");
  await cache.put(ORIGIN + "/main.dart.js", new Response("corrupt"));
  // A direct prepare also validates existing content, even before any fetch.
  assert.equal((await app.call("prepare")).state, "ready");
  assert.equal(await (await cache.match(ORIGIN + "/main.dart.js")).text(), "application");
});

test("activation defers while another old-release tab is open", async () => {
  const previous = harness();
  await previous.call("prepare");
  const next = harness({version: NEXT, caches: previous.caches});
  await next.call("prepare");
  next.context.self.clients.matchAll = async () => [
    {id: "reader", url: ORIGIN + "/", postMessage: () => {}},
    {id: "another-reader", url: ORIGIN + "/", postMessage: () => {}},
  ];
  assert.equal((await next.call("activate")).errorCode, "other_tabs_open");
  assert.equal((await next.call("status")).activeVersion, VERSION);
  assert.equal(next.activated(), false);
  assert.ok((await next.caches.keys()).includes("quran-haven-shell-v1-" + VERSION));
});

test("multiple updates do not retain inactive complete releases", async () => {
  let app = harness();
  await app.call("prepare");
  for (const version of [NEXT, "c".repeat(64), "d".repeat(64)]) {
    app = harness({version, caches: app.caches});
    await app.call("prepare");
    await app.call("activate");
    assert.equal((await app.caches.keys()).filter(name => name.startsWith("quran-haven-shell-v1-")).length, 1);
  }
});

test("bridge waits for controller change before reloading", () => {
  const bootstrap = fs.readFileSync(path.join(__dirname, "../web/flutter_bootstrap.js"), "utf8");
  assert.ok(bootstrap.indexOf('addEventListener("controllerchange", onChange)') < bootstrap.indexOf('const status = await command("activate")'));
  assert.ok(bootstrap.indexOf("const activated = await changed") < bootstrap.indexOf("if (activated) window.location.reload()"));
});

test("first preparation leaves old pre-PWA tabs untouched until explicit activation", async () => {
  const app = harness();
  app.context.self.clients.matchAll = async () => [
    {id: "reader", url: ORIGIN + "/", postMessage: () => {}},
    {id: "old-pre-pwa-tab", url: ORIGIN + "/", postMessage: () => {}},
  ];
  const state = await app.call("prepare");
  assert.equal(state.state, "updateReady");
  assert.equal(state.activeVersion, null);
  assert.equal(state.offlineReady, false);
  assert.equal((await app.call("activate")).errorCode, "other_tabs_open");
  app.context.self.clients.matchAll = async () => [{id: "reader", url: ORIGIN + "/", postMessage: () => {}}];
  assert.equal((await app.call("activate")).state, "ready");
});

test("bootstrap does not reload until the new controller actually takes over", async () => {
  const bootstrap = fs.readFileSync(path.join(__dirname, "../web/flutter_bootstrap.js"), "utf8");
  const events = new Map();
  let reloads = 0;
  let activatedRequest;
  const requested = new Promise(resolve => { activatedRequest = resolve; });
  const waiting = {state: "installed", postMessage: (data, ports) => {
    ports[0].postMessage({state: "ready", supported: true});
    activatedRequest();
  }};
  const registration = {waiting, active: {state: "activated"}};
  const serviceWorker = {
    controller: registration.active,
    register: async () => registration,
    ready: Promise.resolve(registration),
    addEventListener: (name, fn) => events.set(name, fn),
    removeEventListener: name => events.delete(name),
  };
  class Channel {
    constructor() {
      this.port1 = {onmessage: null, close: () => {}};
      this.port2 = {postMessage: data => queueMicrotask(() => this.port1.onmessage?.({data}))};
    }
  }
  const window = {isSecureContext: true, location: {reload: () => reloads++}, dispatchEvent: () => {}};
  const notice = {style: {}, setAttribute: () => {}, remove: () => {}};
  const context = vm.createContext({
    window, navigator: {serviceWorker}, MessageChannel: Channel,
    CustomEvent: class {constructor(type, options) {this.type = type; this.detail = options.detail;}},
    document: {createElement: () => notice, body: {appendChild: () => {}}},
    setTimeout, clearTimeout,
    _flutter: {loader: {load: options => options.onEntrypointLoaded({initializeEngine: async () => ({runApp: async () => {}})})}},
  });
  vm.runInContext(bootstrap.replace("{{flutter_js}}", "").replace("{{flutter_build_config}}", "").replace("__QURAN_OFFLINE_VERSION__", VERSION), context);
  const activation = window.quranOffline.activateAndReload();
  await requested;
  await new Promise(resolve => setImmediate(resolve));
  assert.equal(reloads, 0);
  serviceWorker.controller = waiting;
  waiting.state = "activated";
  events.get("controllerchange")();
  await activation;
  assert.equal(reloads, 1);
});
