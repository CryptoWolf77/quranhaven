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

## Still required from the owner

- Public privacy-contact email and approval of accurate data/retention disclosures,
  including existing CDN analytics and third-party recitation services.
- Google Play/Apple developer accounts, signing ownership, store artwork/listings.
- macOS/Xcode and Apple team configuration for iOS signing and device testing.

## Acceptance before public store release

- Physical Android/iOS: fresh install, upgrade preserving bookmarks/plans, fully
  offline reading, optional downloads, audio interruption/background controls,
  denied permissions, reminders and local data persistence.
- Browser: actual offline mode, quota/eviction, multiple-tab update controls,
  private-browsing restrictions, narrow display/large text and screen-reader use.
- Local storage: existing bookmarks/plans/preferences survive an in-place update;
  uninstall/clear-data warnings accurately explain that no remote recovery exists.

No store enrollment, signing-key creation or CDN
cache purge is implied by this checklist. Those must use the owner's setup.

Cloud account recovery and user-database backup gates were cancelled on
2026-10-01. Public content hosting remains; personal progress is local-only.
