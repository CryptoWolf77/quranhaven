# Quran Haven release verification

## Public build15 and Android bundle — 2026-10-15

- Deployed source `11baca87d3b55c085963bae622f2e4ac4c2fbc80` through only the
  Quran Haven website resource `xt9b22auyjtr8m32snvgsxl3`. Coolify deployment
  `vsbhk46bltstzwsh3pdoicld` reports Success (15m58s); the replacement container
  passed its health check. The old Cloud resource/data, DNS/CDN settings and
  unrelated applications were not modified. Existing unsaved General settings
  were not saved/reset while using the persisted Redeploy configuration.
- The actual public `/version.json` reports 1.0.0/build15. Its complete verified
  offline shell is 756 files / 145228009 bytes, release identity
  `86802ceb10d4634e2f82c83ca4ce0aad0df075f2b212bcb038ab06279400b17c`.
  The Linux-generated identity differs from the local clean build below.
- Public Chromium/Firefox/WebKit pass ar/en/es × desktop/tablet/phone navigation
  for all five main screens (27 combinations). No page exceptions or requests
  to the cancelled personal-data API were observed. Headless WebKit is not a
  physical Safari/iOS acceptance result.
- Public reader bounds/first/last spreads/Arabic search, all five display modes,
  downloaded Spanish translation/reload/deletion, Khatmah/memorization controls
  and persistence, complete Ayah1:5 PNG/text/link, late-Surah whole-book search,
  validated exact114:6 links, Corpus first/last navigation and actual Arabic/
  Spanish text content pass. Personal notes/collections and real JSON export/
  invalid input/cancel/safety-copy/replacement/reload pass in all three languages.
- All 39 public H264 videos pass actual play/pause/seek/replay online, then all
  39 pass those operations in a new forced-offline page after full preparation.
  This strict run has zero page/console errors, remote font failures or account
  API requests. Video decoding was tested in official Chrome, not asserted for
  every browser codec implementation.
- Public Al-Fatihah/Abdul Basit download is 669781 bytes, SHA256
  `7adec6166f88c6a8ade3b28e74764c8baa6a145365299ce28c0de4eb983c904f`.
  It does not autoplay; reload playback advances2.022→3.628s from a local Blob.
  A cold offline page plays to2.718s and seeks to8.962s. Cancelled deletion
  retains the recording; confirmed deletion leaves the verified shell ready.
- Published privacy disclosures pass three languages,320px/200% text and
  no-JavaScript anchors, without automatically requesting the portfolio site.
  The owner-intended all-age audience is disclosed, not certified as Families
  or legal compliance merely by these UI checks.
- The exact published content manifest matches source. All44 complete hosted
  Tafsir/translation gzip-file bodies match their canonical sizes and SHA256.
  A HEAD-only check initially assumed Content-Length was present; some CDN
  responses omit it. The full-body audit resolves that test assumption without
  changing CDN/security settings or weakening integrity checks.
- Actual Home/Settings creator credits pass in all three public interfaces:
  no automatic portfolio request, cancellation/Escape closure and a confirmed
  popup reaching exactly HTTPS yahyazlab.com. Lazy off-screen Settings controls
  and dialog exit animations are handled by the test, not changed in the app.
- Production AAB15:185218071 bytes, SHA256
  `6832d13c35ac3b53455e2c8c346ffe77d623d2911f865b77c2478310a34cc4dd`.
  Its actual public certificate fingerprint matches the authorized RSA3072
  upload certificate documented in RELEASE.md. All12 native libraries pass
  ELF alignment checks; the bundle config requests PAGE_ALIGNMENT_16K.
  Google's official bundletool1.18.3 validation passes, package is
  org.quranflutter.quran_flutter, minSDK24/targetSDK36. JAR verification passes
  with a self-signed/no-timestamp and archive-order diagnostic; these are
  retained rather than silently hidden. This is not Google review approval.
- After specific owner confirmation of policy/export declarations, created
  only Quran Haven in the YahyazLab account (app4972735598475155183). A separate
  action-time owner approval confirms Google-managed Play App Signing and the
  bundle upload. The processed artifact15(1.0.0),mapping/native symbols and
  ar/en-US/es-ES release notes are saved in production draft1. No private key
  or signing password was uploaded. Store setup/review submission remains open.
- The Google Play Dashboard now confirms9/11 initial setup tasks complete.
  Privacy/access/no-ads/government/financial/health disclosures, IARC and
  category/contact are saved. Store text is saved in en-US/ar/es-ES with eight
  genuine1080×1920 final native captures per language. Each order begins with
  reader/Home/guide; no screenshot of an untested physical/tablet/iOS device is
  fabricated. The icon and feature graphic's AI labels are retained.
