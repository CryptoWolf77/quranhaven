# Quran Haven optional cloud service

This optional service stores a user's email, display name, password hash and
voluntary Quran progress backup. Reading and all local features work without an
account. This is manual backup/restore, not automatic multi-device synchronization.

## Local development

```sh
python -m venv .venv
.venv/Scripts/pip install -r requirements-dev.txt
.venv/Scripts/pytest
.venv/Scripts/uvicorn app.main:app --reload
```

Run those commands from `backend/`. The default development database is SQLite.
Tests use an isolated database and never connect to production. The production
configuration requires PostgreSQL and refuses placeholder signing secrets.

## Coolify deployment

Activation is a separate step from publishing the web reader. Obtain the
owner's approval before creating the private database/signing credentials and
enabling public registration.

Create a separate Docker Compose application in the existing Quran Haven
production project, using the same repository and `main` branch:

| Setting | Value |
| --- | --- |
| Base directory | `/backend` |
| Compose file | `/compose.yaml` |
| Public service | `gateway` only |
| Gateway domain | `https://api.quranhaven.org:8080` |
| CORS_ORIGINS | `https://quranhaven.org` |

The port in Coolify's domain field selects the internal service port; public
clients still use normal HTTPS on port 443. Add the `api` DNS record to the
existing origin server and retain Cloudflare Full (strict). Do not publish any
host ports, expose API/database services directly, or attach them to shared
external networks. Verify the effective networks after Coolify generates its
configuration.

Coolify generates and retains these private values on the server:

- `SERVICE_PASSWORD_64_QURANDB`: application database password.
- `SERVICE_PASSWORD_64_QURANDBADMIN`: separate database administrator password.
- `SERVICE_HEX_64_QURANJWT`: signing secret for seven-day sessions.

Never copy values into Git, screenshots, logs or deployment notes. Reuse them on
redeployment. The database initialization script runs only for an empty volume;
changing a password variable does not rotate an existing PostgreSQL role. Do not
delete the persistent volume to resolve a credential problem.

The API connects as the non-superuser `quran`. Its database and API network is
internal. Only the gateway also joins the proxy-facing network. The gateway
limits authentication requests, concurrent connections and request-body sizes,
allows the exact web origin, disables access logs and hides documentation routes.
It trusts private proxy hops and Cloudflare's published IP ranges; keep those
ranges maintained and verify client-IP handling if the proxy topology changes.

For a local Docker integration check, create private values in an ignored
`.env`, then use `docker compose -f compose.yaml -f compose.local.yaml up --build`.
The local override binds only `127.0.0.1:8000`. Do not deploy that override.

## Verify before enabling the clients

```sh
python -B backend/smoke_check.py --base-url https://api.quranhaven.org
```

Run this from the repository root. It creates no accounts. The explicit
`--exercise-account` option creates two synthetic accounts, checks registration,
login, isolated backup/restore and deletion, then removes only those accounts.
Credentials and response bodies are not printed. Use this only as an authorized
deployment check. `--resolve-address VERIFIED_IP` is available for diagnostics;
it retains hostname and certificate verification and changes no system DNS.

Build the Flutter app with the deployed service:

```sh
flutter build apk --release \
  --dart-define=QURAN_CONTENT_URL=https://quranhaven.org/v1/ \
  --dart-define=QURAN_API_URL=https://api.quranhaven.org
```

For the web service, set the Docker build argument `QURAN_API_URL` to the same
HTTPS origin and rebuild only after the API checks pass. It defaults to empty,
so deploying reader changes alone does not activate accounts.

## API

- `POST /v1/auth/register`
- `POST /v1/auth/login`
- `GET /v1/sync`
- `PUT /v1/sync`
- `DELETE /v1/account`
- `GET /health`

Passwords are Argon2-hashed. The API returns expiring JWT access tokens; the app
uses platform secure storage. HTTPS is required except for loopback development.
The health endpoint checks database connectivity. Deleting an account removes
its live database record and backup and invalidates its tokens; it does not
delete device progress or downloaded resources.

## Current limits and launch checklist

- The backup includes last-read page, Khatmah and memorization plans, and selected
  preferences. It does not yet include bookmarks, notes or downloaded audio.
- Restore currently applies the last-read page and plans. Uploaded preferences
  are retained in the snapshot but are not yet reapplied to device settings.
- Backups are at most 1 MB. Upload replaces the previous snapshot; restoring
  replaces the corresponding local fields. There is no conflict merge or history.
- There is no email verification, password reset, token refresh or device-session
  management yet. Sign-out removes the token from that device, not other sessions.
- Data is encrypted in transit, not end-to-end encrypted; the server operator can
  access stored backups. Do not describe server data as inaccessible to operators.
- A persistent database volume is not a disaster-recovery backup. Before a broad
  public launch, configure a private off-server database backup destination,
  retention/deletion policy and a tested restore process. No such destination has
  been supplied or configured yet. Do not put user backups in this public repo.
- Before store release, complete the privacy disclosures, recovery-email workflow,
  rate-limit checks through the live proxy and PostgreSQL/container integration
  checks. These source changes alone are not proof of a production deployment.

Reference: [Coolify Docker Compose configuration and generated variables](https://coolify.io/docs/knowledge-base/docker/compose).
