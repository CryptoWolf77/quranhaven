# Quran Haven iOS verification

Submitted for App Review, 2026-10-15 22:27 (Asia/Muscat). This records observed results;
simulator acceptance is distinguished from physical-device acceptance below.

## Source and tools

- Cloned the latest `main`: `4be31c6` (Arabic Mac handoff), following `79c5938`.
- Working branch: `ios/release-readiness`.
- Isolated official Flutter tag 3.44.7, commit
  `84fc5cbb223bc12f83d65b647ff8a56caf779ffd`; Dart 3.12.2.
- macOS 26.5.1 (25F80), Xcode 26.5 (17F42), iOS simulator runtime 26.5.
- The pre-existing Flutter 3.44.6 installation and its local lockfile change
  were preserved; tools are isolated in the task workspace.
- Bundle ID remains `org.quranflutter.quranFlutter`, version `1.0.0 (15)`.
- Team ID read from the owner's authenticated Apple account: `3393P2G2T3`.
- Owner explicitly approved the displayed Apple Developer Program License
  Agreement dated October 13, 2026; its Agree action was completed. App Store
  Connect then displayed a separate updated Paid Applications Schedule notice.

## Completed checks

- Public-only source integrity audit: all 1,161 files, 114 Surahs, 6,236 Ayahs,
  604 Mushaf page fonts and 44 text resources passed.
- All 261 existing Flutter tests passed on the Mac.
- Analysis: three distinct pre-existing vendored `cacheExtent` informational
  deprecations, no new errors/warnings. The last run emitted each twice (six
  entries). The default analyzer exits 1 for informational notices; they were
  not hidden or presented as a zero exit.
- First debug simulator build succeeded through the existing pure SwiftPM
  integration. No Podfile fallback, dependency upgrades or regenerated iOS
  project were needed. iOS deployment target remains 13.0.
- Native XCTest passed on the iPhone 17 Pro simulator, iOS 26.5:
  `testForegroundNotificationDelegateIsRegistered` and
  `testInternalStorageIsExcludedFromSystemBackup`.
- All 39 bundled ar/en/es videos passed actual AVFoundation initialization,
  no autoplay, time advancement, pause stability, seek, end and replay on the
  iPhone 17 Pro Max simulator. These use the real app video controller.
  An initial UI automation assertion used Cupertino's back-button finder for a
  Material AppBar; it failed after Arabic light navigation, while the separate
  39-video check passed. The driver was corrected to use the actual BackButton;
  the complete recheck passed on iPhone 17 Pro Max and iPad Pro 13-inch (M5).
  The complete matrix also passed on iPhone 17 Pro: ar/en/es, light/dark,
  all five destinations and the guide. 24 native captures per simulator were
  saved; no Android captures or generated Quran text were used.

## Changes

- Registered `UNUserNotificationCenter` delegate without requesting permission
  during launch; permission remains tied to the user's reminder action.
- Marked the internal Documents and Library parent directories excluded from
  system backup before Flutter initializes. Keeps GetStorage, UserDefaults,
  downloaded text/audio and existing file paths/keys intact. XCTest reads the
  actual resource values and verifies an existing fixture survives reapplying.
  Apple's flag is system guidance, not a guarantee that data can never appear
  in any backup or restored device. Manual user exports are separate copies.
- Declared ar/en/es native bundle localizations.
- Added ignored Apple private key/profile, IPA, archive and dSYM patterns.
- Added official SDK integration_test tooling and real native acceptance
  drivers; existing production package versions/hashes remain unchanged.

## Additional native acceptance and fixes

- Actual native UTF-8 JSON write/read/validated restore passed with notes, a
  collection and a paused Khatmah plan. Invalid JSON was rejected.
- Downloaded Spanish translation contains all 6,236 Ayahs. Saved reading and
  parsing passed with Dart HTTP clients deliberately blocked by a test-only
  override. Removing and redownloading the resource passed.
- Found and fixed native translation status checking: the delivery catalog
  names `es.json.gz`, while the saved file is `es.json`. Refresh now checks the
  real native filename and recovers existing saved-file indices. Paths and
  existing data are preserved. The fix also applies to the shared native code;
  no Android release or website deployment was performed.
