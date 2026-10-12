# Quran Haven — current implementation plan

Updated 2026-10-01: the owner cancelled accounts, cloud backup and synchronization.
All personal app data must stay on the user's device/browser. Public Quran
content hosting and recitation downloads remain in scope.

All features are free Sadakah Jariyah: no donations, payments, ads or premium.
Project folder: `C:\Users\ThaherTech\Documents\Quran Flutter`.

## Phase status

| Phase | Implementation | Remaining acceptance |
| --- | --- | --- |
| 1. Foundation | Android/web foundation and iOS configuration implemented | iOS build, signing and device checks need macOS/Xcode and Apple team access. |
| 2. Reader | Surah/Juz/page navigation, Arabic search, bookmarks, last-read persistence and reader customization implemented | Wider physical-device/display acceptance. |
| 3. Text/audio | 44 verified text resources, reciter selection/playback, mobile audio downloads and browser text downloads implemented | Browser offline audio remains backlog; audio uses external providers. |
| 4. Plans | Local Khatmah/memorization progress, targets, repetition, hide/reveal and revision markers implemented | Physical-device background audio acceptance. |
| 5. Local preferences/reminders | Local language/theme, plans, bookmarks and optional device reminders; cloud client removed in build 6 | Verify in-place upgrades and reminder delivery on physical phones. |
| 6. Public content deployment | HTTPS web and read-only content hosting implemented; current builds have no personal-data API configuration | Publish and verify the local-only build; old remote accounts are not deleted by this change. |
| 7. Offline/accessibility | Browser preparation, verified caches, staged updates, keyboard/semantic controls and large-text layouts implemented | Physical phones, Safari/iOS, quota/eviction and full assistive-technology checks. |
| 8. Store release | Signing guard, key template, attribution and release checklist prepared | Owner signing/store setup, privacy approval, iOS platform access and final acceptance. |

## Local-only change

- [x] Remove sign-in, registration, cloud backup/restore/deletion UI and clients.
- [x] Remove cloud session-storage dependency and API build configuration.
- [x] Keep existing local storage keys and application identity.
- [x] Explain device/browser data loss and lack of cross-device recovery in all
  three interface languages.
- [x] Disable Android automatic app backup.
- [x] Remove cloud backend deployment source from the current project; retain
  historical verification and retirement guidance.
- [x] Cancel password recovery, email verification, cloud user database backups,
  automatic sync and device-session management as product requirements.

There is no automatic transfer from an old cloud snapshot. Existing local data
remains local; server records are untouched. A separate owner-approved retirement
decision is needed for the previously deployed cloud service/data.

## Release gates still open

- [ ] Publish the new local-only web build and verify actual browser delivery.
- [ ] Supply public privacy contact and approve accurate disclosures covering
  local storage, content/audio providers and existing CDN analytics.
- [ ] Supply owner-controlled Android signing and Google Play setup.
- [ ] Provide macOS/Xcode, Apple team and physical iOS devices.
- [ ] Complete install/upgrade, offline, interruption/background audio, denied
  permissions, reminders, large-text and screen-reader acceptance.
- [ ] Verify browser storage limits/eviction, private browsing and multi-tab updates.

## Additional product backlog

Personal notes, arbitrary named bookmark categories, generated Ayah-image and
deep-link sharing, full translation/Tafsir search, grammar/morphology teaching,
browser audio downloads and optional local file export/import are not yet
implemented. They must use local storage if added. Cloud storage is cancelled.

See [deployment/RELEASE.md](deployment/RELEASE.md) for publication gates,
[deployment/OFFLINE.md](deployment/OFFLINE.md) for offline boundaries, and
[deployment/VERIFICATION.md](deployment/VERIFICATION.md) for dated evidence.
