# Quran Haven release gates

The app is free Sadakah Jariyah. These are publication checks, not paid features.
Passing unit tests or generating a test APK does not close the production gates.

## Android signing

Release tasks now refuse the previous implicit debug-signing fallback. The
owner must supply and privately back up their upload keystore, alias and passwords.
Put them in ignored `android/key.properties`; use `android/key.properties.example`
only as a field guide. Never commit the actual file, print it or upload the key.
The application ID stays `org.quranflutter.quran_flutter` to preserve installations.

For an explicitly test-signed APK in PowerShell, use the scoped build helper:

```powershell
./deployment/build_android.ps1 -TestSigning
```

The helper temporarily puts Windows Java socket files in ignored `android/.gradle`
to avoid failures caused by long redirected TEMP paths. It restores process
settings on completion; no system network or Java settings are changed. Pass
`-FlutterExecutable C:\flutter\bin\flutter.bat` if Flutter is not on PATH.

Do not publish that artifact in Google Play. With the owner's production signing
configuration, omit `-TestSigning` and use `-AppBundle` with the same content root.
Verify the certificate before uploading. See the official
[Flutter Android release guide](https://docs.flutter.dev/deployment/android).

### Owner-authorized upload key — 2026-10-14

The owner explicitly authorized creation of a new local upload key. It is stored
outside the repository in `C:\Users\ThaherTech\Documents\Quran Haven Signing`.
The RSA-3072 PKCS12 key and its password configuration are private; the PEM
certificate is public. The owner should keep a separate private/offline backup
of the complete signing folder. Neither the key nor its passwords may be
committed, included in a container or uploaded with the app bundle.

Certificate SHA-256:
`52:E9:B3:5A:EB:F9:60:10:2F:EC:DD:F7:52:80:2C:84:4D:F6:A2:40:3A:BC:89:4E:E7:B5:C1:CF:C9:84:4D:19`.

`deployment/create_upload_key.ps1` refuses to overwrite an existing signing
folder/configuration, restricts the private folder to the current Windows user
and SYSTEM, and supplies password input to the signing tool through a temporary
private file rather than command arguments or logs. The temporary input is
removed after creation. Ignored `android/key.properties` remains local.

Explicit `-TestSigning` takes precedence for emulator upgrade checks so existing
debug-signed installations can retain their data. The helper rejects the
`-AppBundle -TestSigning` combination. Production bundle acceptance must still
check the certificate on the actual artifact before uploading.

## Public privacy contact

The owner approved `admin@yahyazlab.com` for public support/privacy contact on
2026-10-14. The public policy route is `/privacy.html` with Arabic, English and
Spanish display options. Personal records remain local; public-content requests,
third-party audio hosting and the existing website-only Cloudflare analytics
must not be described as having zero network logging. The policy and store
Data Safety answers must match the release actually tested and submitted.

## Still required from the owner

- Approval of accurate technical-log/support-mail retention disclosures where
  those are not established by code; the public contact is now supplied.
- Final Google Play release review; the approved 13+ audience, saved Data
  Safety/service-practice disclosures, signing/legal setup and IARC are recorded
  below, rather than assumed from a generated bundle.
- Apple developer account and signing ownership.
- macOS/Xcode and Apple team configuration for iOS signing and device testing.

### Google Play setup progress — 2026-10-15

The owner approved the app-creation policy/export attestations, Google-managed
Play App Signing, worldwide distribution (178 supported countries/regions),
and the IARC terms at the corresponding actions. App
`4972735598475155183` belongs to the YahyazLab developer account. Production
release `1.0.0 (15)` is a draft with the upload-signed AAB processed by Google;
private signing material was not uploaded.

Privacy, unrestricted app access, no ads, no government affiliation, no
financial features and no health features were saved. Books & Reference and
the approved support email/official website were saved. The English store
listing, icon, feature graphic and eight actual native phone captures are
ready to send for review, with the icon/feature graphic AI labels retained.

The content questionnaire was completed using bundled and downloadable text,
including textual references, not invented visual scenes. Its saved results
are ClassInd All ages, ESRB Teen, PEGI 3, USK 12+, and Generic/Russia/South Korea
3+. The owner explicitly approved targeting ages 13+ for the current store
release on 2026-10-15. The saved groups are 13–15, 16–17 and 18 and over;
this supersedes the earlier all-age store intent. The rating answers were not
changed to lower the result. Public website availability remains unchanged.

The English, Arabic and Spanish listing texts and eight native phone captures
per locale were saved together. In every locale the order starts with the
reader, Home and the guide. Target audience and Data Safety have now also been
saved; final Dashboard and production release checks remain in progress.
No tablet/desktop/XR phone screenshots were misrepresented as device captures.

Data Safety was saved after completing Target audience. It records optional collection of IP/
client identifiers, public-resource request interactions and country inferred
from IP. The domain's existing Cloudflare HTTP request dashboard visibly
contains those statistics, independently of the website beacon. No native
analytics SDK or GPS permission is inferred from that delivery-service data.
Collection purposes reflect resource functionality, technical traffic
analytics and security; inferred country is limited to analytics/security.
The direct requests to external recording hosts are disclosed as sharing
network identifiers/resource interactions for audio functionality. Country
processing by our delivery provider is not declared as sharing under the
service-provider exception. Local notes/bookmarks/search/reading progress are
not added to these disclosures. No unverified ephemeral/90-day deletion or
remote deletion mechanism is claimed.

The public policy's three-language request-metadata and current 13+ store
audience clarification is prepared for deployment, without changing CDN
settings, website access or any old Cloud account data.
Final release review is still in progress.
**The release has not been sent to Google for review.** The
owner-requested forced shutdown is conditional on visible in-review status;
neither draft upload nor a completed IARC form satisfies that condition.

## Acceptance before public store release

Do not infer web-plugin readiness from a successful incremental compilation.
The pinned local toolchain has previously retained stale compiler output after
adding plugins. Use a clean, reproducible web build and verify actual video,
file-picker and external-link behavior. Move only a validated project compiler
cache to a recoverable task-specific backup when a clean rebuild is necessary;
never clear user browser/app data or private signing material to repair a build.

Audit the exact Android APK/AAB's packaged 64-bit native libraries with
`python deployment/audit_android_native.py path/to/artifact`. The read-only
checker verifies ELF load-segment alignment for 16KB pages; it does not replace
APK ZIP alignment, signature/certificate, install or device/runtime checks.
Never pass a private signing key to this checker or to any upload flow.

- Physical Android/iOS: fresh install, upgrade preserving bookmarks/plans, fully
  offline reading, optional downloads, audio interruption/background controls,
  denied permissions, reminders and local data persistence.
- Browser: actual offline mode, quota/eviction, multiple-tab update controls,
  private-browsing restrictions, narrow display/large text and screen-reader use.
- Local storage: existing bookmarks/plans/preferences survive an in-place update;
  uninstall/clear-data warnings accurately explain that no remote recovery exists.

No store enrollment or CDN cache purge is implied by this checklist. Store
agreements and security-sensitive signing enrollment require action-time owner
confirmation; the explicitly authorized local upload-key creation is recorded
above. A submitted release is not live until Google approves and publishes it.

Cloud account recovery and user-database backup gates were cancelled on
2026-10-01. Public content hosting remains; personal progress is local-only.