- A 669,781-byte Fatiha recording downloaded without autoplay, then played,
  paused and sought through the production local-file audio path with Dart
  HTTP disabled. This does not simulate every native socket or real hardware
  interruption.
- Native PNG render/write/read signature verification passed. On iPad, the
  production JSON share popover opened, Save to Files saved a 418-byte test
  backup under On My iPad, and file_selector reopened it into the restore
  preview. Cancel returned without replacing records.
- The reminder OS prompt appeared only when enabling the feature. Denial
  kept the switch off and displayed the permission message.
- The controlled in-place update passed on iPad Pro 13-inch (M5), iOS 26.5:
  installed test build 0.9.9 (14), seeded a note, collection, paused plan and
  sandbox file through the production repositories, then installed 1.0.0 (15)
  with the same Bundle ID without uninstalling. Both installed build numbers
  were read from their actual app Info.plist. The second run verified every
  fixture and restored the previous test records. Both builds use the current
  source with an integration-test entry point; this is not a prior production
  version migration or a TestFlight/hardware installation claim.
  Use `flutter build ios --simulator --debug` with `IOS_UPDATE_PHASE=seed` and
  build 14, then `verify` and build 15. Drive the resulting `.app` with
  `--use-application-binary`, `--keep-app-running`, `--no-uninstall-first`
  and `test_driver/ios_acceptance.dart`. The initial harness let Flutter remove
  the test app on exit; that run is not counted as upgrade evidence.
- Found and fixed a real reminder timing bug: Apple returned `Asia/Muscat`,
  absent from timezone 0.11.1 default data. The service caught that lookup
  error and silently selected UTC; the actual OS trigger showed hour 21
  with timezone Etc/UTC (four hours late). Using the same package version
  with `latest_all.dart` retains IANA aliases.
- After the fix, the real daily reminder was observed delivered by iOS at
  2026-10-15 21:54:00 Asia/Muscat on iPad Pro 13-inch (M5), iOS 26.5.
  Rescheduling retained exactly one pending ID 2001; cancellation removed it.
  Initial test runs also exposed a test target computed before an OS prompt;
  the driver now resolves permission before choosing the test minute.
- Actual Dart HTTP profiling found an unnecessary GitHub library-logo request.
  iOS now configures bundled Quran Haven artwork before audio initialization;
  its MediaItem uses a local file URI. The native recheck observed only GETs
  to the production Spanish translation and the selected Tarteel recording,
  each with zero request-body length. Dart profiling does not capture all
  native Apple/OS traffic, so this is scoped evidence, not an exhaustive
  packet-capture claim. No personal record was intentionally sent.
- Added an app privacy manifest for own-app UserDefaults (CA92.1), sandbox
  file metadata (C617.1) and user-selected file metadata/size (3B52.1), with
  no tracking domains. Retained request metadata is disclosed as Coarse
  Location, Product Interaction and Other Data Types, linked, for App
  Functionality/security and Analytics, without tracking. Local personal
  notes/plans are not declared as collected off-device.
- Confirmed the app and ten framework/plugin privacy manifests are embedded
  in the signed archive. No cloud/account/associated-domain entitlements.
- Replaced the blank Flutter launch placeholders with byte-identical copies
  of the existing Quran Haven brand artwork, constrained to 168 pt on the
  parchment launch background. No Quran assets or letters were modified.

## Apple account and distribution configuration

- Confirmed no Quran Haven record in the current App Store Connect app list
  and no matching App ID in the team's identifier list.
- Registered Quran Haven with its existing explicit Bundle ID on the team;
  no extra capabilities were enabled, including iCloud/Sign in with Apple.
- Created App Store Connect record `6823268805`, SKU `quran-haven-ios`,
  primary English U.S.; Arabic and Spanish (Spain) app information saved.
  Localized names retain Quran Haven with Arabic/Spanish descriptors.
- Owner approved the third-party content-rights declaration, calculated Apple
  age rating 13+ without Kids/override, manual release after approval, and
  worldwide availability (175 current regions plus future Apple regions).
  Mac and Vision Pro availability are disabled. Price schedule is zero.
