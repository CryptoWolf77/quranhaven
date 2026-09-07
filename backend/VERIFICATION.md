# Cloud phase verification — 2026-09-07

The owner approved optional cloud activation. The separate Quran Haven Cloud
application is live at `https://api.quranhaven.org`; core reading needs no account.
Private credentials were generated and retained by Coolify, never copied to Git.

## Passed locally

- 74 backend tests, including 12 deployment-checker tests, using isolated SQLite.
- 69 Flutter tests, including full restore preflight, persisted preferences,
  account-deletion preservation and exact memorization Ayah boundaries.
- 22 content and website-deployment utility tests.
- Release JavaScript web build with the self-hosted content URL and verified
  production cloud API URL enabled.
- Compose YAML parsing, database initialization shell syntax and production
  configuration validation with synthetic settings.
- Git whitespace checks.

Flutter analysis reports only three pre-existing `cacheExtent` deprecation
notices in the vendored Quran library. The WebAssembly dry run still reports
the existing `get_storage`/`dart:html` incompatibility; the JavaScript release
build succeeds. Backend tests report two upstream test-client deprecation
warnings.

## Live reader checks

The website now includes the cloud-connected and browser-offline release. Normal
DNS resolution for `quranhaven.org` works on this computer. The public HTTPS
deployment checker passed without an address override, including exact Quran
resource bytes and missing-file responses. Chrome loaded the home page and
Library; selecting the Spanish resource reached the selected state.

## Live cloud checks passed

- HTTPS API health and PostgreSQL readiness.
- Registration, login, backup upload/readback, account isolation, deletion,
  rejection of deleted-user tokens and rejection of deleted-user login. Both
  synthetic accounts were removed by the test; no real account was modified.
- Production documentation routes hidden; unauthenticated backups rejected.
- Exact website-origin CORS including preflight and denied untrusted origins.
- Bounded eight-request invalid-login burst returned 422/429 with correct CORS.
- Gateway, API and PostgreSQL containers all healthy, with no published host
  ports. Only the gateway has a public domain.

Deployment `3gwyoetzgjccxpi9arscskh9` completed at 11:46 UTC, using backend commit
`6e4a005d905fb03d303cd2a2aaeedd4d7dc68cb3`. Its PostgreSQL volume survives
application redeployment.

## Effective network boundary

Runtime inspection found Coolify attaches all three services plus `coolify-proxy`
to the application-specific bridge, in addition to the custom internal network.
No unrelated application is connected. API/database have no direct public
routes, but the reverse proxy can reach their bridge addresses. This is managed
Compose networking, not strict gateway-only network isolation. Do not weaken
or replace the shared server proxy to change this behavior.

## Client update and remaining work

The deployed web build and version-3 test APK include the verified API URL.
The APK has the INTERNET permission needed by release builds. Android/iOS
display names are Quran Haven. Language and theme restore together and persist on restart;
malformed backups are rejected before local fields are changed.

Email recovery/verification, private off-server backups and tested restoration,
privacy contact/disclosures, and final store signing/accounts remain outstanding.
The feature is manual snapshot backup/restore, not automatic conflict-merging
synchronization. See [README.md](README.md) and the newer
[connected/offline release checks](../deployment/VERIFICATION.md) for deployment,
APK hashes and real browser outage verification.
