# Content independence verification

Verified locally on 7 September 2026. The working project is
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
- Content preparation/integrity tests: 9 passed.
- Full manifest verification: passed in the working project.
- Public-only verification used by the Docker build: passed independently.
- Flutter analysis: no errors or warnings; three existing upstream deprecation
  informational messages remain for `cacheExtent`.
- Standard JavaScript web release: built successfully with bundled web renderer
  resources. WebAssembly is not supported by the current storage dependency.
- Android release APK: built successfully. SHA-256:
  `350C828AA89FF91F73E9D9CC110463EC260D1B7D2596ABF8F00F10F2DB59C114`.
- Playwright browser test blocked all non-local HTTP(S) traffic: settings had no
  donation section; a Spanish translation downloaded from the local content
  server with HTTP 200; the Mushaf rendered; mobile and Arabic settings worked.
  No requests to the King Fahd, GitHub, or GitLab content hosts were attempted.

## Not yet completed / limitations

- No Coolify service was created or published. The production content domain and
  deployment access have not been supplied. The APK and portable web build have
  no content URL; they do not contain a localhost address.
- The container image was not built here because Docker was unavailable. Verify
  the actual image and HTTPS/CORS behavior during deployment, including access
  from outside Saudi Arabia. Local retrieval does not establish the scope or
  cause of the reported geographic restriction.
- Audio providers are unchanged. This is not an audio recording mirror.
- Optional web downloads are memory-backed in the current library; persistent
  PWA offline resource caching remains future work.
- With every external host blocked, some library interface labels still request
  fallback fonts from Google and can display missing glyphs. Core Quran page
  fonts and the main application fonts are bundled. Complete interface-font
  coverage belongs in the accessibility/offline finishing work.
- Next-phase production/accessibility work has not begun: the requested content
  deployment and app connection come first.

## This Windows machine's Android build workaround

Java's internal Unix-domain wakeup socket failed on this host. A process-local
setting made it use its built-in TCP fallback. No global setting was changed:

```powershell
$env:JAVA_TOOL_OPTIONS = '-Djdk.net.unixdomain.tmpdir=C:/Users/ThaherTech/AppData/Local/Temp/quran-gradle-tcp-only'
flutter build apk --release
```

That specific temporary directory was verified absent before the build; do not
create it. This workaround is machine-specific, not an app runtime requirement.
When the content service is deployed, also pass the real `QURAN_CONTENT_URL`
shown in `README.md` and rebuild the app.
