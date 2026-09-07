# Content independence verification

Verified locally and deployed on 7 September 2026. The working project is
`C:\Users\ThaherTech\Documents\Quran Flutter`.

## Completed

- Removed donation configuration, actions, and interface strings in Arabic,
  English, and Spanish. The project is free as Sadakah Jariyah.
- Preserved five official Hafs-related downloads and source/provenance records.
- Inventoried 1,161 served files, totaling 379,967,203 bytes before the manifest;
  the complete public directory is about 363 MiB.
- Verified file hashes, archive integrity, exact bundled-asset copies, 114 Surahs,
  6,236 Ayahs, and all 604 page fonts. This checks data structure and preservation,
  not scholarly approval of editions or translations.
- Verified 44 available Tafsir/translation files and five learning archives.
  The unavailable upstream Indonesian Jalalayn file is recorded and omitted.
- Implemented exclusive own-server routing for optional text resources. With no
  content URL, core reading still works and additional downloads are unavailable.

## Checks

- Flutter tests: 11 passed.
- Python tests: 22 passed (9 content integrity and 13 deployment checks).
- Full manifest verification: passed in the working project.
- Public-only verification used by the Docker build: passed independently.
- Flutter analysis: no errors or warnings; three existing upstream deprecation
  informational messages remain for `cacheExtent`.
- Standard JavaScript web release: built successfully with bundled web renderer
  resources. WebAssembly is not supported by the current storage dependency.
- Android release APK: built successfully with production content URL
  `https://quranhaven.org/v1/`. SHA-256:
  `53812DC507C123B81B1B75ACEB1B0D984D99CF834D0D11003D6180F9D366D1AA`.
- Playwright browser test blocked all non-local HTTP(S) traffic: settings had no
  donation section; a Spanish translation downloaded from the local content
  server with HTTP 200; the Mushaf rendered; mobile and Arabic settings worked.
  No requests to the King Fahd, GitHub, or GitLab content hosts were attempted.

## Production deployment

- Published application source and verified public content to
  `https://github.com/CryptoWolf77/quranhaven` on branch `main`.
- Created the Quran Haven application in its own Coolify project; unrelated
  applications and server proxy settings were preserved.
- The Linux Docker image built successfully in Coolify. All 1,161 content files
  passed verification inside the build. The container passed its `/health`
  check on port 8080 on the first attempt.
- Configured `quranhaven.org` and `www.quranhaven.org` in Cloudflare, with the
  proxy enabled and Full (strict) TLS. HTTP redirects to HTTPS.
- Production web and APK builds use `https://quranhaven.org/v1/`. No localhost
  content address is shipped. Core Quran reading remains bundled.
- Live manifest, Spanish translation and Tajweed sample match the verified
  originals after normal HTTP transport decompression. A `.json.gz` file still
  retains its own gzip layer for the app to decode.
- The full live smoke check passed, including app entry points, CORS, and 404
  responses for missing files and `.env`.
- Final application revision `28b202c12ef8ea089721ea7a628d38e6905ad144`
  deployed successfully at approximately 10:51 UTC. HTTPS `www` redirects to
  `https://quranhaven.org/`; the public title/description show Quran Haven.
  Final live smoke verification passed again at 10:52 UTC.
- Public DNS resolvers see the new records. During deployment this computer's
  default resolver retained an earlier negative response; per-request DNS
  overrides allowed HTTPS checks without weakening TLS or changing DNS settings.
- Live Chrome and in-app-browser rendering could not be verified on this
  computer because its default DNS resolver still returned `ERR_NAME_NOT_RESOLVED`.
  Public DNS (Cloudflare, Google, Quad9), certificate validation, server health,
  and independent live HTTP/content checks passed. Earlier local browser tests
  and current production web builds passed; this is not a claim of completed
  live browser testing from outside Saudi Arabia.

## Limitations

- These checks do not establish availability from every country or the scope
  and cause of the reported restriction on the original publisher's website.
- The account/synchronization backend is not connected in this deployment.
- Audio providers are unchanged. This is not an audio recording mirror.
- Optional web downloads are memory-backed in the current library; persistent
  PWA offline resource caching remains future work.
- With every external host blocked, some library interface labels still request
  fallback fonts from Google and can display missing glyphs. Core Quran page
  fonts and the main application fonts are bundled. Complete interface-font
  coverage belongs in the accessibility/offline finishing work.
- Further accessibility, persistent PWA downloads, account-server connection,
  and store-release work remain separate from this web/content deployment.

## This Windows machine's Android build workaround

Java's internal Unix-domain wakeup socket failed on this host. A process-local
setting made it use its built-in TCP fallback. No global setting was changed:

```powershell
$env:JAVA_TOOL_OPTIONS = '-Djdk.net.unixdomain.tmpdir=C:/Users/ThaherTech/AppData/Local/Temp/quran-gradle-tcp-only'
flutter build apk --release
```

That specific temporary directory was verified absent before the build; do not
create it. This workaround is machine-specific, not an app runtime requirement.
Production APK builds also pass
`--dart-define=QURAN_CONTENT_URL=https://quranhaven.org/v1/`.
