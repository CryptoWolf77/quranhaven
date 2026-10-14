{{flutter_js}}
{{flutter_build_config}}

(() => {
  "use strict";
  const SHELL_VERSION = "__QURAN_OFFLINE_VERSION__";
  const EVENT = "quran-offline-status";
  let registration;
  let currentStatus = {state: "unprepared", supported: false, version: SHELL_VERSION};
  let audioStatus = {state: "idle", supported: false};
  let audioBlobUrl = null;
  let audioBlobSource = null;
  const prepareHeartbeats = new Set();

  function publishAudio(status) {
    audioStatus = {...status};
    window.dispatchEvent(new CustomEvent("quran-audio-status", {detail: audioStatus}));
    return audioStatus;
  }

  function publish(status) {
    currentStatus = {...status};
    window.dispatchEvent(new CustomEvent(EVENT, {detail: currentStatus}));
    return currentStatus;
  }

  function unsupported() {
    return publish({state: "unsupported", supported: false, errorCode: "unavailable", version: SHELL_VERSION});
  }

  const ready = (async () => {
    if (!("serviceWorker" in navigator) || !window.isSecureContext || !/^[a-f0-9]{64}$/.test(SHELL_VERSION)) {
      return null;
    }
    try {
      registration = await navigator.serviceWorker.register("quran_service_worker.js?quran-release=" + SHELL_VERSION, {
        scope: "./", updateViaCache: "none",
      });
      navigator.serviceWorker.addEventListener("message", event => {
        if (event.data?.type === EVENT) {
          publish(event.data.status);
          if (event.data.status?.state === "preparing") for (const heartbeat of prepareHeartbeats) heartbeat();
        }
        if (event.data?.type === "quran-audio-status") publishAudio(event.data.status);
      });
      await navigator.serviceWorker.ready;
      return registration;
    } catch (_) {
      return null;
    }
  })();

  async function command(action, details = {}) {
    const registered = await ready;
    if (!registered) return unsupported();
    const worker = registered.waiting || registered.active;
    if (!worker) return unsupported();
    return new Promise(resolve => {
      const channel = new MessageChannel();
      let timer;
      const resetTimer = () => {
        clearTimeout(timer);
        timer = setTimeout(() => {
          prepareHeartbeats.delete(resetTimer);
        channel.port1.close();
        resolve(publish({state: "error", supported: true, errorCode: "timeout", version: SHELL_VERSION}));
        }, action === "prepare" ? 3 * 60 * 1000 : 15000);
      };
      if (action === "prepare") prepareHeartbeats.add(resetTimer);
      resetTimer();
      channel.port1.onmessage = event => {
        clearTimeout(timer);
        prepareHeartbeats.delete(resetTimer);
        channel.port1.close();
        resolve(publish(event.data));
      };
      worker.postMessage({type: "quran-offline-command", action, pageVersion: SHELL_VERSION, ...details}, [channel.port2]);
    });
  }

  // The Flutter settings bridge may call these methods with JS interop and
  // listen for quran-offline-status CustomEvents. No preparation is automatic.
  window.quranOffline = Object.freeze({
    async status() {
      let persisted = null;
      if (navigator.storage?.persisted) {
        try { persisted = await navigator.storage.persisted(); } catch (_) { /* Unknown storage policy. */ }
      }
      return command("status", {persisted});
    },
    async prepare() {
      // persist() is a Window API, not a worker API. Ask only after the user
      // explicitly requests offline preparation; denial does not block caching.
      let persisted = null;
      if (navigator.storage?.persist) {
        try { persisted = await navigator.storage.persist(); } catch (_) { persisted = false; }
      }
      return command("prepare", {persisted});
    },
    cancel: () => command("cancel"),
    remove: () => command("remove"),
    get lastStatus() { return currentStatus; },
    async activateAndReload() {
      const registered = await ready;
      if (!registered) return unsupported();
      const worker = registered.waiting || registered.active;
      if (!worker) return unsupported();
      let finish;
      let timer;
      const changed = new Promise(resolve => { finish = resolve; });
      const onChange = () => {
        if (navigator.serviceWorker.controller === worker) finish(true);
      };
      navigator.serviceWorker.addEventListener("controllerchange", onChange);
      timer = setTimeout(() => finish(false), 20000);
      const status = await command("activate");
      if (status.state !== "ready") {
        clearTimeout(timer);
        navigator.serviceWorker.removeEventListener("controllerchange", onChange);
        return status;
      }
      onChange();
      if (!registered.waiting && worker.state === "activated" && !navigator.serviceWorker.controller) finish(true);
      const activated = await changed;
      clearTimeout(timer);
      navigator.serviceWorker.removeEventListener("controllerchange", onChange);
      if (activated) window.location.reload();
      else return publish({...status, state: "error", errorCode: "activation_timeout"});
      return status;
    },
  });

  async function audioCommand(action, details = {}) {
    const registered = await ready;
    const worker = registered?.waiting || registered?.active;
    if (!worker) return publishAudio({supported: false, state: "unsupported", errorCode: "unavailable"});
    return new Promise(resolve => {
      const channel = new MessageChannel();
      const timer = setTimeout(() => {
        channel.port1.close();
        resolve(publishAudio({supported: true, state: "error", errorCode: "timeout"}));
      }, action === "download" ? 15 * 60 * 1000 : 60000);
      channel.port1.onmessage = event => {
        clearTimeout(timer); channel.port1.close();
        resolve(action === "list" || action === "has" ? event.data : publishAudio(event.data));
      };
      worker.postMessage({type: "quran-audio-command", action, ...details}, [channel.port2]);
    });
  }
  window.quranAudio = Object.freeze({
    list: () => audioCommand("list"),
    download: details => audioCommand("download", details),
    cancel: () => audioCommand("cancel"),
    async remove(url) {
      const result = await audioCommand("remove", {url});
      if (result.state === "removed" && audioBlobSource === url) {
        URL.revokeObjectURL(audioBlobUrl); audioBlobUrl = null; audioBlobSource = null;
      }
      return result;
    },
    async playableUrl(url) {
      // Check the complete stored recording/hash before creating a local source.
      // Blob playback supports seeking without another network request.
      const result = await audioCommand("has", {url});
      if (!result.entry) return null;
      if (audioBlobSource === url && audioBlobUrl) return audioBlobUrl;
      const cache = await caches.open("quran-haven-audio-v1");
      const response = await cache.match(url);
      if (!response) return null;
      const blob = await response.blob();
      if (audioBlobUrl) URL.revokeObjectURL(audioBlobUrl);
      audioBlobUrl = URL.createObjectURL(blob); audioBlobSource = url;
      return audioBlobUrl;
    },
    get lastStatus() { return audioStatus; },
  });

  // Startup must still work online if browser storage or service workers fail.
  // This message is visible only when Flutter itself cannot start.
  const notice = document.createElement("div");
  notice.setAttribute("role", "status");
  notice.setAttribute("aria-live", "polite");
  notice.style.cssText = "max-width:34rem;margin:12vh auto;padding:1.5rem;font:1rem/1.6 system-ui;color:#123b2e;background:#f7f2e7;border-radius:1rem;text-align:center";
  notice.textContent = "Opening Quran Haven…";
  document.body.appendChild(notice);
  const startupTimer = setTimeout(() => {
    notice.textContent = "Quran Haven is taking longer to open. If you are offline, reconnect once and prepare offline reading in Settings.";
  }, 20000);
  // Flutter reuses main.dart.js across releases. Isolate the online entrypoint
  // just like the verified offline downloads, without changing CDN settings.
  for (const build of _flutter.buildConfig.builds) {
    if (build.mainJsPath) build.mainJsPath += "?quran-release=" + SHELL_VERSION;
  }
  Promise.resolve(_flutter.loader.load({
    config: {canvasKitBaseUrl: "canvaskit/"},
    onEntrypointLoaded: async engine => {
      try {
        const app = await engine.initializeEngine({canvasKitBaseUrl: "canvaskit/"});
        await app.runApp();
        clearTimeout(startupTimer);
        notice.remove();
      } catch (_) {
        clearTimeout(startupTimer);
        notice.textContent = "Quran Haven could not open. Reconnect and reload. Offline reading is available after its download finishes in Settings.";
      }
    },
  })).catch(() => {
    clearTimeout(startupTimer);
    notice.textContent = "Quran Haven could not open. Reconnect and reload. Offline reading is available after its download finishes in Settings.";
  });
})();