- The saved IARC results are ClassInd All ages, ESRB Teen, PEGI3, USK12+ and
  Generic/Russia/South Korea3+. Textual references in bundled/downloadable
  resources were disclosed, without claiming visual scenes. One downloaded
  Tafsir explicitly discusses prohibited intoxicating substances; raw keyword
  matches in other texts also refer to ordinary grass or seclusion and are not
  indiscriminately classified as drug content. Target audience is not silently
  changed to fit the results; an owner decision is pending. Data Safety and
  actual Google review submission are still open. No forced shutdown occurred.
- A read-only check of the project's existing Cloudflare HTTP request dashboard
  confirms IP/country/client-software and traffic statistics. No Cloudflare
  setting was changed. Data Safety is saved as a draft for those optional
  request-data practices (IP identifiers/resource interactions and IP-derived
  approximate country), not falsely marked zero collection because personal
  progress is local. Google blocks final submission until Target audience is
  completed. No GPS, native analytics SDK, remote personal notes, automatic
  90-day deletion or unimplemented remote deletion mechanism is claimed.
- The policy request-metadata clarification is available in all three source
  languages, dated2026-10-15. Local320px/200% and no-JavaScript audience/network
  checks pass, as do27 multi-engine/language/navigation rows and21 focused
  320px/200%-text rows. All25 retained native phone PNGs have originalRGBA
  1080×1920 dimensions and are below8MB;24 are used across the store locales.
  All18 offline/server tests pass after regenerating the756-file
  local shell (145231951bytes, identity prefix42a10e282f42). The new policy
  deployment/public recheck is still pending at this entry.

## Final candidate rechecks — 2026-10-15 (pre-publish history)

- All 39 original H264 videos (13 topics × ar/en/es) play, pause, seek and replay
  in isolated official Chrome. All 39 also pass those operations in a new page
  after complete verified preparation and forced offline mode. The strict
  offline console gate found a remote Noto Sans Symbols fallback retry; that
  font is being bundled before final acceptance, not ignored as a success.
- The candidate `c8baa3a474f905fd837aa165b6dc05b891c6d4b3be0232189e6922b8ce0f2642`
  contains 754 files / 144835713 bytes. Development-server HTTP response faults
  were isolated using an independent loopback transport of these same files;
  it completes full preparation. No worker integrity checks or budgets were
  weakened. The final font/poster/policy/metadata rebuild will have a new identity.
- Chromium/Firefox/WebKit each pass ar/en/es × desktop/tablet/phone main-screen
  navigation on this candidate. These engine tests are not physical Safari/iOS.
- Real notes/collections CRUD, JSON export, invalid-input rejection, cancelled
  restore, safety copy and full replacement/reload pass again in all languages.
  Reader bounds/search, all five display modes, saved translation removal,
  Khatmah/memorization, complete Ayah PNG/link, late-Surah whole-book search,
  Corpus navigation and actual Tafsir/translation text pass the final rechecks.
- The saved Al-Fatihah browser recording retains its exact 669781-byte hash,
  survives reload/cold offline playback and seeking, and removal leaves the
  verified app shell intact. Downloading does not autoplay.
- Independent design round 2 passes the inspected UI/media: all 39 posters and
  318 caption states inspected, three-language real seeking, bounded zoom,
  desktop→phone single-decoder reflow, 320px/200% privacy, genuine blocked-video
  Retry recovery. This used a same-provider independent evaluator, not an
  external-provider certification. Two optional poster/header polish changes
  are being applied separately; offline/native/store gates are not implied.
- All 254 Flutter tests pass before the final native-notification fix; its four
  focused selection/metadata tests also pass. All 32 worker/audio Node tests
  and 18 manifest/loopback-server Python tests pass. Analyzer has only the three
  existing vendored cacheExtent informational deprecations (no errors/warnings).
- New all-media test APK15 is 179.2MB, SHA256
  `6927601c8765306d9e3b26cd50706c4f7738fde99d0530a728266af430d25fd2`,
  signed by the same debug certificate as build6. It upgrades the separate AVD
  without erasing page2 and its test records. Selected Al-Fatihah plays even
  after a prior Al-Baqarah selection; background media pause/resume pass. The
  stale notification title found during that real test is fixed in source and
  must still pass on the rebuilt APK. Real Surah114 download completes without
  autoplay and restores enabled controls; final cold-offline/native checks remain.

Final pre-publish recheck after the fixes:

- The original Noto Sans Symbols font/OFL is now local. All 39 finalized lessons
  pass cold-offline play/pause/seek/replay with zero page/console errors and no
  remote font failures. Final clean shell: 756 files / 145228106 bytes, identity
  `9adec8673552db70a27af839660d83d27537a926cfa31039920bc3fe76a0cc89`.
