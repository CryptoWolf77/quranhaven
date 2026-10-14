# Quran Haven — current implementation plan

Updated 2026-10-15: the owner cancelled accounts, cloud backup and synchronization.
All personal app data must stay on the user's device/browser. Public Quran
content hosting and recitation downloads remain in scope.

All features are free Sadakah Jariyah: no donations, payments, ads or premium.
Project folder: `C:\Users\ThaherTech\Documents\Quran Flutter`.

## Phase status

| Phase | Implementation | Remaining acceptance |
| --- | --- | --- |
| 1. Foundation | Android/web foundation and iOS configuration implemented | iOS build, signing and device checks need macOS/Xcode and Apple team access. |
| 2. Reader | Surah/Juz/page navigation, Arabic search, bookmarks, last-read persistence and reader customization implemented | Wider physical-device/display acceptance. |
| 3. Text/audio | 44 verified text resources, reciter selection/playback and local downloads; build15 adds verified browser Surah audio and fixes native download-only behavior | Final build15 public/native acceptance pending; audio uses external providers. |
| 4. Plans | Local Khatmah/memorization progress, targets, repetition, hide/reveal and revision markers implemented | Physical-device background audio acceptance. |
| 5. Local preferences/reminders | Local language/theme, plans, bookmarks and optional device reminders; cloud client removed in build 6 | Physical-phone upgrade and reminder delivery acceptance. |
| 6. Public content deployment | Local-only website build 13 published and verified over HTTPS on 2026-10-12; no personal-data API configuration | Old remote accounts are untouched; retirement requires a separate owner decision. |
| 7. Offline/accessibility | Browser preparation, verified caches, staged updates, keyboard/semantic controls and large-text layouts implemented | Physical phones, Safari/iOS, quota/eviction and full assistive-technology checks. |
| 8. Store release | Owner-authorized private Android upload key created; public contact/privacy source and release identity prepared | Google Play agreements/declarations, final production bundle/public acceptance and iOS platform access. |

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

- [x] Publish the local-only web build and verify actual browser delivery (build 6).
- [x] Publish and verify the build-7 guide and release-isolated offline downloads.
- [x] Supply owner-approved public privacy contact (`admin@yahyazlab.com`).
- [x] Prepare disclosures covering local storage, content/audio providers and
  existing website CDN analytics; verify ar/en/es narrow/large-text layouts.
- [x] Create an owner-authorized private Android upload key outside the repo.
- [ ] Complete Google Play target audience, rating, Data Safety, listing and
  production-review submission. The app and processed AAB15 now exist as drafts;
  specific owner-approved policy/export and Google-signing steps are complete.
- [ ] Provide macOS/Xcode, Apple team and physical iOS devices.
- [ ] Complete install/upgrade, offline, interruption/background audio, denied
  permissions, reminders, large-text and screen-reader acceptance.
- [x] Verify automated quota/eviction guards, isolated browser profiles and a real
  public multi-tab update with retained personal data (build 11 → 12).
- [ ] Complete physical Safari/iOS, vendor-specific private/storage policy and
  full assistive-technology acceptance; headless WebKit is not an iPhone test.

## Final current-web acceptance (build 13)

- [x] Publish the tested source through the **Quran Haven** website resource.
- [x] Check the five main screens in Chromium, Firefox and WebKit, three
  interface languages and desktop/tablet/phone viewports (27 combinations).
- [x] Verify all five reader display modes, page bounds, Arabic search, bookmark
  persistence, keyboard dismissal and downloaded translation removal.
- [x] Verify Khatmah creation/targets/pause/date/progress/deletion and memorization
  bounds/hide/reveal/revision/navigation/persistence in the public browser.
- [x] Verify real Surah and word-by-word audio with working Stop controls.
- [x] Verify all 44 hosted text resources and bounded first/last audio samples
  for all 29 Surah and 20 Ayah profiles; preserve downloaded audio paths/IDs.
- [x] Verify the guide in all three languages, 24 media hashes, optional playback,
  zoom/Escape, reduced motion and mobile layouts.
- [x] Fix false successful plan saves, locale-change warning timing, page-field
  focus theft, quick-navigation Escape and merged resource deletion semantics.
- [x] Show Tafsir loading/error feedback; verify actual Arabic Tafsir and
  downloaded Spanish verse text in all three interface languages.
