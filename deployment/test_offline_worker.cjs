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
    ["/privacy.html", "<html>Quran Haven Privacy</html>"],
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
  let injectedHTML = false;
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
      if (blockAsset && pathname !== "/offline-manifest.json") await blockAsset(init.signal, pathname);
      if (pathname === "/offline-index.bin") return new Response(corrupt ? "corrupt" : fixture.contents.get("/index.html"), {headers: {"Content-Type": "application/octet-stream"}});
      if (pathname === "/offline-privacy.bin") return new Response(corrupt ? "corrupt" : fixture.contents.get("/privacy.html"), {headers: {"Content-Type": "application/octet-stream"}});
      if (["/index.html", "/privacy.html"].includes(pathname) && injectedHTML) return new Response(fixture.contents.get(pathname) + '<script src="/injected-analytics.js"></script>', {headers: {"Content-Type": "text/html"}});
      if (fixture.contents.has(pathname)) return new Response(corrupt ? "corrupt" : fixture.contents.get(pathname), {headers: {"Content-Type": pathname.endsWith(".js") ? "application/javascript" : "text/html"}});
      return new Response("not found", {status: 404});
    },
  });
  vm.runInContext(source.replace("__QURAN_OFFLINE_VERSION__", options.version || VERSION), context);
  return {
    context, caches, messages, requests, fixture,
    setOffline: value => { offline = value; },
    setCorrupt: value => { corrupt = value; },
    setInjectedHTML: value => { injectedHTML = value; },
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

test("saved tutorial video supports bounded ranges only after full-file verification", async () => {
  const app = harness();
  const pathname = "/assets/assets/tutorials/ar/reader.mp4";
  const body = "0123456789-video-fixture";
  app.fixture.contents.set(pathname, body);
  app.fixture.data.files.push({path: pathname, bytes: body.length, sha256: createHash("sha256").update(body).digest("hex")});
  app.fixture.data.totalBytes += body.length;
  assert.equal((await app.call("prepare")).state, "ready");
  app.setOffline(true);
  for (const [range, expected, contentRange] of [
    ["bytes=2-5", "2345", `bytes 2-5/${body.length}`],
    ["bytes=10-", body.slice(10), `bytes 10-${body.length - 1}/${body.length}`],
    ["bytes=-7", body.slice(-7), `bytes ${body.length - 7}-${body.length - 1}/${body.length}`],
    ["bytes=0-999", body, `bytes 0-${body.length - 1}/${body.length}`],
  ]) {
    const {response} = await app.fetch(pathname, {headers: {Range: range}});
    assert.equal(response.status, 206);
    assert.equal(response.headers.get("Content-Range"), contentRange);
    assert.equal(response.headers.get("Accept-Ranges"), "bytes");
    assert.equal(response.headers.get("Content-Type"), "video/mp4");
    assert.equal(await response.text(), expected);
  }
  for (const range of ["bytes=100-", "bytes=8-2", "bytes=-0", "bytes=0-2,4-6", "bytes=-", "bytes=9007199254740992-"]) {
    const {response} = await app.fetch(pathname, {headers: {Range: range}});
    assert.equal(response.status, 416, range);
    assert.equal(response.headers.get("Content-Range"), `bytes */${body.length}`);
  }
  const full = await app.fetch(pathname, {headers: {Range: "bytes=1-3", "If-Range": '"old-file"'}});
  assert.equal(full.response.status, 200);
  assert.equal(await full.response.text(), body);
  const cache = await app.caches.open("quran-haven-shell-v1-" + VERSION);
  await cache.put(ORIGIN + pathname, new Response("corrupt"));
  await assert.rejects(app.fetch(pathname, {headers: {Range: "bytes=0-2"}}), /offline/);
  assert.equal(await cache.match(ORIGIN + pathname), undefined);
});

test("explicit prepare verifies all files and survives a worker restart offline", async () => {
  const app = harness();
  const done = await app.call("prepare");
  assert.equal(done.state, "ready");
  assert.equal(done.completedBytes, app.fixture.data.totalBytes);
  assert.equal(done.completedFiles, app.fixture.data.files.length);
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

test("one transient transport retry keeps the same release URL and strict verification", async () => {
  const app = harness();
  let attempts = 0;
  app.setBlockAsset(async (_signal, pathname) => {
    if (pathname === "/main.dart.js" && ++attempts === 1) throw new TypeError("temporary transport failure");
  });
  const result = await app.call("prepare");
  assert.equal(result.state, "ready");
  assert.equal(attempts, 2);
  const requests = app.requests.filter(request => new URL(request.url).pathname === "/main.dart.js");
  assert.equal(requests.length, 2);
  assert.equal(requests[0].url, requests[1].url);
  assert.ok(requests.every(request => request.init.redirect === "error" && request.init.credentials === "omit"));
});

test("a repeated transport failure stops after two attempts and never activates partial data", async () => {
  const app = harness();
  let attempts = 0;
  app.setBlockAsset(async (_signal, pathname) => {
    if (pathname === "/main.dart.js") {
      attempts++;
      throw new TypeError("unavailable transport");
    }
  });
  const result = await app.call("prepare");
  assert.equal(result.errorCode, "download_failed");
  assert.equal(attempts, 2);
  assert.equal(result.offlineReady, false);
  assert.equal((await app.call("status")).state, "unprepared");
  assert.deepEqual(await app.caches.keys(), []);
});

test("HTML edge injection is irrelevant to strict offline index integrity", async () => {
  const app = harness();
  app.setInjectedHTML(true);
  assert.match(await (await app.fetch("/index.html")).response.text(), /injected-analytics/);
  const requestStart = app.requests.length;
  assert.equal((await app.call("prepare")).state, "ready");
  const downloads = app.requests.slice(requestStart).map(request => new URL(request.url).pathname);
  assert.ok(downloads.includes("/offline-index.bin"));
  assert.ok(downloads.includes("/offline-privacy.bin"));
  assert.ok(!downloads.includes("/index.html"));
  assert.ok(!downloads.includes("/privacy.html"));
  app.setOffline(true);
  const loaded = await app.fetch("/", {mode: "navigate"});
  assert.equal(await loaded.response.text(), app.fixture.contents.get("/index.html"));
  assert.equal(loaded.response.headers.get("Content-Type"), "text/html; charset=utf-8");
  assert.equal((await app.fetch("/offline-index.bin")).intercepted, false);
  const privacy = await app.fetch("/privacy.html?lang=ar", {mode: "navigate"});
  assert.equal(await privacy.response.text(), app.fixture.contents.get("/privacy.html"));
  assert.equal(privacy.response.headers.get("Content-Type"), "text/html; charset=utf-8");
  assert.equal((await app.fetch("/offline-privacy.bin")).intercepted, false);
  const keys = await (await app.caches.open("quran-haven-shell-v1-" + VERSION)).keys();
  assert.ok(!keys.some(request => ["/offline-index.bin", "/offline-privacy.bin"].includes(new URL(request.url).pathname)));
});

test("auth, API, Quran content, health, arbitrary navigation and queries are never intercepted", async () => {
  const app = harness();
  await app.call("prepare");
  for (const [pathname, options] of [
    ["/v1/tafsir/es.json.gz", {}], ["/api/login", {}], ["/health", {}],
    ["/account", {mode: "navigate"}], ["/index.html?token=private", {}],
    ["/privacy.html?token=private", {}], ["/privacy.html?lang=fr", {}],
    ["/privacy.html?lang=ar&token=private", {}],
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
  for (const illegal of ["/v1/auth/login", "/v1/tafsir/es.json.gz", "/offline-index.bin", "/offline-privacy.bin", "/assets/.env", "//other.example/file", "/assets/%2e%2e/account"] ) {
    const app = harness();
    app.fixture.data.files[0].path = illegal;
    assert.equal((await app.call("prepare")).errorCode, "invalid_manifest");
  }
  const app = harness();
  app.fixture.data.files[1].path = app.fixture.data.files[0].path;
  assert.equal((await app.call("prepare")).errorCode, "invalid_manifest");
});

test("preparation bounds concurrent downloads to three and reports monotonic progress", async () => {
  const app = harness();
  let running = 0;
  let peak = 0;
  app.setBlockAsset(async () => {
    running++;
    peak = Math.max(peak, running);
    await new Promise(resolve => setTimeout(resolve, 5));
    running--;
  });
  assert.equal((await app.call("prepare")).state, "ready");
  assert.equal(peak, 3);
  const progress = app.messages.map(message => message.status.completedBytes);
  assert.ok(progress.every((value, index) => !index || value >= progress[index - 1]));
});

test("downloads and online fallback isolate CDN objects by the fixed release identity", async () => {
  const app = harness();
  await app.fetch("/assets/AssetManifest.bin");
  await app.call("prepare");
  assert.ok(app.requests.every(request => new URL(request.url).searchParams.get("quran_release") === VERSION));
  const cachedKeys = await (await app.caches.open("quran-haven-shell-v1-" + VERSION)).keys();
  assert.ok(cachedKeys.every(request => !new URL(request.url).search));
  app.setOffline(true);
  assert.equal(await (await app.fetch("/assets/AssetManifest.bin")).response.text(), "public-assets");
});

test("large files are not downloaded together beyond the batch byte budget", async () => {
  const app = harness();
  for (const pathname of ["/assets/large-a.bin", "/assets/large-b.bin"]) {
    const bytes = Buffer.alloc(9 * 1024 * 1024, 65);
    app.fixture.contents.set(pathname, bytes);
    app.fixture.data.files.push({path: pathname, bytes: bytes.length, sha256: createHash("sha256").update(bytes).digest("hex")});
    app.fixture.data.totalBytes += bytes.length;
  }
  let runningBytes = 0;
  let peakBytes = 0;
  app.setBlockAsset(async (_signal, pathname) => {
    const canonical = pathname === "/offline-index.bin" ? "/index.html" : pathname === "/offline-privacy.bin" ? "/privacy.html" : pathname;
    const entry = app.fixture.data.files.find(file => file.path === canonical);
    runningBytes += entry.bytes;
    peakBytes = Math.max(peakBytes, runningBytes);
    await new Promise(resolve => setTimeout(resolve, 5));
    runningBytes -= entry.bytes;
  });
  assert.equal((await app.call("prepare")).state, "ready");
  assert.ok(peakBytes < 12 * 1024 * 1024);
  assert.ok(peakBytes >= 9 * 1024 * 1024);
});

test("cancellation waits for every parallel download before removing partial work", async () => {
  const app = harness();
  let started;
  const inFlight = new Promise(resolve => { started = resolve; });
  let running = 0;
  app.setBlockAsset(signal => new Promise((resolve, reject) => {
    running++;
    if (running === 3) started();
    signal.addEventListener("abort", () => setTimeout(() => {
      running--;
      reject(new Error("aborted"));
    }, 5), {once: true});
  }));
  const preparation = app.call("prepare");
  await inFlight;
  await app.call("cancel");
  assert.equal((await preparation).state, "cancelled");
  assert.equal(running, 0);
  assert.ok(!(await app.caches.keys()).includes("quran-haven-shell-v1-" + VERSION));
});

test("bootstrap uses direct registration, stable bridge and no automatic prepare", () => {
  const bootstrap = fs.readFileSync(path.join(__dirname, "../web/flutter_bootstrap.js"), "utf8");
  new vm.Script(bootstrap.replace("{{flutter_js}}", "").replace("{{flutter_build_config}}", ""));
  assert.match(bootstrap, /navigator\.serviceWorker\.register\("quran_service_worker.js\?quran-release=" \+ SHELL_VERSION/);
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
    _flutter: {buildConfig: {builds: [{mainJsPath: "main.dart.js"}]}, loader: {load: options => options.onEntrypointLoaded({initializeEngine: async () => ({runApp: async () => {}})})}},
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

test("release-keyed bootstrap and entrypoint reuse only the matching verified cache", async () => {
  const app = harness();
  await app.call("prepare");
  const count = app.requests.length;
  app.setOffline(true);
  for (const file of ["flutter_bootstrap.js", "main.dart.js"]) {
    const result = await app.fetch("/" + file + "?quran-release=" + VERSION);
    assert.equal(result.intercepted, true);
    assert.equal(await result.response.text(), app.fixture.contents.get("/" + file));
  }
  assert.equal(app.requests.length, count);
  assert.equal((await app.fetch("/main.dart.js?quran-release=" + VERSION + "&token=private")).intercepted, false);
  app.setOffline(false);
  await app.fetch("/main.dart.js?quran-release=" + NEXT);
  assert.equal(app.requests.at(-1).url, ORIGIN + "/main.dart.js?quran-release=" + NEXT);
});

test("preparation timeout follows inactivity, not total elapsed download time", async () => {
  const bootstrap = fs.readFileSync(path.join(__dirname, "../web/flutter_bootstrap.js"), "utf8");
  const events = new Map(), timers = new Map(); let clock = 0, id = 0, reply;
  const timer = (fn, ms) => { const key = ++id; timers.set(key, {fn, due:clock + ms}); return key; };
  const advance = ms => { clock += ms; for(const [key,t] of [...timers])if(t.due <= clock){timers.delete(key);t.fn();} };
  const worker = {postMessage: (_data, ports) => { reply = ports[0]; }};
  const registration = {active: worker};
  const serviceWorker = {register:async()=>registration,ready:Promise.resolve(registration),addEventListener:(name,fn)=>events.set(name,fn)};
  class Channel {constructor(){this.port1={close:()=>{},onmessage:null};this.port2={postMessage:data=>queueMicrotask(()=>this.port1.onmessage?.({data}))};}}
  const window={isSecureContext:true,dispatchEvent:()=>{},location:{reload:()=>{}}};
  const notice={style:{},setAttribute:()=>{},remove:()=>{}};
  const context=vm.createContext({window,navigator:{serviceWorker},MessageChannel:Channel,
    CustomEvent:class{constructor(type,options){this.type=type;this.detail=options.detail;}},
    document:{createElement:()=>notice,body:{appendChild:()=>{}}},setTimeout:timer,clearTimeout:key=>timers.delete(key),
    _flutter:{buildConfig:{builds:[{mainJsPath:'main.dart.js'}]},loader:{load:options=>options.onEntrypointLoaded({initializeEngine:async()=>({runApp:async()=>{}})})}}});
  vm.runInContext(bootstrap.replace('{{flutter_js}}','').replace('{{flutter_build_config}}','').replace('__QURAN_OFFLINE_VERSION__',VERSION),context);
  const preparation=window.quranOffline.prepare();await new Promise(resolve=>setImmediate(resolve));
  for(let n=0;n<20;n++){
    advance(150000);events.get('message')({data:{type:'quran-offline-status',status:{supported:true,state:'preparing',completedFiles:n}}});
    assert.equal(window.quranOffline.lastStatus.state,'preparing');
  }
  reply.postMessage({state:'ready',supported:true});assert.equal((await preparation).state,'ready');
  advance(300000);assert.equal(window.quranOffline.lastStatus.state,'ready');
  const stalled=window.quranOffline.prepare();await new Promise(resolve=>setImmediate(resolve));advance(180001);
  assert.equal((await stalled).errorCode,'timeout');
});