- An incremental local compiler cache omitted newly added web plugins from the
  generated JavaScript despite a correct registrant. The cache was moved to a
  recoverable task-specific backup on E:, and a clean build restored actual
  video/file/url plugin code. This failure is not accepted as a successful build.
  Fresh-source container builds and actual browser playback remain release gates.
- The worker now makes at most one retry for a network/stream TypeError, under
  the same total 60-second file deadline. Redirect/opaque/HTTP/size/hash/quota
  failures and cancellation remain strict. Both transient recovery and a second
  failure's bounded cleanup have tests; all 34 worker/audio tests pass.
- All 261 final Flutter tests pass, plus 18 offline/server and 23 deployment/
  content/Android-resource Python tests. Analysis still has only three existing
  informational deprecations.
- Corrected test APK SHA256:
  `2e80be6bd0bfa723d6864ff7d91b8bf194c22956ba8e9b9496f5116f14bef9a2`.
  After an actual cold start with Android reporting `Active default network:
  none`, cached Al-Fatihah plays, the native metadata title is correct, and
  background pause/resume advance actual positions. Page2 and prior test records
  survive the update. A real bundled Arabic video completes 00:30/00:30 offline.
  UI automation cannot capture an idle tree during its continuous animation;
  that diagnostic failure is retained, not a claim of a playback failure.

At the time of these local candidate checks the website was still build13.
The public build15 results are recorded above; neither section claims Google
Play approval, physical-device acceptance or iOS publication.

## Local release15 acceptance — 2026-10-14 (historical candidates)

This section records earlier development candidates, not their later publication.
At that time the live website was build13. The current public build15 and
Google Play setup evidence are recorded above; the store is not yet in review.

- Original Corpus bytes/source notices retained. Actual morphology navigation,
  indexed first/last Ayahs, raw feature text and source/license controls pass in
  Arabic, English and Spanish after explicit selectable-text semantics were
  added. Existing unaudited Qiraat/word-meaning data remains disabled.
- Actual browser Surah download saved Al-Fatihah/Abdul Basit (669781bytes,
  SHA-256 `7adec6166f88c6a8ade3b28e74764c8baa6a145365299ce28c0de4eb983c904f`)
  without autoplay. Reload playback used a local Blob, advanced from2.086s to
  3.692s, and a new offline page played to2.585s and sought to8.969s. Cancelled
  removal preserved the recording; confirmed removal left the offline shell
  ready. No personal-data API requests or page exceptions occurred.
- A fresh locked web build includes the required video/file/url web-plugin
  registrations. An earlier incremental candidate omitted those registrations;
  its generic video failure is not accepted as a successful media test.
- The fresh candidate shell contains681files/107098326bytes, identity
  `f02ba20b9b804144a0a912438ccf9cddbdaf7d0f91bc282bc37194a4d3152b02`.
  Real Arabic H264 lesson playback in isolated official Chrome reached1.771s,
  paused, replayed, then worked in a new offline page after full preparation:
  2.629s playback,13.498s seek and1.777s replay. One preparation attempt failed
  with `download_failed`; the fresh rerun completed all681files. The UI reported
  the failure honestly. Complete finalized39-lesson and public rechecks remain.
- Strict worker tests validate full-file hash before MP4 Range slicing, reject
  malformed/out-of-range/multiple ranges and preserve non-video behavior.
  Privacy HTML has an exact binary transport like the app index so CDN markup
  cannot break offline integrity. All32worker/audio Node tests and17manifest/
  loopback-server Python tests pass.
- Owner-approved `admin@yahyazlab.com` appears in source Settings/policy. The
  static privacy document passes27isolated browser result rows, narrow320px,
  language query/history, keyboard, print,200%zoom and no-JavaScript anchors.
  Website Cloudflare beacon is disclosed; no privacy/security settings changed.
- The new icon/feature master checks pass33PNGs,15unique iOS sizes and five
  Android adaptive safe zones. Independent combined design review is pending.
- Android test APK15 compiled successfully (143.2MB). Its debug certificate
  matches the existing build6 certificate, not the new production upload key.
  The old shared Pixel_10 AVD refused upgrade with insufficient storage; no
  application/data was removed. A separate Quran_Haven_Test AVD was created for
  clean installation and upgrade acceptance. Final media/store bundle checks
  remain open.
- Local production upload-key creation was explicitly authorized by the owner;
  the private folder is outside the repository and `android/key.properties` is
  ignored. See RELEASE.md for the public certificate fingerprint. No key/password
  was sent to GitHub/Google, and no Play app has been created or uploaded yet.
- The separate emulator passes the actual in-place6→15 upgrade: Spanish UI,
  last-read page2 and a paused30-day Khatmah with21completed pages remain.
  The shared old AVD is unchanged. Only the newly created test AVD was moved
  recoverably to `E:\Quran Haven Test` after exporting its test records; the
  project and private signing folder remain in Documents.
