# Connected/offline release verification — 2026-09-07

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
