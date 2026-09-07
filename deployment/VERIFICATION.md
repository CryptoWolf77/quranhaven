# Connected/offline release verification — 2026-09-07

## Cloud-connected release

- Backend `6e4a005` is healthy at `https://api.quranhaven.org`.
- Website `cb635801d1abc8180165d4f7d72fe1e4435552f9` deployed successfully in
  `9zuchvpseuwzjap27sbluivm` at 12:04 UTC.
- HTTPS content smoke check passed. The public version reports build 2 and the
  JavaScript contains the production API address.
- An independent in-app browser displays optional Sign in/Create account.
  The existing Chrome session still showed an older cached app. Cloudflare
  cache controls were not changed; a permission request was raised.
- Build-2 APK contains INTERNET permission, versionCode 2 and Quran Haven label.
  Size 143339670 bytes; SHA-256
  `26435371a534bb82718dc78b0a0892e82b9bba355940b011ed7f0710a33bdcc1`.

## Offline/accessibility source release

- 69 Flutter tests pass, including all 44 resource integrity/JSON checks and
  account/plan/offline-control regressions.
- 6 offline-manifest generator tests and 16 actual-worker/bridge tests pass.
- Integrated JavaScript release build succeeds with production content/API URLs.
- Generated offline manifest: 665 files, 97185385 bytes. All 604 Mushaf page
  fonts, core Quran JSON, bundled Tafsir and local renderer assets are required.
- Analysis has no new diagnostics; three existing vendored `cacheExtent`
  deprecation notices remain. Existing `get_storage` prevents Wasm compilation;
  the standard JavaScript release is supported.

Browser offline acceptance and the build-3 deployment checks are recorded below
when run. Unit tests use browser API mocks, not a physical airplane-mode device.

## Public-release prerequisites

Still need the owner's recovery-email provider/sender, private off-server backup
destination/retention, privacy contact, final signing ownership and store accounts.
No production signing key, recovery-email service or off-server backup was
invented or configured. The APK is test-signed; iOS release needs macOS/Xcode.