- Android's real document chooser saved a627-byte JSON backup. Import preview
  cancellation preserved a newer test note. Cancelling the safety-copy chooser
  kept Replace disabled; saving the856-byte safety copy (including that note)
  enabled replacement. Restoring the original copy refreshed native views and
  retained page2/the paused21-page plan while removing the newer note. These
  are isolated test records, not the owner's shared emulator data.
- Android saved a real743×400PNG for2:1 through its document chooser,16441bytes,
  SHA-256 `d742c16e946e0e3bb96ea25a97c73d0c94dc07e0b5e6c3c3343ddc8577f10de6`.
  The complete Ayah/reference/source footer was visually checked. A native
  collection also retained that Ayah without cloud requests.
- Denied notification permission leaves reminders off. After owner-scoped test
  permission, real Spanish19:00→19:15, English7:15PM→7:20PM and Arabic7:20م→7:25م
  input transitions succeed. Android's scheduled alarms match19:15/19:25;
  disabling removes the active app RTC alarm. This proves scheduling, not
  physical-phone delivery. The Spanish12/24-hour dialog mismatch discovered
  during recording was fixed; its failed raw clip is not included in lessons.
- All205Flutter tests excluding unfinished media assets pass after reminder,
  guide zoom/reflow and native restore-dialog fixes. Eleven new native audio
  storage tests and six Library caller/cancellation tests pass separately.
  The final combined suite remains to run after all39media files are installed.
- Actual Android testing found the old Library download path could autoplay,
  await playback completion and use the previous listening Surah. A separate
  download-only API now captures the selected reader/Surah, validates bounded
  MP3/length bytes, cleans only its own temporary file and never touches a
  player. Cancellation cannot report success. Revised native runtime acceptance
  is in progress; these source tests alone do not close that gate.

## Current web acceptance — 2026-10-12, build 13

The current application is local-only. Historical cloud sections below describe
past releases, not active product requirements. This is acceptance of implemented
web features; product backlog and physical/store gates are not declared complete.

- Source `dc0df929a8a406445589d5bd7eb034658fa2434f` published through Coolify
  **Quran Haven** resource `xt9b22auyjtr8m32snvgsxl3`. Deployment
  `oeyjmjpunbx9d9ckfbcaqykn` succeeded in 3m 42s. No Cloud resource, server
  records, DNS, CDN security/privacy settings or user browser data was changed.
- Public version is **1.0.0+13**. HTTPS app/content checks and safe 404s pass.
  Public shell: **691 files, 100,967,708 bytes**, identity
  `e61c8189e9983d497568afe954ffed1e4d24d743d81fe729889c23a3fec32b18`.
  Main JavaScript SHA-256:
  `0029fdf6ca61818a6bc84b37c34da1ad58a65d0f4a3c703835262ed6211d0db9`.
  Release-keyed bootstrap/main/version bytes, worker stamp and binary HTML hash
  match the public manifest. Local/container content-derived identities differ
  as expected.
- **103 Flutter tests, 14 offline/server Python tests and 22 actual-worker/bridge
  Node tests pass.** Analysis has no errors/warnings, with three existing
  vendored `cacheExtent` deprecation information notices. Standard JavaScript
  compilation succeeds; Wasm remains unsupported by existing `get_storage`.
- Actual public browser matrix: Chromium/Firefox/WebKit × English/Arabic/Spanish
  × 1440×900/768×1024/375×812. The five main screens and guide navigation pass;
  no page exceptions, app console errors or personal-data API requests occurred.
  Headless WebKit sometimes captured a white image after repeated viewport
  resizing despite live semantics; cold 375px contexts rendered correctly in
  all three languages and were inspected separately. This does not certify
  real Safari/iOS or physical rotation/accessibility behavior.
- Public reader checks pass page 0/605 rejection, last/first-page navigation,
  empty and Arabic search (55 results for الرحمن), bookmark save/reload and
  Escape/Close dismissal. All five display modes render without page errors.
  The selected Arabic Tafsir opens with localized English Tafsir/Tajwid labels.
  Build 13 adds three loading/error/content regression tests: waiting never
  appears as an empty ready panel, and failed loads use localized feedback.
- Downloaded Spanish text remains available after reload. Its Delete control
  opens the confirmation dialog; Cancel keeps it, confirmation removes it and
  makes Download available again. Resource semantics no longer merge deletion
  with the selected-resource chip.
- Public Khatmah flow passes 60-day creation, 11-page daily target, pause/resume,
  invalid/123-page adjustments, target-date change, reload and deletion
  cancellation/confirmation. Memorization passes actual Surah bounds, reversed
  range validation, repetitions/delay settings, hide/reveal, revision marker,
  mark memorized, range navigation bounds, Mushaf jump and persisted 50% progress.
