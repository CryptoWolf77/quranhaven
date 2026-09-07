# Browser offline reading

The web app now owns its offline worker; Flutter's generated cleanup worker is
not used for caching. Core reading is still bundled in the Android/iOS app.

## Reader controls

1. Open Settings online and choose **Prepare offline reading**. This saves the
   app, local CanvasKit renderer, Quran data, bundled Tafsir and all 604 page
   fonts. The screen reports downloaded bytes; the current build is about 93 MiB.
2. Wait for **Ready for offline reading**. If an update is staged, close other
   Quran Haven tabs and choose **Apply update and reload**. Never assume that
   opening the site alone prepared it for offline use.
3. Save additional Tafsir/translations in Library. They use a separate 160 MiB
   cache and remain available after reload. Audio is not included in web offline
   preparation. Native audio downloads retain their existing behavior.
4. Recheck Settings before relying on offline access. Browsers can deny storage
   or evict it. Preparing again repairs missing core files. A damaged optional
   resource can be removed and downloaded again.

Removing offline app files requires confirmation. It removes only the named
Quran Haven shell caches, not account data, reading preferences, plans, bookmarks
or the separate saved Tafsir/translation cache. Optional resources can be removed
individually, except the two bundled defaults.

## Build

After `flutter build web --release --no-web-resources-cdn`, run:

```sh
python deployment/prepare_offline.py --web-root build/web
```

The root Dockerfile performs this step automatically in its Python stage. It
stamps the custom bootstrap and worker with a repeatable release identity and
writes exact byte counts and SHA-256 hashes into `offline-manifest.json`. Do not
serve an unstamped build when testing offline behavior.

The build also emits `offline-index.bin`, an exact byte copy of `index.html`.
NGINX serves it as binary so CDN HTML optimization or analytics injection cannot
change the offline payload. The worker downloads that fixed transport URL,
verifies the original HTML hash, and only then stores it as `text/html` under
`/index.html`. Online HTML remains subject to the domain's existing CDN settings.

## Boundaries

- Explicit preparation only; installation does not silently fetch the bundle.
- Exact public same-origin static files only; no API, login, backup, content
  `/v1/` requests, non-GET requests, or authorization-bearing traffic is cached
  by the app worker. Optional verified resources have their own cache adapter.
- Each shell release is capped at 160 MiB, active plus staged at 320 MiB.
- A staged release must be complete and verified before activation. Older
  complete shell caches retire only after explicit activation and a check that
  other Quran Haven tabs are closed.
- Optional downloads use exact self-hosted manifest hashes and bounded
  decompression, with a cross-tab write lock and no silent eviction.
- Browser storage is not a backup of personal data. Accounts still use explicit
  remote snapshot backup; user data is never added to these static caches.

## Repeatable checks

```sh
python -B -m unittest discover -s deployment -p 'test_*.py'
node --test deployment/test_offline_worker.cjs
flutter test
```

The worker tests mock browser APIs without real network traffic. They check
offline responses, excluded account requests, integrity failures, interrupted
downloads, missing-entry repair, quota failure, cancellation, deletion scope,
multi-tab activation and successive updates. These tests do not substitute for
physical-device/browser offline acceptance testing.

For a local browser acceptance check after building and stamping the app:

```sh
python deployment/serve_web.py --web-root build/web --port 8087
```

This helper binds only to loopback, supplies deterministic JavaScript/WASM MIME
types on Windows and disables HTTP caching so it cannot mask worker failures.
Prepare offline reading in the browser, stop the helper and navigate from `/`
to `/index.html` to verify a fresh application startup without its server.
Other internet hosts remain reachable in this test; separately test airplane
mode and optional downloaded resources on supported physical devices.
