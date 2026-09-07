# Quran content for Coolify

This project is free for everyone as Sadakah Jariyah (صدقة جارية).

## What is preserved

- Five original Hafs-related downloads from the King Fahd Quran Developer Portal,
  retrieved on 7 September 2026. See `upstream/` and `provenance/quran-dev.html`.
- Official Uthmanic Hafs and Hafs Smart JSON/CSV data and fonts; the original
  archives also retain the publisher's other formats and readme files.
- Exact Quran text, navigation metadata, glyph/layout data, all 604 page fonts,
  and other bundled assets from `quran_library` 4.2.1.
- 44 available Tafsir/translation resources, five learning ZIPs, and 457 JSON
  files for word recitations, morphology, grammar, meanings, and Tajweed.
- Source attribution, upstream license notices, SHA-256 hashes and byte counts.

The King Fahd website is a source credit in the library, not a runtime API.
The app already reads core Quran data and fonts from its own assets. These
assets stay bundled: a server outage does not stop Quran reading.

Optional text resources originally came from the library publisher's GitHub and
GitLab releases. They are now mirrored here and routed exclusively through
`QURAN_CONTENT_URL`. No automatic fallback contacts the original hosts.
The upstream Indonesian `in-tafsir-jalalayn.json.gz` entry is unpublished (404 on
both hosts, absent from release and source inventories). It is omitted from the
app catalog and recorded in provenance; no other language was substituted.

Audio recordings remain on the existing recitation providers. This archive is
for text, metadata and fonts, not an audio mirror. Native devices retain their
downloaded text resources. The web library now saves optional resources in a
separate, verified browser cache (160 MiB maximum). Prepare the app and Quran
pages separately in Settings before offline use. Browser storage can be evicted;
see [offline reading](../deployment/OFFLINE.md).

## Verify before publishing

From the project folder, with Python 3.11 or later:

```sh
python content/download_optional.py
python content/prepare_content.py --package vendor/quran_library
python content/prepare_content.py --verify
```

Downloads are resumable by rerunning the script. Existing files are validated,
not fetched again. Quran text is copied byte-for-byte; only archive extraction
and gzip decoding for validation take place. The two official JSONs and bundled
core are checked for 6,236 Ayahs, 114 Surahs, and consistent verse numbering.
This structural check is not a scholarly review of Quran editions.

`public/v1/manifest.json` inventories the served files. Keep it together with
the corresponding `public/` directory. Keep `upstream/` and `provenance/` in a
separate backup; they are not exposed by the web server.

## Deploy to Coolify

For the production **quranhaven.org** deployment, use the project-root
`Dockerfile` and [deployment instructions](../deployment/README.md). That single
service hosts both the web application and `/v1/` content with no extra subdomain.
The instructions below remain available for a separate content-only service.

1. Copy the `content/` directory to your deployment repository or server.
2. In Coolify, create a Dockerfile application with build context `/content`
   and Dockerfile `/content/Dockerfile` (paths relative to the repository root).
3. Use container port **8080** and health check `/v1/manifest.json`.
4. Attach your chosen HTTPS content domain to that service.
5. Check `https://YOUR-CONTENT-DOMAIN/v1/manifest.json` and
   `/v1/tafsir/es.json.gz` from outside Saudi Arabia.
6. Build the app with the complete versioned root:

The Android release command requires private signing configuration, or the
explicit test-only flag described in [release gates](../deployment/RELEASE.md).

```sh
flutter build apk --release \
  --dart-define=QURAN_CONTENT_URL=https://YOUR-CONTENT-DOMAIN/v1/
flutter build web --no-web-resources-cdn \
  --dart-define=QURAN_CONTENT_URL=https://YOUR-CONTENT-DOMAIN/v1/
```

The account API can be configured independently with `QURAN_API_URL`. The content
server needs no database, secrets, user account, or connection to the Saudi site.
It serves public read-only files with CORS for the Flutter web app. TLS is handled
by Coolify. Preserve each `.gz` file's original bytes after HTTP transport
decoding, since Flutter decompresses the file itself. A proxy may add a separate
`Content-Encoding: gzip` layer around those bytes; it must not falsely label the
file's existing compression as HTTP encoding. The deployment smoke check tests
this distinction and verifies hashes after transport decoding.

For a local container, use `docker compose -f content/compose.yaml up --build`.
The compose port is bound only to localhost. The Docker service uses the official
unprivileged NGINX image; pin its tested image digest for your production release.

## Local development

```sh
python content/serve.py
flutter run -d web-server --web-port 8082 \
  --dart-define=QURAN_CONTENT_URL=http://127.0.0.1:8090/v1/
```

The Python preview binds to localhost. Use the Docker service in production.
Do not ship an APK with a localhost content address: that would refer to the
phone itself. Without a content URL, the app keeps bundled reading and existing
native downloads available and explains that extra resources are not connected.

## Sources and rights

- King Fahd Quran Developer Portal: https://qurancomplex.gov.sa/quran-dev/
- Quranic Universal Library by Tarteel: https://qul.tarteel.ai/
- Library: https://pub.dev/packages/quran_library/versions/4.2.1
- Optional text archive publisher: https://github.com/alheekmahlib/Islamic_database

The library's MIT code license is retained in `public/v1/core/LICENSE`; its
`NOTICE` explains that Quran fonts and third-party text resources keep their
respective upstream terms. Source credits remain in this free project.