- Rejected plan writes do not create a false saved plan or a page exception.
  Rejected preference writes display the warning in the newly selected language;
  reload retains the last durable language. Read failures have a non-overwriting
  retry path tested in Flutter. Fault injection was limited to isolated fixtures.
- Real public Surah audio advances **2.003488 → 3.517631 seconds**, readyState 4,
  paused=false, provider HTTP 206. Real word-by-word current/range playback and
  Stop work; no stray playback remains after Stop/navigation. Audio was not
  mocked. All **29 Surah / 20 Ayah profiles** pass bounded first/last MP3 samples
  (98 checks); all **44 hosted text resources** pass exact byte/hash/JSON checks.
  Eight added MP3Quran reciters now use current provider CDN roots while keeping
  their IDs, indexes and local download directories unchanged.
- Guide acceptance passes all three languages, eight topics, no autoplay,
  play/stop, enlarged zoom/reset/Escape, reduced motion, mobile views and all
  **24 GIF/poster hashes**. No support/donation/account controls are present.
- A real isolated public Chromium profile upgrades **11 → 12**. Its old release
  was fully cached; new release preparation retained the old active cache.
  Activation returned `other_tabs_open` while both readers were open. After
  closing the old tab, explicit activation/reload retained Spanish, page 49,
  one yellow bookmark, paused 21/604 Khatmah progress and downloaded Spanish
  text. With the entire browser context offline, the new app, Mushaf and guide
  reopened successfully from the verified 691-file shell.
- The user's existing Chrome tab was refreshed normally and shows the updated
  website. No storage/cache clearing or browser/security setting changes were
  performed. Test contexts were synthetic and separate from user data.

### Remaining scope and limitations

Personal notes, arbitrary named bookmark categories, Ayah-image/deep-link sharing,
full Tafsir/translation search, local export/import, browser offline audio and
grammar teaching remain product backlog, not completed features. Unaudited
Qiraat/grammar download shortcuts are hidden; the agreed Hafs Mushaf and
word-by-word memorization audio remain available. Physical Android/iOS/Safari,
screen-reader/rotation/interruption checks, production signing/store accounts,
macOS/Xcode and approved privacy contact/disclosures remain release gates.
Browser storage can be denied/evicted and external audio providers can change;
these checks are not a universal or permanent zero-defect guarantee. Existing
remote cloud records/service remain untouched pending an owner retirement decision.


## Public deployment completed and Android audio repair — 2026-10-12

This supersedes the pending public/native acceptance statements in the build-7
preparation section below. Website build 7 and Android test build 8 are separate
artifacts; no build-8 public website deployment is claimed.

- Windows Computer Use selected the correct **Quran Haven** website resource
  `xt9b22auyjtr8m32snvgsxl3` in Coolify and redeployed `785ef16`. Deployment
  `h1suf8wgekbyzu9hvk21pfse` finished successfully in 3m 37s. The failed
  `/backend/compose.yaml` attempts belonged to **Quran Haven Cloud**, not this
  website. The obsolete Cloud service/data was not changed, stopped or deleted.
- Public HTTPS version reports build 7. App/content smoke checks pass. The
  public shell has 691 files and 100,959,802 bytes, identity
  `1bbdf92fc21c7f38717ff3a6ca0e3f0592b126d9e94ac033b9eb022e4f97661b`.
- Actual public browser tests pass Surah/Juz navigation, Arabic search (55
  results), page-49 persistence for the wide spread, saved Spanish translation,
  Khatmah completion/pause, memorization creation and offline full reload/reader
  rendering in Arabic, English and Spanish. No personal-data API request or
  page error occurred. The same isolated context reuses the prepared shell
  across the language checks; no user's browser data was cleared.
- A public yellow Ayah bookmark survives reload; expanded-bookmark Escape and
  close controls work. The selected Arabic Tafsir displays with English Tafsir
  and Tajwid labels. Real browser audio is not mocked: paused=false, readyState
  4, advancing from 2.024442 to 3.539463 seconds, provider HTTP 206, no page error.
- The guide opens in the existing user Chrome session, plays/stops its actual
  GIF and opens the enlarged viewer. Independent public checks in English,
  Arabic and Spanish verify eight topics, no autoplay, play/stop, zoom
  reset/Escape, 375px screenshots, reduced motion and all 24 media hashes.
- Android build 8: `Quran Haven - test build 8.apk`, 147,718,648 bytes, SHA-256
  `a7f198e5724a2d9457465aa7678b4f7677d606d234ddf776f75b520cae55f242`.
  VersionCode 8, original app ID, Android Debug certificate and disabled
  automatic backup verified. Previous delivery APKs were preserved.
