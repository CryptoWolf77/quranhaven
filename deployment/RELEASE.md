# Quran Haven release gates

The app is free Sadakah Jariyah. These are publication checks, not paid features.
Passing unit tests or generating a test APK does not close the production gates.

## Android signing

Release tasks now refuse the previous implicit debug-signing fallback. The
owner must supply and privately back up their upload keystore, alias and passwords.
Put them in ignored `android/key.properties`; use `android/key.properties.example`
only as a field guide. Never commit the actual file, print it or upload the key.
The application ID stays `org.quranflutter.quran_flutter` to preserve installations.

For an explicitly test-signed APK in PowerShell, set a process-only variable:

```powershell
$env:QURAN_HAVEN_TEST_SIGNING = 'true'
flutter build apk --release --dart-define=QURAN_CONTENT_URL=https://quranhaven.org/v1/ --dart-define=QURAN_API_URL=https://api.quranhaven.org
Remove-Item Env:QURAN_HAVEN_TEST_SIGNING
```

Do not publish that artifact in Google Play. With the owner's production signing
configuration, omit the test flag and use `flutter build appbundle` with the same
content/API defines. Verify the certificate before uploading. See the official
[Flutter Android release guide](https://docs.flutter.dev/deployment/android).

## Still required from the owner

- Recovery-email provider, sender address and private server-side credentials.
- Private off-server backup repository, encryption-password custody and retention
  decision; then run and verify a restore on an isolated database.
- Public privacy-contact email and approval of accurate data/retention disclosures,
  including existing CDN analytics and third-party recitation services.
- Google Play/Apple developer accounts, signing ownership, store artwork/listings.
- macOS/Xcode and Apple team configuration for iOS signing and device testing.

## Acceptance before public store release

- Physical Android/iOS: fresh install, upgrade preserving bookmarks/plans, fully
  offline reading, optional downloads, audio interruption/background controls,
  denied permissions, reminders, expired sessions and account deletion.
- Browser: actual offline mode, quota/eviction, multiple-tab update controls,
  private-browsing restrictions, narrow display/large text and screen-reader use.
- Hosted backup: scheduled success/failure signal, encrypted off-server snapshot,
  isolated restore and the owner's retention/deletion policy.
- Cloud account recovery: real mailbox delivery, expired/one-use recovery token,
  abuse limits and revocation of old sessions after password reset.

No store enrollment, signing-key creation, mail sending, backup transfer or CDN
cache purge is implied by this checklist. Those must use the owner's setup.
