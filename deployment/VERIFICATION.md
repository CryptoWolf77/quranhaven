# Connected/offline release verification — 2026-09-07

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