- Dedicated API-37 x86_64 emulator upgraded build 6 → 7 → 8 without uninstall
  or data clearing. Spanish, last-read page 2, paused 21/604 Khatmah progress,
  guide controls and offline Mushaf restart remain available. Downloaded
  Al-Fatihah plays in airplane mode after the upgrade.
- Build 7 had a native CustomAction exception because resource shrinking
  removed `audio_service_*` icons. Build 8 keeps these drawables; the compiled
  APK contains all seven standard controls. On the emulator, media state is
  PLAYING in the background, PAUSED at 7,101ms via the media key, then PLAYING
  at the same position after resume. These are emulator state checks, not an
  assessment of physical speaker sound or real lock-screen/interruption UX.
- The test-only startup harness initially sampled before audio was ready and
  later selected the automatically advanced, undownloaded next Surah. Final
  bounded checks explicitly used the retained Al-Fatihah download and observed
  the media states above; those harness failures are not counted as passes.
- Re-run: 94 Flutter tests and 23 content/deployment Python tests pass,
  including a new resource-retention regression guard. Local build-8 web shell
  has 691 files/100,959,899 bytes, identity prefix `0f4ea75950c1`; its JavaScript
  is unchanged from build 7. This local artifact is not the public website.
- Exact public `main.dart.js` SHA-256 matches the tested local JavaScript:
  `d6a4494bbb3bfdd093a606a83fdefcfd8a752eb4f9c7b917c404b241b117ba4f`.

Physical Android/iOS, denied permissions, reminder delivery, wider browser
storage/assistive-technology acceptance, owner signing and privacy approval
remain open. No production signing key or new account was created.

## Publication, Android repair and usage guide — 2026-10-12 (build 7)

This section supersedes the unpushed/build-blocked status recorded on 2026-10-01.
The local-only source was pushed as `a61dbbe`; the owner triggered the public
Quran Haven deployment. HTTPS now reports build 6, exact `main.dart.js` matches
the build-6 hash below, and app/content smoke checks pass. No remote cloud service
or existing user record was stopped, inspected or deleted.

Build 7 is prepared locally with eight guide topics, 12 real-screen GIFs and 12
PNG posters in Arabic, English and Spanish. Written steps distinguish browser
and native limitations. Media is local, static by default, explicitly played,
zoomable and disabled when reduced motion is requested.

- 94 Flutter tests, 22 content/deployment Python tests, 13 offline/server Python
  tests and 21 real-worker/bridge Node tests passed. All 1,161 public Quran files
  pass integrity checks; text/font/resource bytes are unchanged.
- Analysis: no errors/warnings; the same three vendored `cacheExtent` notices.
- Final JavaScript build passed. `main.dart.js` SHA-256:
  `d6a4494bbb3bfdd093a606a83fdefcfd8a752eb4f9c7b917c404b241b117ba4f`.
  Local shell: 691 files, 100,959,899 bytes, identity prefix `fc4ff3214737`.
- Real independent Chrome tests passed reader navigation, Arabic `الرحمن`
  search (55 results), downloaded Spanish translation, Khatmah creation/daily
  completion/pause, memorization creation, and full offline app reload/reader
  rendering in all three interface languages. The wide two-page reader retains
  page 49 for the 49/50 spread selected through Aal-Imran. No account API request
  or page error was observed in these tests.
- A yellow Ayah bookmark survives reload; named actions, close control and
  Escape after expanding a bookmark group work. Arabic Tafsir content renders;
  its interface tabs now follow the app language.
- On the public build-6 site, real Surah playback was verified: the HTML media
  element was playing, readyState 4, and time advanced from 2.007863 to 3.522889
  seconds. The provider returned HTTP 206; no page errors occurred.
- Public build-6 offline preparation exposed a stale CDN MaterialIcons font:
  22,308 bytes delivered versus 21,432 bytes required. A fixed release query
  returned the correct file/hash. Build 7 uses release-isolated requests and
  revalidation, with bounded three-file downloads and settled cancellation.
- Independent guide evaluation passed at 1440, 768 and 375 px in all languages,
  including explicit playback, enlarged viewer, Escape and reduced motion. The
  evaluator was independent but same-provider; no external-provider audit is
  claimed. Supplemental dark-mode evaluation was inconclusive, not a pass.
- Android build repaired using scoped `jdk.net.unixdomain.tmpdir` under ignored
  `android/.gradle`. Windows long TEMP paths caused Java's local pipe failure.
  No global SDK/Java/network setting was changed.
- Delivery APK: `Quran Haven - test build 7.apk`, 147,697,744 bytes, SHA-256
  `d9ccac7d04eead24b8d7003463de2ede0ea61d0847f49e6d56261f759456e910`.
  VersionCode 7, same app ID, Android Debug certificate, and disabled automatic
  backup verified. This is not a store-signed package.

