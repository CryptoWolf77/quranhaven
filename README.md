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
erase local data; there is no remote recovery copy or local export/import tool.

Public Tafsir, translations and recitation downloads still need an internet
connection. These requests do not upload personal reading progress. Network
providers and existing website analytics still need accurate privacy disclosure;
local-only personal storage does not mean the app makes no network requests.

## Implemented experience

- Responsive navigation; Arabic, English and Spanish; light/dark/system theme.
- Madinah Mushaf reader using the local `vendor/quran_library` foundation.
- Surah/Juz/page navigation, Arabic Quran search, bookmarks and last-read resume.
- 35 commentary resources and 9 translations; downloadable text resources.
- Reciter selection, Surah/Ayah/word playback and native Surah audio downloads.
- Local Khatmah plans, daily targets, pause/resume and Ramadan options.
- Local memorization ranges, repeats/delays, hide/reveal and revision markers.
- Optional on-device reading reminders on Android and iOS.
- Explicit browser offline preparation, verified text caches and staged updates.
- Keyboard/semantic controls and large-text layout improvements.

Browser offline audio, personal notes, arbitrary named bookmark categories,
Ayah-image/deep-link sharing, full Tafsir/translation search and grammar teaching
remain backlog items. Cloud accounts and synchronization are cancelled, not
pending features.

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
Safari/iOS and accessibility acceptance. Phase 8 needs production signing,
store setup, privacy disclosures and macOS/Xcode access for iOS.

Build 6 is the local-only update. Preparing it locally does not update the public
website automatically. Historical cloud verification is retained as history in
`backend/VERIFICATION.md`; it is not part of the current app. Retiring the old
remote service or deleting existing server data requires a separate owner
decision and is not performed by removing the client feature.
