# Connected/offline release verification — 2026-09-07

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