The build-7 public deployment and native in-place upgrade checks are still being
completed. A first update attempt on the existing Pixel 10 emulator failed due
to insufficient storage (541 MiB free). Its existing fixtures/data were preserved;
a separate roomier test emulator is being used. Physical Android/iOS, store
signing, privacy contact and wider storage/assistive-technology checks remain open.

## Local-only update — 2026-10-01 (build 6)

This supersedes historical cloud-client details below. Accounts, sign-in,
cloud backup/restore, auth/session storage and personal-data API configuration
were removed. Local preference/progress keys and Android app identity are kept.
The obsolete backend source is removed; its history remains recoverable. No
remote service was stopped and no existing server user data was deleted.

- 68 Flutter tests passed, including legacy preferences, local plan/reminder
  persistence, localized Settings without account forms and cloud-client guards.
- 22 content/deployment Python tests, 13 offline Python tests and 17 worker tests
  passed. Public integrity verification passed for all 1,161 files, including
  114 Surahs, 6,236 Ayahs, 604 page fonts and 44 Tafsir/translation resources.
- Analyzer: no errors/warnings; three pre-existing vendored `cacheExtent`
  deprecation informational notices remain.
- JavaScript web build passed; build number 6. `main.dart.js` contains no
  `api.quranhaven.org`, `QURAN_API_URL` or removed account-client symbols.
  SHA-256: `185d989531e2955fceb44bb1f926f8a2ccd21649738b6853163d3fb81e58c7a8`.
- Offline preparation: 667 files, 97,701,487 bytes; release `bab0224613f9`.
  WebAssembly is not supported by the existing `get_storage` implementation;
  this artifact is the supported JavaScript build.