- [x] Isolate bootstrap, worker and main JavaScript requests by release identity
  without changing CDN/security settings or clearing user data.
- [x] Hide unaudited Qiraat/grammar download panels instead of presenting them as
  completed features. Word-by-word memorization audio remains available.

This accepts the currently implemented web scope, not every backlog item or
every physical browser/device. See the dated evidence and limitations in
`deployment/VERIFICATION.md`.

## Usage guide and acceptance update (build 7)

- [x] Integrated guide with eight topics in Arabic, English and Spanish.
- [x] Twelve real-screen GIFs and twelve posters, explicit Play/Stop, enlarged
  zoom viewer, reduced-motion support and written steps.
- [x] Independent desktop/tablet/mobile design evaluation passed in all three
  languages; this was a same-provider evaluator, not an external-provider audit.
- [x] Android build repaired with a process-only Java temporary-socket path;
  test APK build 7 produced. Previous delivery APKs remain untouched.
- [x] Local real-browser navigation, Arabic search (55 results), translation
  persistence, Khatmah/memorization creation and offline reload in all languages.
- [x] Actual browser Surah playback, bookmark save/reload, Tafsir display and
  expanded-bookmark Escape closure verified.
- [x] Fix stale CDN asset integrity failures using a fixed release query key;
  keep canonical verified cache keys and bounded three-file downloads.
- [x] Publish `785ef16` through the correct Coolify **Quran Haven** website
  resource; verify public build 7 and all three languages with actual browser
  offline reloads. The Cloud resource was not changed or removed.
- [x] Upgrade a dedicated Android emulator in place from build 6 → 7 → 8;
  retain Spanish, page 2, a paused 21-page plan and downloaded Al-Fatihah.
- [x] Build 8 retains dynamically referenced audio-service icons that Android
  resource shrinking removed. Verify offline playback, background playback and
  media-key pause/resume in the emulator. Test signing only; physical devices
  and store signing remain open.

## Expanded local/web scope — build 15 published

- [x] Personal Ayah notes and arbitrary named Ayah collections, with durable
  local writes, edit/open/reload and confirmed removal.
- [x] Browser JSON export/import for whitelisted personal data, validated
  preview, explicit replacement, safety copy and rollback; no remote transfer.
- [x] Full canonical Ayah PNG/text/public-link sharing and validated deep links.
- [x] Whole-book search across bundled/downloaded Tafsir/translations without
  changing the reader resource or automatically downloading another book.
- [x] Explicit complete-Surah browser audio downloads, progress/cancel,
  MP3/hash/quota checks and separate per-recording removal.
- [x] Bundled original Quranic Arabic Corpus v0.4 morphology: 6,236 Ayahs,
  original segments, POS, roots/lemmas and feature codes; preserved notices and
  source/license dialog. No full syntactic parsing or word meanings claimed.
- [x] Complete 39 professional real-screen guide videos and 39 posters across
  13 topics in all three languages, with 318 annotated steps.
- [x] Add the shared Quran Haven book icon to Home, site/PWA, Android and iOS
  assets; retain the original YahyazLab logo with an explicit external link.
- [x] Complete independent design acceptance of the guide/UI/media, including
  zoom/reflow, actual seeks, large text and failed-video retry.
- [x] Publish and verify the expanded scope through the website resource.
- [x] Complete the scoped final public/browser functional acceptance for the
  expanded tools, all 39 online/cold-offline videos and 27 main-screen matrix
  combinations. Wider physical/device/assistive-technology gates remain above.

Final public build15 checks pass notes/collection CRUD and JSON safety-copy/
replacement/reload in all three languages, actual Ayah PNG/text/link, last-Surah
book search and cold-offline saved-Surah playback/seek. Native Android file
restore/PNG tools passed actual emulator round trips. The owner-approved
production AAB15 is uploaded to the new Quran Haven Play app as a draft;
physical-device/iOS/store-review gates remain open. Cloud storage is cancelled.

See [deployment/RELEASE.md](deployment/RELEASE.md) for publication gates,
[deployment/OFFLINE.md](deployment/OFFLINE.md) for offline boundaries, and
[deployment/VERIFICATION.md](deployment/VERIFICATION.md) for dated evidence.
