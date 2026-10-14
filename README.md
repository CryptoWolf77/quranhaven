# Quran Haven

A multilingual Flutter Quran app for Android, iOS, Web and PWA, free for everyone
as Sadakah Jariyah (صدقة جارية). No advertisements, donations, subscriptions or
paid features.

## Local-only personal storage

Since build 6, the app has no accounts, sign-in, cloud backups or cross-device
synchronization. Bookmarks, last-read position, Khatmah/memorization progress,
language, appearance and reminders stay in the app's storage on the user's
device, or in that browser's local storage. Downloaded content stays local too.

Existing storage keys and the Android application ID are unchanged so an
in-place update can retain existing local progress. Android automatic app backup
is disabled. Uninstalling the app, clearing app/site data or browser eviction can
erase local data; there is no remote recovery copy. The website's Local backup
tool exports/imports a private JSON file; downloaded books/audio are excluded.
Keep the exported file yourself. Restore explicitly replaces current personal
data after validation and confirmation; it is not a cloud backup or merge.

Public Tafsir, translations and recitation downloads still need an internet
connection. These requests do not upload personal reading progress. Network
providers and existing website analytics are described in the multilingual
`/privacy.html` policy; local-only personal storage does not mean the app makes
no network requests. The owner-approved support/privacy address is
`admin@yahyazlab.com`.

## Implemented experience

- Responsive navigation; Arabic, English and Spanish; light/dark/system theme.
- Madinah Mushaf reader using the local `vendor/quran_library` foundation.
- Surah/Juz/page navigation, Arabic Quran search, bookmarks and last-read resume.
- 35 commentary resources and 9 translations; downloadable text resources.
- Reciter selection, Surah/Ayah playback, word-by-word memorization audio and
  native and explicit browser Surah audio downloads.
- Local Khatmah plans, daily targets, pause/resume and Ramadan options.
- Local memorization ranges, repeats/delays, hide/reveal and revision markers.
- Optional on-device reading reminders on Android and iOS.
- Explicit browser offline preparation, verified text caches and staged updates.
- Keyboard/semantic controls and large-text layout improvements.
- Personal Ayah notes, named collections, complete Ayah PNG/text/public-link
  sharing and search across a whole bundled/downloaded Tafsir or translation.
- Bundled, hash-verified Quranic Arabic Corpus v0.4 morphology: original word
  segments, POS tags, roots/lemmas when present and raw feature codes.
- A prominent Home usage-guide entry and 13 Arabic/English/Spanish lessons,
  written numbered steps, real-screen H264 MP4 demonstrations and highlighted
  pointer/click instructions, explicit playback/seek/replay and a full-screen
  viewer. The 39 final videos use real website footage and verified Android
  reminder footage; iOS footage is not claimed.
- A shared open-Quran book identity for the site/app icons, plus the original
  YahyazLab creator logo on Home/Settings. The optional creator link opens
  `https://yahyazlab.com/` only after an external-site confirmation.

The expanded personal/learning/browser-audio tools and guide are published in
website build 15, deployed from `11baca8` and verified on 2026-10-15. Actual
notes/collections/backup workflows pass in all three languages; all 39 videos
pass online and after complete preparation in a new offline page. The five main
screens also pass 27 language/engine/viewport combinations. See the dated
evidence and remaining device/store limitations in deployment/VERIFICATION.md.
Morphology is not a full syntactic treebank, generated Tafsir or word-meaning
dictionary. Previously unaudited Qiraat/word-info resources remain disabled.
Cloud accounts and synchronization are cancelled, not pending features.

The original Corpus file and both copyright blocks are unchanged. Its GNU
license, Tanzil terms, official documentation links and acquisition provenance
are available in **Word morphology → Source and license** and
[assets/learning/SOURCE.json](assets/learning/SOURCE.json). This separate data
resource does not replace the canonical Mushaf or change the app's code license.
Native file adapters are implemented: Android JSON/PNG saving uses the system
document chooser without broad storage access, and iOS saving/sharing uses the
system share sheet. Imports use the chosen-file picker and a validated preview.
Actual Android emulator JSON export/preview/cancel/safety-copy/restore and PNG
saving have passed. No physical iOS result is implied by shared Dart tests.

## Quran content independence

Quran text, navigation data and all 604 page fonts are bundled locally. The King
Fahd Developer Portal is attribution, not a live API dependency. Verified
optional text resources are served read-only from
`https://quranhaven.org/v1/`; existing recitation providers supply audio.
Original publisher archives and source/license credits remain preserved.

The root Dockerfile serves the web app and public content without a user-data
API or database. See [content/README.md](content/README.md) and
[deployment/README.md](deployment/README.md).

## Run and build

```sh
flutter pub get
flutter run --dart-define=QURAN_CONTENT_URL=https://quranhaven.org/v1/
flutter build web --release --no-web-resources-cdn --dart-define=QURAN_CONTENT_URL=https://quranhaven.org/v1/
python deployment/prepare_offline.py --web-root build/web
```

Android release builds require private signing configuration, or an explicit
test-signing flag; see [deployment/RELEASE.md](deployment/RELEASE.md). Keep the
existing application ID `org.quranflutter.quran_flutter`.

## Remaining phases

See [PLAN.md](PLAN.md) for the current checklist. Phases 1–6 are implemented
under the revised local-only scope. Phase 7 still needs wider physical-device,
Safari/iOS and accessibility acceptance. An owner-authorized local Android
upload key is configured. The production Android bundle is verified and uploaded
to the new Quran Haven Google Play app. Production1.0.0(15), the three localized
listings and the owner-approved13+ audience/Data Safety are now in Google review;
automated submission checks completed. This is not store approval or a live
listing. iOS still requires macOS/Xcode and Apple
signing/device acceptance.

Website build 13 was published and verified on 2026-10-12 with local-only storage,
the multilingual guide, corrected page-field focus and keyboard dismissal,
durable plan saves, accessible resource deletion, refreshed reciter endpoints
and release-keyed online/offline entrypoints. Tafsir now shows loading and
failure feedback rather than an empty panel. Unprepared Qiraat/grammar download
panels are hidden; this release supports the agreed Hafs Mushaf.
Android test build 8 additionally fixes the audio-service
icons needed by background/media controls and passed in-place emulator upgrade
and offline playback checks. It is test-signed, not store-ready. The website and
APK have separate build numbers. Build 13 above is historical; the current
public website is build 15. The final test APK15 passed an in-place emulator
upgrade, cold offline playback with correct native media metadata and local
backup/PNG workflows. The production AAB15 uses the separate authorized upload
certificate, not the test APK's debug signature.
Preparing a build locally does not update the public website automatically.
Historical cloud verification is retained as history in
`backend/VERIFICATION.md`; it is not part of the current app. Retiring the old
remote service or deleting existing server data requires a separate owner
decision and is not performed by removing the client feature.