- A new Android APK was not produced: Gradle/Java fails before compilation with
  `Unable to establish loopback connection` (`Invalid argument: connect` in
  Java's local pipe/selector implementation). Scoped IPv4 and traditional
  selector attempts did not resolve it. No system network settings were changed;
  process-only Java/test-signing overrides were restored. Existing test APKs
  remain untouched and do not contain this local-only update.

This update has not been pushed or deployed to the public website. Physical
device upgrade, browser quota/eviction and iOS acceptance remain outstanding.
Uninstalling or clearing local app/site data can erase saved progress; no remote
recovery or local file export/import is available.

## Plan-audit release (build 4)

This section supersedes the build-3 source counts below. Earlier deployment and
browser-outage results are preserved as dated historical evidence, not repeated
claims about the new artifact. See [the audited plan](../PLAN.md).

- Web source `5799d7964448050e59744d2085d29ef624d1542c` deployed successfully in
  `7qvypq0wqzqh3uycjmttsq79`. The new container was healthy and its rolling update
  completed at 14:38:24 UTC. The backend was not redeployed or reconfigured.
- Public version reports build 4. Public offline manifest has 667 files,
  97,770,794 bytes and identity
  `a147f20c8ba116280d3103ced11da68fa2de02bda30b767d88d5eb9116782ea0`.
  Exact public hashes passed for the Bengali font, unchanged OFL license,
  `main.dart.js` and `AssetManifest.bin`; app/content smoke checks also passed.
- Final delivery APK: `Quran Haven - test build 4.apk` in the project root,
  144,430,318 bytes; SHA-256
  `c0e4c0f5c17e81e73d54d8be39cc7c7648e61d2ebfa90b72f444874d2fef06bf`.
  VersionCode 4, Quran Haven label, INTERNET permission and Android Debug
  certificate verified. Previous delivery APKs were preserved, not overwritten.

- 81 Flutter tests passed, including bookmark payload validation, restore
  preflight, persistence-failure handling, legacy backup compatibility, all 44
  catalogue/file-format checks and Home layouts at 360 px / 2x text in three
  interface languages.
- 74 isolated backend tests, 22 content/website tests, 13 offline/server Python
  tests and 17 actual-worker/bridge JavaScript tests passed.
- Analysis reports only the same three vendored `cacheExtent` deprecation
  notices; no new errors or warnings. JavaScript web compilation is supported;
  the existing `get_storage` Wasm limitation remains.
- Production-configured JavaScript web build passed. Local offline manifest:
  667 files, 97,770,891 bytes, release prefix `2370b4527428`. Bengali font and OFL
  are bundled; all Quran content and page-font bytes remain unchanged.
- In the local real browser, Home Search opened Search directly and Arabic
  `الرحمن` returned 55 results. Home Bookmarks opened its own tab directly.
  The final Library displayed commentary under Tafsir and only the nine
  translation entries under Translations. Settings opened the license page.
- A temporary read-only Pixel 10 Android emulator installed the test APK, with
  airplane mode on, Wi-Fi off and mobile data off. Al-Fatihah rendered visually;
  Browse Surahs opened its index and Al-Baqarah opened page 2. After force-stop
  and restart, Home reported Last read · Page 2. This is emulator evidence, not
  physical Android/iOS acceptance. This exercise preceded the final two
  label-only corrections; the final APK was rebuilt and all 81 tests rerun.
  The temporary emulator was stopped afterward.
- Live API checks passed with two synthetic accounts: a bookmark-containing
  snapshot round-tripped exactly, accounts remained isolated, deletion rejected
  old tokens and login. Only the two test accounts were deleted; no real account
  was inspected or changed.
- A release-task dry run with test signing disabled refused missing private
  signing configuration as intended. Explicit test signing built successfully;
  its certificate is Android Debug, not an owner production certificate.
- Private Android keys, email credentials, backup destinations and CDN settings
  were not invented, changed or published. Physical-device and owner-dependent
  release gates remain open in [RELEASE.md](RELEASE.md).
- Git whitespace checking passes outside the unchanged upstream OFL file,
  which intentionally retains its original trailing space and exact hash.

## Cloud-connected release

- Backend `6e4a005` is healthy at `https://api.quranhaven.org`.
- Website `1abd51d12cef83f6658f1e62761ac3487e179b23` deployed successfully in
  `mo3sjv52zryoj2bfa1c7rldm`; the replacement container was healthy and the
  rolling update completed at 12:32:12 UTC.
- HTTPS API and content smoke checks passed. The public version reports build 3
  and the JavaScript contains the production API address.
- An independent in-app browser displays optional Sign in/Create account.
  The existing Chrome session still showed an older cached app. Cloudflare
  cache controls were not changed; a permission request was raised.
- Build-3 APK contains INTERNET permission, versionCode 3 and Quran Haven label.
  Size 143339670 bytes; SHA-256
  `0689af9fd40feda81c8aa47147a2b7721d49b8a38ad6c1046707007d96838b16`.
  The matching delivery copy is
  `C:\Users\ThaherTech\Documents\Quran Flutter\Quran Haven - test.apk`.

## Offline/accessibility source release

- 69 Flutter tests pass, including all 44 resource integrity/JSON checks and
  account/plan/offline-control regressions.
- 7 offline-manifest generator tests, 17 actual-worker/bridge tests and 6 local
  test-server checks pass.
- 74 backend tests and 22 content/website utility tests pass.
- Integrated JavaScript release build succeeds with production content/API URLs.
- Generated offline manifest: 665 files, 97185385 bytes. All 604 Mushaf page
  fonts, core Quran JSON, bundled Tafsir and local renderer assets are required.
- Analysis has no new diagnostics; three existing vendored `cacheExtent`
  deprecation notices remain. Existing `get_storage` prevents Wasm compilation;
  the standard JavaScript release is supported.

## Public offline assets

- Public manifest release identity:
  `f5bcdc5aa0a4c5aa3b74d6656910374997259f8b98875a3bf85b683ab538bb4b`.
- Public manifest contains 665 files, 97185288 bytes. Local and container builds
  have separate content-derived identities; this is expected.
- Worker/bootstrap release stamps match the public manifest. Exact size/hash
  checks passed for HTML transported through `offline-index.bin`, bootstrap,
  main JavaScript, `AssetManifest.bin` and the first Mushaf page font.
- Existing Cloudflare HTML analytics injection changed online index bytes.
  Binary HTML transport fixes offline integrity without changing CDN settings.
- Existing public browser sessions could retain an older app bundle. No
  Cloudflare cache purge was performed: scoped approval remains pending.

## Real browser outage check

- Built and stamped the production-configured app locally, then served it only
  on `127.0.0.1:8087` using `deployment/serve_web.py` with correct Windows MIME
  types and `Cache-Control: no-store`.
- In an independent in-app browser, explicit preparation reached **Ready for
  offline reading**, showing 92.7 / 92.7 MB saved.
- Stopped the exact temporary server process and confirmed TCP connections to
  its port failed. Navigated to `/index.html` to restart the application.
- Home and Settings reopened from saved files. Settings retained Ready status;
  the Mushaf displayed Al-Fatihah and the beginning of Al-Baqarah, including
  their correct page fonts, verified visually.
- Downloaded the Spanish translation from the production content service in
  that local browser. After another full app restart it remained selected and
  removable, confirming persistent optional-resource availability across reload.
- This checks an app-server outage in a real browser, not physical airplane
  mode: the machine's connection to other hosts remained available. Real
  Android/iOS devices and wider browser/storage-eviction acceptance remain.

## Public-release prerequisites

Still need the owner's recovery-email provider/sender, private off-server backup
destination/retention, privacy contact, final signing ownership and store accounts.
No production signing key, recovery-email service or off-server backup was
invented or configured. The APK is test-signed; iOS release needs macOS/Xcode.
Final privacy disclosures must also account for the existing CDN analytics.
