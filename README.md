# Quran Flutter

A multilingual Quran application for Android, iOS, Web, and PWA, free for
everyone as Sadakah Jariyah.

## Product principles

- Every feature is free.
- No advertisements, subscriptions, or feature locks.
- Core reading remains available offline.
- Accounts are optional and only support backup and synchronization.

## Phase 1

The initial foundation includes:

- Android, iOS, Web, and PWA project scaffolding.
- Responsive mobile and desktop navigation.
- Arabic, English, and Spanish localization.
- Light, dark, and system appearance modes.
- `quran_library` initialization and a working Mushaf reader entry point.
- Android and iOS background-audio configuration.

## Phase 2

The reader experience now includes:

- Surah, Juz, and direct-page quick navigation.
- Localized Quran search and bookmark tabs.
- Persistent last-read page, surfaced on the Home screen.
- Localized reader controls in Arabic, English, and Spanish.
- Theme-aware Quran navigation, search, bookmark, and Ayah-menu styling.
- Word selection and the Quran library's display modes.

## Phase 3

The content and listening experience now includes:

- A dedicated Library destination for Tafsir, translations, and recitations.
- Selection and mobile offline download of the Quran library's Tafsir and
  translation resources.
- Complete-Surah playback and saved-position resume controls.
- Mobile offline Surah-audio downloads with cancellation and status feedback.
- Access to reciter selection and downloaded-Surah management in the reader.
- Word-by-word audio initialization.
- Localized Tafsir and audio interfaces in Arabic, English, and Spanish.

## Phase 4

The guided Quran journey now includes:

- Persistent Khatmah plans with 30, 60, 90-day and Ramadan options.
- Daily page targets calculated from remaining pages and target date.
- Progress editing, pause/resume controls, and adjustable completion dates.
- Persistent Surah and Ayah memorization ranges.
- Configurable Ayah and full-range repetition with optional delays.
- Quran-text reveal and hide practice using `GetSingleAyah`.
- Word-by-word practice audio, revision markers, and memorized-Ayah tracking.
- Direct navigation from a memorization range into the Mushaf.
- Fully localized plan interfaces in Arabic, English, and Spanish.

## Phase 5

The optional connected experience now includes:

- Guest-first use with no account requirement for any Quran feature.
- Optional account registration and sign-in against a configurable API.
- Encrypted on-device storage for cloud session tokens.
- Explicit progress backup and restore for the last-read page, Khatmah plans,
  memorization ranges, and selected preferences.
- A self-hosted FastAPI and PostgreSQL backend packaged for Coolify.
- Argon2 password hashing, expiring JWT sessions, and per-user sync records.
- User-controlled daily reading reminders on Android and iOS.
- Arabic, English, and Spanish interfaces for all Phase 5 controls.

Cloud accounts are configured at build time so deployment addresses are never
hard-coded:

```sh
flutter run \
  --dart-define=QURAN_API_URL=https://api.example.org
```

See `backend/README.md` for local and Coolify setup. The optional cloud service
is now live and verified at `https://api.quranhaven.org`.

## Phase 6 — cloud deployment and connected clients

- Optional cloud-account deletion, preserving device progress and downloads.
- Clear data notices and manual-backup wording in Arabic, English and Spanish.
- HTTPS-only account connections (with loopback development support), expired
  session handling, and useful rate-limit messages.
- Production configuration checks, database-aware readiness, private PostgreSQL
  networking, a non-superuser database role and a rate-limited gateway.
- Automated API/isolation/deletion tests and an opt-in live deployment checker.

Cloud activation and live PostgreSQL/gateway integration are verified. Web and
Android builds connect to the live service. Snapshot restore validates before
writing, restores language/theme and persists them across restarts. Android
release builds include INTERNET permission. See `backend/VERIFICATION.md`.

## Phase 7 — web offline reading and accessibility

- Explicit offline app preparation with byte progress, cancellation and removal.
- Verified persistent browser Tafsir/translation downloads and actual saved state.
- Release-specific app caches with staged, user-controlled updates.
- Localized screen-reader labels, keyboard controls and large-text fixes for
  memorization/account controls, tested in Arabic, English and Spanish.
- Offline settings and confirmation dialogs tested at narrow widths and 2x text.

See `deployment/OFFLINE.md` for offline preparation, limits and verification.

## Quran content independence

The project is offered as Sadakah Jariyah (صدقة جارية). All features are free.
The Quran text, navigation data and 604 Mushaf page fonts remain bundled locally.
The King Fahd Developer Portal is attribution, not a live API dependency.

Official Hafs data archives and the library's optional text resources are saved
under `content/`, with checksums and a standalone Coolify content service. The
local `vendor/quran_library` copy routes optional downloads to your own server:

```sh
flutter run --dart-define=QURAN_CONTENT_URL=https://content.example.org/v1/
```

See `content/README.md` for the resource inventory, verification, deployment,
and remaining audio/PWA limitations. The root `Dockerfile` packages the web app
and content together for `https://quranhaven.org`, with optional downloads using
`https://quranhaven.org/v1/`. See `deployment/README.md` for Coolify, DNS, HTTPS and
verification steps. The image connects optional accounts to the separate API.

## Run locally

```sh
flutter pub get
flutter run
```

## Planned phases

1. Foundation and Quran reader — complete.
2. Reader experience, navigation, search, bookmarks, and last-read state —
   complete.
3. Tafsir, translations, recitations, and offline downloads — complete.
4. Khatmah and memorization tools — complete.
5. Optional account/manual-backup implementation and notifications — complete.
6. Cloud service activation and connected clients — complete; manual snapshots.
7. Browser offline reading and accessibility — implementation and testing.
8. Public-release readiness — pending recovery email, private off-server database
   backups with restore testing, final privacy contact/disclosures, production
   Android signing and Google Play/Apple accounts. iOS release also needs macOS.

The APK is currently test-signed. Do not upload it as a final store release or
describe the cloud database volume as a disaster-recovery backup. Bookmarks,
notes and audio are not part of the current cloud snapshot; automatic merging,
email verification/recovery and device-session management are not implemented.
