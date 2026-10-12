# Cloud service retired from the product

On 2026-10-01 the owner cancelled accounts, cloud backups and synchronization.
Build 6 has no account client, auth/session storage, backup API or user-data
server configuration. Personal data stays on the user's device/browser.

The backend application, deployment definitions and cloud-only tests were
removed from the current source tree. They remain recoverable in project history.
`VERIFICATION.md` is historical evidence, not a current deployment guide.

## Existing remote deployment

Removing source/client code does not stop the previously deployed cloud service
or erase its database. No remote user data was deleted during this change.

Before retiring that deployment, obtain the owner's explicit decision about
existing users/data, any permitted export and retention/deletion obligations.
Then retire only the dedicated account/API service and its resources, without
touching the public web/content service or unrelated Coolify applications.
Do not expose private snapshots or secrets in Git or the public content server.

Public Quran text and audio downloads are unrelated to personal cloud storage
and remain supported by the app.