- Owner approved using their actual Apple account name/phone and the public
  support email for private App Review contact; private details are not stored
  in this repository.
- Owner approved publishing the prepared App Privacy responses at the action
  shown by Apple. App Store Connect confirmed publication by the account owner.
- English, Arabic and Spanish version descriptions, promotional text, keywords,
  localized support URLs and marketing URL were saved. Eight native iPhone
  17 Pro Max screenshots and eight iPad Pro 13-inch screenshots were uploaded
  per locale. Apple's smaller-size inheritance is used; the additional iPhone
  17 Pro captures remain acceptance evidence.
- After the real encryption questionnaire, the owner explicitly approved
  temporarily excluding France so review can proceed. France is now Not
  Available; the other 174 current countries/regions and future markets remain
  selected. Do not restore France without resolving its encryption declaration.
- The build uses standard TLS through Dart's bundled BoringSSL in addition to
  Apple networking, not proprietary cryptography. The questionnaire was answered
  with standard encryption outside Apple's OS and France = No. App Store
  Connect then changed build 15 to Ready to Submit. No blanket
  `ITSAppUsesNonExemptEncryption=false` was added to bypass this process.
- No TestFlight groups or testers were added; TestFlight installation and
  on-device distribution acceptance were unavailable without physical hardware.

## Verification limits

- Owner requested simulator checks for now. Physical iPhone/iPad testing,
  lock/headphone/interruption audio and physical reminder delivery remain open.
- JSON export to Files and import preview/cancel were observed. The production
  PNG action also opened the native iPad share popover with a 34 KB PNG. Saving
  and opening that PNG outside the app, a complete manual safety-copy restore,
  VoiceOver, Dynamic Type, rotation and physical-device acceptance have not all
  been verified. No accessibility-support claim was published for these checks.
- Network evidence is scoped to the native Dart HTTP profile, rather than a
  complete OS packet capture. Storage backup exclusion was checked as actual
  metadata, rather than by performing an iCloud backup/restore.
- No website, Android, Coolify, DNS, old cloud service or user data was changed.

## Signed build and Apple validation

The first device release and archive succeeded on Xcode 26.5 / iPhoneOS 26.5.
Automatic export used the account's existing Cloud Managed Apple Distribution
certificate (SHA1 ED50E8712FC46639B6D02721874407E600CC4600, expires
2027-07-25), Team 3393P2G2T3, Store provisioning for the unchanged Bundle ID.
Export entitlements include get-task-allow=false and beta-reports-active=true.
No distribution private key was exported or committed. The final archive was
rebuilt after the translation/artwork/timezone/launch fixes, with production
content URL `https://quranhaven.org/v1/`, `lib/main.dart`, version 1.0.0 (15).

- Final exported IPA SHA256:
  `a2fd5d58de929b279ef8030f876b3e243831329c0290064d740abf464a769aef`.
- Xcode Organizer Validate completed successfully with one warning: starting
  April 2027 Apple will require deployment target 15.0 or later. This build's
  13.0 target was accepted for the current upload.
- Organizer upload completed with the same future-target warning at 22:10.
  Apple processed the build and it appeared in TestFlight as build 15.
- Build 15 was selected and saved for iOS version 1.0.0. Add for Review passed
  Apple's readiness check and created a draft submission at 22:24. Final
  submission succeeded at 22:27 and the details page displayed Waiting for
  Review for 1.0.0 (15), submission
  `06d1f905-0784-43bd-a739-e1b2ac4ef699`. This is not approval or public release;
  the owner-approved manual release setting remains selected.

## References for the encryption declaration

- [Apple's encryption requirements](https://developer.apple.com/documentation/security/complying-with-encryption-export-regulations)
- [Apple's required encryption documentation and France](https://developer.apple.com/help/app-store-connect/reference/app-information/export-compliance-documentation-for-encryption)
- [Dart SDK TLS implementation](https://github.com/dart-lang/sdk/blob/main/runtime/bin/security_context.cc)
