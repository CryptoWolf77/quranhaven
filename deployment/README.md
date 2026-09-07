# Quran Haven production deployment

The main Dockerfile serves the Flutter application at **https://quranhaven.org/**
and the verified public Quran content at **https://quranhaven.org/v1/** from one
read-only service. Every feature is free as Sadakah Jariyah, with no advertisements
or account requirements for Quran reading.

## Coolify configuration

Create one application in the existing Quran Haven project (do not replace any
unrelated services):

| Setting | Value |
| --- | --- |
| Repository | `https://github.com/CryptoWolf77/quranhaven.git` |
| Branch | `main` |
| Build pack | Dockerfile |
| Base directory / build context | `/` |
| Dockerfile | `/Dockerfile` |
| Container port | `8080` |
| Domain | `https://quranhaven.org` |
| Health check path | `/health` |
| Health check port | `8080` |
| Build argument `QURAN_CONTENT_URL` | `https://quranhaven.org/v1/` (already the default) |

Use the existing amd64 server. The build downloads the official Flutter 3.44.7
Linux SDK and checks its pinned SHA-256, resolves dependencies against
`pubspec.lock`, and builds web assets on the server. Allow several GB of free
build space for the SDK and caches. Flutter build dependencies need network
access; the running content service does not contact any source website.

The content stage refuses to build if any served resource differs from its
manifest. The runtime image contains only NGINX, the app bundle and the verified
public files. No generated `build/` directory, secrets or account database is
committed or copied into it.

## Domain and HTTPS

1. Point the Cloudflare DNS `A` record for `quranhaven.org` at the existing
   Coolify server's public IPv4 address. Only add `AAAA` if IPv6 is configured.
2. The current deployment keeps Cloudflare proxying enabled for both the apex
   and `www` records. Allow the existing Coolify proxy to receive ports 80/443;
   do not replace proxy settings shared by other applications. If certificate
   issuance fails, inspect the exact ACME error before changing DNS or TLS.
3. Let Coolify issue the HTTPS certificate for `quranhaven.org` and verify HTTPS.
4. Cloudflare is configured to use Full (strict) TLS, not Flexible.
   Preserve the original `/v1/*` file bytes after HTTP decoding. A proxy may add
   a separate `Content-Encoding: gzip` transport layer; browsers remove that
   layer before the app reads the file. A `.json.gz` resource must still be the
   original gzip file at that point, not already-decoded JSON. Do not relabel the
   file's own gzip layer as HTTP encoding or rewrite its contents.

Cloudflare documents the origin-certificate requirements for
[Full (strict)](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/full-strict/).

No `QURAN_API_URL` is set in this deployment. Optional account/synchronization
features remain unconnected until the separate backend is deliberately deployed
with its own secrets, database and security configuration.

## Publish and verify

Run the local integrity check before publishing the source:

```sh
python content/prepare_content.py --verify --public-only
```

After Coolify reports a healthy deployment:

```sh
python deployment/smoke_check.py --base-url https://quranhaven.org
```

If this computer's DNS cache has not caught up with verified public DNS, the
optional `--resolve-address VERIFIED_IP` flag directs this check alone to that
address. HTTPS certificate validation and the original hostname remain enabled;
system DNS and browser settings are not changed. This is a diagnostic option,
not a permanent IP configuration for the app.

This checks HTTPS app entry points, the content manifest, a byte-for-byte
translation download, gzip handling and missing-file behavior. It accepts
identity or one gzip HTTP transport layer, checks the original file's hash, then
decodes the separate `.json.gz` file format for validation. Unknown encodings,
damaged payloads and incorrectly labeled gzip files fail verification. Also open the
app from outside Saudi Arabia and select an additional translation from Library.
Core Quran reading continues to use its bundled data and page fonts.

For an independent local container check (requires Docker on Linux/amd64):

```sh
docker build -t quranhaven:local .
docker run --rm --name quranhaven-check -p 127.0.0.1:8080:8080 quranhaven:local
python deployment/smoke_check.py --base-url http://127.0.0.1:8080
```

The default image still points extra downloads to the real HTTPS domain. Override
the build argument only for local testing; never ship an APK using localhost.

## Android app connected to this service

Once the public checks pass, build the Android package with the same content root:

```sh
flutter build apk --release \
  --dart-define=QURAN_CONTENT_URL=https://quranhaven.org/v1/
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. Keep release
signing credentials out of Git; store publication and final signing are separate
from this website/content deployment.

## Content backups and updates

Git includes `content/public/v1/`, its manifest, and provenance JSON. The original
publisher downloads in `content/upstream/`, expanded originals in
`content/official/`, and saved portal HTML remain in the local project as a
separate backup and are ignored by Git. Do not delete these local originals.
The public copy is enough for deployment and `--verify --public-only`.

Keep a separate private backup of the originals before moving computers. To
change public content, regenerate and verify the manifest with the preparation
tool, then deploy both manifest and files together. The present `/v1/` cache
lifetime is one hour, not immutable; browsers revalidate the manifest each time.

Audio still uses the existing recitation providers. The current web library does
not guarantee persistent offline caching of optional text downloads after a
reload. See [the content inventory](../content/README.md) for full limitations.

## References

- [Coolify Dockerfile build pack](https://coolify.io/docs/applications/build-packs/dockerfile)
- [Flutter web deployment](https://docs.flutter.dev/deployment/web)
- [Official Flutter Linux checksums](https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json)
