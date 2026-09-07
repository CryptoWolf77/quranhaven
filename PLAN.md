# Quran Haven — audited implementation plan

Audited on 2026-09-07 against the eight phases in README.md, the source code,
tests, built app and deployed services. This is the implementation checklist;
it does not treat the earlier product vision as already-delivered functionality.

All features remain free Sadakah Jariyah. No donation, payment, advertisement or
premium flow is present in the app. The working project stays directly in
`C:\Users\ThaherTech\Documents\Quran Flutter`.

## Phase status

| Phase | Implementation | Acceptance / outstanding work |
| --- | --- | --- |
| 1. Foundation | Complete for Android and JavaScript web; iOS scaffold/configuration present | iOS compilation, signing and device acceptance need macOS/Xcode and the owner's Apple team. |
| 2. Reader | Surah/Juz/page navigation, Arabic Quran search, color-group bookmarks, last-read state and themed reader implemented | Home shortcut routing corrected in this audit. Wider device/display acceptance remains in phase 7. |
| 3. Tafsir, translations and listening | All 44 text resources verified; reciter playback, mobile Surah downloads, browser text downloads and word playback implemented | Catalogue grouping corrected without changing cached-file formats. Audio still uses external recitation providers; browser offline audio is not implemented. |
| 4. Khatmah and memorization | Plans, daily targets, pause/resume, Ayah ranges, repeats/delays, hide/reveal and revision markers implemented | Real-device background audio and reminder delivery must be checked before store release. |
| 5. Optional account and reminders | Guest-first accounts, explicit manual backup/restore, preferences, bookmarks and progress implemented | Not automatic synchronization. Notes/audio are not backed up. Recovery and device-session management are not yet implemented. |
| 6. Connected deployment | HTTPS web/content/API deployed; isolated account backup/deletion and PostgreSQL readiness verified | Persistent database storage is not off-server disaster recovery; see phase 8. |
| 7. Offline/accessibility | Browser offline preparation, verified text caches, staged updates, keyboard/semantic controls and large-text layouts implemented | Real-browser outage and Android-emulator airplane-mode checks passed. Physical phones, Safari/iOS, storage eviction and full assistive-technology acceptance are not complete. |
| 8. Public release | Signing guard, key template, font attribution and release checklist prepared | Blocked on owner setup and platform access listed below. Not complete and not store-ready. |

## Gaps closed in this audit

- [x] Home's Browse Surahs, Search and Bookmarks open their own reader panels.
- [x] Separate 35 commentary books from 9 translations. Preserve all 44 original
  filenames, content bytes, list positions and legacy parser/download flags.
- [x] Add bookmarks to cloud snapshots, including color, title and exact Ayah/page
  identity. Old snapshots without bookmarks leave device bookmarks untouched.
- [x] Validate all included restore fields before writes. Reject duplicate IDs,
  invalid references and malformed server envelopes with controlled errors.
- [x] Persist bookmark replacement before changing the visible list; prevent
  same-instant bookmark ID collisions and duplicate controller reloads.
- [x] Bundle Bengali glyph coverage needed by the resource-language catalogue,
  retain its OFL license and expose open-source licenses in Settings.
- [x] Localize previously hard-coded bookmark counts and search-page labels.
- [x] Require private production signing or an explicit test-signing flag.
- [x] Verify narrow Home layouts at 2x text in Arabic, English and Spanish.

Restore preflight is comprehensive validation, not a cross-repository transaction:
an unexpected device-storage failure midway through applying valid data can still
leave some fields restored. Cloud backups remain explicit replacement snapshots.

## Owner-dependent completion gates

- [ ] Choose recovery-email provider and sender; configure secrets privately in
  Coolify. Then implement one-use/expiring reset links, abuse protection, old-session
  revocation and verify actual email delivery. No provider was supplied.
- [ ] Supply a private off-server backup destination, retention/deletion policy
  and encryption-key custody. Then configure scheduling and failure notifications,
  and prove an isolated database restore. Do not publish user backups in Git.
- [ ] Supply public privacy contact and approve accurate disclosures covering
  stored account data, backups, existing CDN analytics and external audio providers.
- [ ] Supply owner-controlled Android signing configuration and Google Play account.
  Do not publish the test APK. Do not change the app ID of existing installations.
- [ ] Provide macOS/Xcode, Apple team and iOS devices for build/signing/acceptance.
- [ ] Complete physical-device installation/upgrade, offline, audio interruption,
  permission denial, reminders and accessibility checks in RELEASE.md.
- [ ] Resolve old public-browser cache delivery through an owner-approved route.
  No Cloudflare cache purge or dashboard changes were performed in this audit.

## Earlier vision not promised as complete

The eight-phase implementation does not yet deliver personal notes, arbitrary
named bookmark categories, generated Ayah-image/deep-link sharing, full
translation/Tafsir search, grammar/morphology teaching, automatic conflict-merging
sync or device-session management. These remain product backlog items, not hidden
completed checkboxes. Offline recitations are mobile downloads, not a self-hosted
mirror of every reciter or a browser audio cache.

## Evidence and next action

See [deployment/VERIFICATION.md](deployment/VERIFICATION.md) for dated test,
artifact and deployment results; [deployment/RELEASE.md](deployment/RELEASE.md)
for publication gates; and [deployment/FONTS.md](deployment/FONTS.md) for font
provenance. The next release-gate work needs the owner's service choices above.
