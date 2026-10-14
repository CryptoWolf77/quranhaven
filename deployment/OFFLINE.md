# Browser offline reading

The web app now owns its offline worker; Flutter's generated cleanup worker is
not used for caching. Core reading is still bundled in the Android/iOS app.

## Reader controls

1. Open Settings online and choose **Prepare offline reading**. This saves the
   app, local CanvasKit renderer, Quran data, bundled Tafsir and all 604 page
   fonts and bundled learning data. The screen reports downloaded bytes;
   size varies with the release and its guide media.
2. Wait for **Ready for offline reading**. If an update is staged, close other
   Quran Haven tabs and choose **Apply update and reload**. Never assume that
   opening the site alone prepared it for offline use.
3. Save additional Tafsir/translations in Library. They use a separate 160 MiB
   cache and remain available after reload. Audio is not included in web offline
   preparation. In Recitations, save complete Surah recordings separately.
   Native audio downloads retain their existing behavior.
4. Recheck Settings before relying on offline access. Browsers can deny storage
   or evict it. Preparing again repairs missing core files. A damaged optional
   resource can be removed and downloaded again.

Removing offline app files requires confirmation. It removes only the named
Quran Haven shell caches, not reading preferences, plans, bookmarks
or the separate saved Tafsir/translation/audio caches. Optional resources can be removed
individually, except the two bundled defaults.

## Separate Surah audio cache (build 14)

Choose a Surah and reciter in Library/reader controls, then explicitly choose
Download for offline. Downloading does not start playback. Only a complete,
MP3-validated, SHA-256-recorded response is enrolled in the separate
`quran-haven-audio-v1` cache; cancellation/failure does not advertise partial data.
The policy accepts only the 29 approved reader roots and Surahs 001–114, not
arbitrary/authenticated/redirected URLs. Limits are 256 MiB per recording and
1 GiB total, also subject to available browser quota. Word-by-word/Ayah playback
is not included. Third-party CORS/provider availability can still prevent a
download; online audio alone does not mean it is saved.

Saved-recording Play verifies bytes and uses a local Blob source with seeking.
The site itself must also be prepared before reopening it offline. Per-recording
Delete requires confirmation and leaves other recordings, shell, books and
personal data intact. Removing shell files leaves saved audio intact too.
Browser eviction/clearing can remove either cache; there is no server recovery.
Personal JSON backups exclude downloaded recordings/books and static app files.

App preparation uses an inactivity-based bridge timeout refreshed by download
progress; it does not fail merely because a slow complete transfer takes more
than fifteen minutes. Individual stalled file requests are still bounded.

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

Build 7 separates network asset requests using a fixed `quran_release` query key
derived from the worker's release identity. This prevents a CDN from returning
an older subset icon font or another unchanged filename after deployment.
Manifest paths and local cache keys remain query-free; original byte counts and
SHA-256 checks are still required. NGINX revalidates unversioned assets.

Since build 11, generated HTML also loads a release-keyed bootstrap, and the
bootstrap registers a release-keyed worker and main JavaScript entrypoint using
`quran-release`. These entrypoints no longer rely on an unversioned CDN object.
The worker recognizes only that single validated release query for static app
files; matching versions reuse the verified canonical cache, while a different
version uses the network. Arbitrary queries and sensitive/API paths are still
excluded. Regenerating the manifest normalizes/stamps the HTML marker too, so
hashes and the binary HTML transport remain exact and repeatable.

Preparation downloads at most three files concurrently, with a 12 MiB batch
budget (a larger allowed individual file downloads alone). Every in-flight write
settles before cancellation/failure cleanup. These limits reduce waiting without
removing integrity, quota or staged-update safeguards.

## Boundaries

Tutorial H264 MP4 files and their posters are bundled with the app shell. Online
and saved tutorial playback starts only on explicit Play. Offline Range requests
are served from the saved full file only after its exact length/hash has been
verified; malformed or out-of-bounds ranges return416 without trusting partial
data. The public multilingual privacy document also has a byte-preserving binary
transport alias (`offline-privacy.bin`), cached under `privacy.html`, not twice.
Only its bounded `lang=ar|en|es` display query may reuse those public bytes.

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
- Personal data stays on this device/browser only. There are no accounts or
  remote snapshots. Clearing site data, eviction or uninstalling can erase saved
  items; user data is never added to these static app caches.

## Repeatable checks

```sh
python -B -m unittest discover -s deployment -p 'test_*.py'
node --test deployment/test_offline_worker.cjs
node --test deployment/test_browser_audio.cjs
flutter test
```

The worker tests mock browser APIs without real network traffic. They check
offline responses, excluded non-public requests, integrity failures, interrupted
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
