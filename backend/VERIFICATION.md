# Cloud phase verification — 2026-09-07

Source changes are prepared for the optional Quran Haven cloud service. No cloud
API, database, public registration or server credentials were created during
this phase. Activation is pending the project owner's confirmation.

## Passed locally

- 74 backend tests, including 12 deployment-checker tests, using isolated SQLite.
- 18 Flutter tests, including cloud-session and account-deletion preservation.
- 22 content and website-deployment utility tests.
- Release JavaScript web build with the existing self-hosted content URL and
  no cloud API URL enabled.
- Compose YAML parsing, database initialization shell syntax and production
  configuration validation with synthetic settings.
- Git whitespace checks.

Flutter analysis reports only three pre-existing `cacheExtent` deprecation
notices in the vendored Quran library. The WebAssembly dry run still reports
the existing `get_storage`/`dart:html` incompatibility; the JavaScript release
build succeeds. Backend tests report two upstream test-client deprecation
warnings.

## Live reader checks

The existing website remains on the prior reader/content release. Normal DNS
resolution for `quranhaven.org` now works on this computer. The public HTTPS
deployment checker passed without an address override, including exact Quran
resource bytes and missing-file responses. Chrome loaded the home page and
Library; selecting the Spanish resource reached the selected state.

## Still required before cloud activation is complete

- Owner approval for private database/signing credentials and public accounts.
- Actual PostgreSQL, NGINX and container startup checks on Coolify. Docker is not
  installed locally, so local tests do not prove container integration.
- API DNS, HTTPS, effective private-network/port checks and gateway rate limits.
- Authorized synthetic account/backup/deletion round-trip on the deployed API.
- Only then rebuild the web app and Android package with the live API URL.

Email recovery/verification, off-server disaster-recovery backups and the other
launch limitations in [README.md](README.md) remain future release work. The
existing APK has not been rebuilt for this cloud preparation phase.
