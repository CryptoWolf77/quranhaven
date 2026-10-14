// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get corpusEmptyForm => 'No separate written form in the source';

  @override
  String get corpusAcquisition => 'Acquisition and provenance record';

  @override
  String get corpusLearning => 'Word morphology';

  @override
  String get corpusLearningBody =>
      'Explore the original Quranic Arabic Corpus v0.4 word segments, part-of-speech tags, roots and lemmas. This is a learning resource, not a replacement for the King Fahd Mushaf text.';

  @override
  String get corpusOffline => 'Bundled for offline learning';

  @override
  String get corpusWord => 'Word';

  @override
  String get corpusSegment => 'Segment';

  @override
  String get corpusPartOfSpeech => 'Part of speech';

  @override
  String get corpusRoot => 'Root';

  @override
  String get corpusLemma => 'Lemma';

  @override
  String get corpusOriginalForm => 'Original Buckwalter form';

  @override
  String get corpusOriginalCodes => 'Original feature codes';

  @override
  String get corpusSource => 'Source and license';

  @override
  String get corpusSourceBody =>
      'The original dataset and its notices are preserved unchanged. Word numbering and forms here follow the Corpus, independently of the Mushaf renderer. Raw codes are shown as recorded; this page does not generate interpretations or translations.';

  @override
  String get corpusLoadFailed =>
      'The complete learning resource could not be verified or loaded. No partial analysis is shown. Try again.';

  @override
  String get corpusPreviousAyah => 'Previous Ayah';

  @override
  String get corpusNextAyah => 'Next Ayah';

  @override
  String get corpusPrefix => 'Prefix';

  @override
  String get corpusStem => 'Stem';

  @override
  String get corpusSuffix => 'Suffix';

  @override
  String get corpusSourceDownload => 'Official source and updates';

  @override
  String get corpusTagsetDocs => 'Official part-of-speech documentation';

  @override
  String get corpusFeaturesDocs => 'Official morphology documentation';

  @override
  String get corpusBuckwalterDocs => 'Documented Buckwalter mapping';

  @override
  String get corpusTanzilSource => 'Tanzil text source and updates';

  @override
  String get corpusLicense => 'Full GNU GPL license for the dataset';

  @override
  String get corpusIdentity => 'Immutable dataset identity';

  @override
  String get corpusLinkCopied => 'Source link copied. Open it in your browser.';

  @override
  String get corpusGuideStep1 =>
      'Library → Word morphology opens the bundled Corpus learning page. You can also long-press an Ayah in the reader and choose Word morphology.';

  @override
  String get corpusGuideStep2 =>
      'Choose a Surah and Ayah, or use Previous/Next Ayah. Each original word is broken into its recorded segments, with tags, roots and lemmas when present.';

  @override
  String get corpusGuideStep3 =>
      'Original feature codes remain visible. Source and license opens the unchanged copyright notices, full license and official documentation links. This is morphology, not automated Tafsir or full syntactic parsing.';

  @override
  String get shareArabicSource =>
      'Quran text: King Fahd Glorious Quran Printing Complex.';

  @override
  String get audioDownloadSelection => 'Selected recording';

  @override
  String get corpusPosN => 'Noun';

  @override
  String get corpusPosPN => 'Proper noun';

  @override
  String get corpusPosADJ => 'Adjective';

  @override
  String get corpusPosIMPN => 'Imperative verbal noun';

  @override
  String get corpusPosPRON => 'Personal pronoun';

  @override
  String get corpusPosDEM => 'Demonstrative pronoun';

  @override
  String get corpusPosREL => 'Relative pronoun';

  @override
  String get corpusPosT => 'Time adverb';

  @override
  String get corpusPosLOC => 'Location adverb';

  @override
  String get corpusPosV => 'Verb';

  @override
  String get corpusPosP => 'Preposition';

  @override
  String get corpusPosDET => 'Determiner prefix';

  @override
  String get corpusPosEMPH => 'Emphatic lām prefix';

  @override
  String get corpusPosIMPV => 'Imperative lām prefix';

  @override
  String get corpusPosPRP => 'Purpose lām prefix';

  @override
  String get corpusPosCONJ => 'Coordinating conjunction';

  @override
  String get corpusPosSUB => 'Subordinating conjunction';

  @override
  String get corpusPosACC => 'Accusative particle';

  @override
  String get corpusPosAMD => 'Amendment particle';

  @override
  String get corpusPosANS => 'Answer particle';

  @override
  String get corpusPosAVR => 'Aversion particle';

  @override
  String get corpusPosCAUS => 'Particle of cause';

  @override
  String get corpusPosCERT => 'Particle of certainty';

  @override
  String get corpusPosCIRC => 'Circumstantial particle';

  @override
  String get corpusPosCOM => 'Comitative particle';

  @override
  String get corpusPosCOND => 'Conditional particle';

  @override
  String get corpusPosEQ => 'Equalization particle';

  @override
  String get corpusPosEXH => 'Exhortation particle';

  @override
  String get corpusPosEXL => 'Explanation particle';

  @override
  String get corpusPosEXP => 'Exceptive particle';

  @override
  String get corpusPosFUT => 'Future particle';

  @override
  String get corpusPosINC => 'Inceptive particle';

  @override
  String get corpusPosINT => 'Particle of interpretation';

  @override
  String get corpusPosINTG => 'Interrogative particle';

  @override
  String get corpusPosNEG => 'Negative particle';

  @override
  String get corpusPosPREV => 'Preventive particle';

  @override
  String get corpusPosPRO => 'Prohibition particle';

  @override
  String get corpusPosREM => 'Resumption particle';

  @override
  String get corpusPosRES => 'Restriction particle';

  @override
  String get corpusPosRET => 'Retraction particle';

  @override
  String get corpusPosRSLT => 'Result particle';

  @override
  String get corpusPosSUP => 'Supplemental particle';

  @override
  String get corpusPosSUR => 'Surprise particle';

  @override
  String get corpusPosVOC => 'Vocative particle';

  @override
  String get corpusPosINL => 'Quranic initials';

  @override
  String get backupNativeHint =>
      'On this mobile build, export copies JSON to the clipboard. File restore and PNG download are available on the website; native file tools are not yet enabled.';

  @override
  String get backupRecoveryFailed =>
      'Storage refused both restore and rollback. Recovery may be incomplete. Keep your safety copy; do not clear app/site data.';

  @override
  String get guidePersonalTitle => 'Notes and collections';

  @override
  String get guidePersonalStep1 =>
      'Open Library → My Quran space. Create a note linked to a Surah and Ayah, or create a named collection.';

  @override
  String get guidePersonalStep2 =>
      'Long-press an Ayah in the reader, then choose Add a note or Add to collection. Existing color bookmarks still work.';

  @override
  String get guidePersonalStep3 =>
      'Use Edit to change text or a collection name. Open Ayah returns to the reader; deletions ask for confirmation.';

  @override
  String get guideBackupStep1 =>
      'In Settings → Local backup, export the JSON file and keep it privately in a safe location. It contains personal text, not downloaded audio or books.';

  @override
  String get guideBackupStep2 =>
      'Choose a backup file or paste its JSON. Review its date and item counts; invalid or oversized files are rejected without changes.';

  @override
  String get guideBackupStep3 =>
      'Save a safety copy, then explicitly confirm replacement. The backup replaces current data instead of merging it. On the website choose Reload; in the phone app close the confirmation to refresh. Reminders remain disabled.';

  @override
  String get guideShareSearchTitle => 'Share an Ayah and search books';

  @override
  String get guideShareSearchStep1 =>
      'Long-press an Ayah → Share Ayah. Preview the complete Arabic text, optionally select a saved translation, then save PNG or copy text/link.';

  @override
  String get guideShareSearchStep2 =>
      'The public link opens the exact Surah and Ayah. Your private note and collection data is never included in the link or image.';

  @override
  String get guideShareSearchStep3 =>
      'Library → Search saved books searches the whole chosen Tafsir or translation, not only the current page. Enter at least two characters; use result paging and Open Ayah.';

  @override
  String get guideSavedAudioStep1 =>
      'In Library → Recitations, choose a Surah. The reader’s reciter selection determines the recording to download.';

  @override
  String get guideSavedAudioStep2 =>
      'Press Download for offline, watch progress, or cancel. Only complete verified recordings are saved; downloading never starts playback.';

  @override
  String get guideSavedAudioStep3 =>
      'Saved Surah recordings has Play and Delete actions. Prepare the offline app separately in Settings so the site can reopen without internet.';

  @override
  String get browserAudioTitle => 'Saved Surah recordings';

  @override
  String get browserAudioBody =>
      'Download one complete Surah for the selected reciter. This is separate from the offline app and word-by-word audio. Playback starts only when you press Play. Browser storage can be cleared or evicted.';

  @override
  String get browserAudioEmpty =>
      'No Surah recordings are saved in this browser yet.';

  @override
  String get browserAudioUnavailable =>
      'Persistent audio storage is unavailable in this browser. Online playback remains available.';

  @override
  String get browserAudioStorageFull =>
      'There is not enough browser storage. Remove a saved recording and try again.';

  @override
  String get browserAudioCancelled =>
      'Download cancelled. No partial recording was saved.';

  @override
  String get browserAudioDelete =>
      'Remove this recording from this browser? Other recordings and your personal data are kept.';

  @override
  String get browserAudioBusy => 'Another audio download is in progress.';

  @override
  String get browserAudioTooLarge =>
      'This recording exceeds the per-file download limit (256 MB).';

  @override
  String get personalTools => 'My Quran space';

  @override
  String get personalToolsBody =>
      'Your notes and named collections stay on this device.';

  @override
  String get personalNotes => 'Ayah notes';

  @override
  String get personalCollections => 'Collections';

  @override
  String get addNote => 'Add a note';

  @override
  String get editNote => 'Edit note';

  @override
  String get noteTitle => 'Title (optional)';

  @override
  String get noteBody => 'Your reflection';

  @override
  String get notesEmpty =>
      'Keep a reflection beside an Ayah. Add a note here or from the reader’s Ayah menu.';

  @override
  String get createCollection => 'Create collection';

  @override
  String get editCollection => 'Rename collection';

  @override
  String get collectionName => 'Collection name';

  @override
  String get collectionsEmpty =>
      'Organize Ayahs into your own named collections. Existing color bookmarks remain unchanged.';

  @override
  String get collectionEmpty =>
      'No Ayahs yet. Add one from the reader or use Add Ayah.';

  @override
  String get addAyah => 'Add Ayah';

  @override
  String get openAyah => 'Open Ayah';

  @override
  String get removeAyah => 'Remove Ayah';

  @override
  String get addToCollection => 'Add to collection';

  @override
  String get deletePersonalConfirm =>
      'Delete this item from this device? This cannot be undone.';

  @override
  String get personalSaved => 'Saved on this device.';

  @override
  String get personalDuplicate => 'This Ayah is already in the collection.';

  @override
  String get personalLimit =>
      'The local collection or note limit has been reached. Export a backup before removing old items.';

  @override
  String get requiredText => 'Enter text to continue.';

  @override
  String get invalidAyahLink =>
      'This Ayah link is not valid. Your last reading position has been kept.';

  @override
  String get backupTitle => 'Local backup';

  @override
  String get backupBody =>
      'Export a private JSON file for notes, collections, bookmarks, plans and reading settings. Audio and downloaded books are not included. Keep it somewhere safe; no copy is sent to a server.';

  @override
  String get exportBackup => 'Export backup';

  @override
  String get chooseBackup => 'Choose backup file';

  @override
  String get pasteBackup => 'Paste backup JSON';

  @override
  String get previewBackup => 'Preview backup';

  @override
  String get restoreBackup => 'Replace with this backup';

  @override
  String get backupPreviewTitle => 'Review before restoring';

  @override
  String get backupReplaceWarning =>
      'This replaces the notes, collections, color bookmarks, plans and reader settings on this device. It does not merge them. Download a safety copy first. Reminders will be disabled until you enable them again.';

  @override
  String get backupSafetyCopy => 'Download safety copy';

  @override
  String get backupSafetyReady =>
      'Safety copy prepared. Keep the downloaded file before confirming.';

  @override
  String get backupInvalid =>
      'This file is invalid, unsupported or larger than 5 MB. Nothing was changed.';

  @override
  String get backupFailed =>
      'The operation failed. Your existing data was kept or restored. Keep your safety copy and try again.';

  @override
  String get backupRestored =>
      'Backup restored. Reload the app to use the restored settings and plans.';

  @override
  String get backupRestoredNative =>
      'Backup restored. Close this confirmation to load the restored data. Reminders remain off.';

  @override
  String get reloadApp => 'Reload app';

  @override
  String get backupCopied => 'Private backup copied. Save it to a safe file.';

  @override
  String get backupCreated => 'Created';

  @override
  String get shareAyah => 'Share Ayah';

  @override
  String get shareBody =>
      'Preview the complete Ayah, then save an image or copy its text or public link.';

  @override
  String get includeTranslation => 'Include translation';

  @override
  String get withoutTranslation => 'Arabic only';

  @override
  String get downloadAyahImage => 'Save Ayah image';

  @override
  String get copyShareText => 'Copy full text';

  @override
  String get copyAyahLink => 'Copy Ayah link';

  @override
  String get shareCopied => 'Copied to the clipboard.';

  @override
  String get shareFailed =>
      'Could not prepare or save the image. You can still copy the text or link.';

  @override
  String get shareSource =>
      'Quran text: King Fahd Quran Complex. Translation resource identified above.';

  @override
  String get savedTextSearch => 'Search saved books';

  @override
  String get savedTextSearchBody =>
      'Search every Ayah in a bundled or downloaded Tafsir or translation. No book is downloaded automatically and your reader selection is not changed.';

  @override
  String get searchBook => 'Book to search';

  @override
  String get searchPhrase => 'Word or phrase (at least 2 characters)';

  @override
  String get searchMinimum => 'Enter at least two characters.';

  @override
  String get searchNoResults => 'No matching Ayahs in this book.';

  @override
  String get searchSavedOnly =>
      'Only bundled and downloaded books appear here. Download more from the Library.';

  @override
  String get searchResults => 'Results';

  @override
  String get previousResults => 'Previous results';

  @override
  String get nextResults => 'Next results';

  @override
  String get searchLoadFailed =>
      'This saved book could not be read. Try again, or remove and download it again from the Library.';

  @override
  String get quranTextTab => 'Quran';

  @override
  String get localSaveFailed =>
      'Your change could not be saved on this device. The last saved state is kept. Check available storage and try again.';

  @override
  String get localLoadFailed =>
      'Local progress could not be read. No saved data has been replaced. Enable site storage and try again.';

  @override
  String get retry => 'Try again';

  @override
  String get planOptions => 'Plan options';

  @override
  String get tenRecitationsTab => 'Ten readings';

  @override
  String get readerModeDefault => 'Mushaf';

  @override
  String get readerModeScrollable => 'Scrollable page';

  @override
  String get readerModeDual => 'Dual page';

  @override
  String get readerModeTafsir => 'Quran and Tafsir';

  @override
  String get readerModeAyahTafsir => 'Ayah with Tafsir';

  @override
  String get appName => 'Quran';

  @override
  String get home => 'Home';

  @override
  String get quran => 'Quran';

  @override
  String get library => 'Library';

  @override
  String get plans => 'Plans';

  @override
  String get settings => 'Settings';

  @override
  String get greeting => 'Peace be upon you';

  @override
  String get heroTitle => 'A quiet place for the Quran';

  @override
  String get heroBody =>
      'Read, listen, reflect, and build a lasting daily practice — completely free.';

  @override
  String get startReading => 'Open the Mushaf';

  @override
  String lastReadPage(int page) {
    return 'Last read · Page $page';
  }

  @override
  String get quickAccess => 'Quick access';

  @override
  String get browseSurahs => 'Browse Surahs';

  @override
  String get searchQuran => 'Search Quran';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get downloads => 'Downloads';

  @override
  String get dailyJourney => 'Your daily journey';

  @override
  String get dailyJourneyBody =>
      'Create a Khatmah plan and keep your memorization goals moving.';

  @override
  String get comingSoon => 'Coming in a later phase';

  @override
  String get charityMessage => 'Free for everyone as Sadakah Jariyah.';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Appearance';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get about => 'About this project';

  @override
  String get aboutBody =>
      'A charitable Quran platform with no advertisements, subscriptions, or locked features.';

  @override
  String get index => 'Index';

  @override
  String get search => 'Search';

  @override
  String get surahs => 'Surahs';

  @override
  String get juz => 'Juz';

  @override
  String get hizb => 'Hizb';

  @override
  String get sajda => 'Prostration';

  @override
  String get searchHint => 'Search Quran text or Surah';

  @override
  String get noBookmarks => 'No bookmarks yet. Long-press an Ayah to save one.';

  @override
  String get yellowBookmarks => 'Yellow bookmarks';

  @override
  String get redBookmarks => 'Red bookmarks';

  @override
  String get greenBookmarks => 'Green bookmarks';

  @override
  String get ayahCopied => 'Ayah copied';

  @override
  String get quickNavigate => 'Quick navigation';

  @override
  String get page => 'Page';

  @override
  String get goToPage => 'Go to page';

  @override
  String get pageRangeHint => 'Enter a page from 1 to 604';

  @override
  String get invalidPage => 'Enter a page number from 1 to 604';

  @override
  String get readerMenuHint =>
      'The reader menu includes the Surah and Juz index, Quran search, and saved bookmarks.';

  @override
  String juzNumber(int number) {
    return 'Juz $number';
  }

  @override
  String get contentLibrary => 'Quran library';

  @override
  String get contentLibraryBody =>
      'Choose Tafsir and translations, listen to recitations, and prepare content for offline use.';

  @override
  String get tafsir => 'Tafsir';

  @override
  String get translations => 'Translations';

  @override
  String get recitations => 'Recitations';

  @override
  String get selected => 'Selected';

  @override
  String get available => 'Available';

  @override
  String get download => 'Download';

  @override
  String get downloading => 'Downloading…';

  @override
  String get select => 'Select';

  @override
  String get resourceReady => 'The selected resource is ready in the reader.';

  @override
  String get resourceFailed =>
      'The resource could not be prepared. Check your connection and try again.';

  @override
  String get resourceHint =>
      'Downloaded resources remain available without an internet connection on mobile.';

  @override
  String get chooseSurah => 'Choose a Surah';

  @override
  String get play => 'Play';

  @override
  String get resumeListening => 'Resume listening';

  @override
  String get downloadForOffline => 'Download for offline';

  @override
  String get cancelDownload => 'Cancel download';

  @override
  String get downloadComplete => 'The Surah is ready for offline listening.';

  @override
  String get downloadFailed =>
      'The audio download failed. Check your connection and storage.';

  @override
  String get openReaderControls => 'Open reader audio controls';

  @override
  String get readerAudioHint =>
      'Use the reader audio controls to choose a reciter and manage downloaded Surahs.';

  @override
  String get webOfflineNote =>
      'On web, selected Tafsir and translations can be saved in this browser (up to 160 MiB). Save Surah audio separately under Recitations. Browsers may remove saved files if storage is low. Prepare the app and Quran pages separately in Settings.';

  @override
  String get webResourceStorageUnavailable =>
      'This browser cannot save reading resources. Use a supported browser with site storage enabled.';

  @override
  String get readers => 'Reciters';

  @override
  String get downloadedSurahs => 'Downloaded Surahs';

  @override
  String get chooseReader => 'Choose a reciter';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get ayahSingular => 'Ayah';

  @override
  String get ayahPlural => 'Ayahs';

  @override
  String get lastListen => 'Last listened';

  @override
  String get translation => 'Translation';

  @override
  String get footnotes => 'Footnotes';

  @override
  String get tafsirEmpty =>
      'Download or select a Tafsir or translation to view it here.';

  @override
  String get plansTitle => 'Your Quran journey';

  @override
  String get plansBody =>
      'Plan a Khatmah, practise memorization, and keep steady progress at your own pace.';

  @override
  String get khatmah => 'Khatmah';

  @override
  String get memorization => 'Memorization';

  @override
  String get noKhatmah => 'Begin a Khatmah plan';

  @override
  String get noKhatmahBody =>
      'Choose a completion period and the app will calculate a manageable daily reading target.';

  @override
  String get createKhatmah => 'Create Khatmah plan';

  @override
  String get createKhatmahBody =>
      'Set a comfortable target. You can pause the plan or adjust its date at any time.';

  @override
  String get completionPeriod => 'Completion period';

  @override
  String daysCount(int days) {
    return '$days days';
  }

  @override
  String get ramadanPlan => 'Ramadan plan';

  @override
  String get ramadanPlanBody => 'A focused 30-day Quran completion plan.';

  @override
  String get continueFromLastRead => 'Continue from my last-read page';

  @override
  String startAtPage(int page) {
    return 'Count progress from page $page';
  }

  @override
  String get startPlan => 'Start plan';

  @override
  String get activeKhatmah => 'Active Khatmah';

  @override
  String get ramadanKhatmah => 'Ramadan Khatmah';

  @override
  String get paused => 'Paused';

  @override
  String targetDate(String date) {
    return 'Target: $date';
  }

  @override
  String get adjustDate => 'Adjust target date';

  @override
  String get deletePlan => 'Delete plan';

  @override
  String get deletePlanBody =>
      'This Khatmah progress will be removed from this device.';

  @override
  String pagesOfTotal(int completed, int total) {
    return '$completed of $total pages';
  }

  @override
  String get pagesToday => 'Pages today';

  @override
  String get pagesRemaining => 'Pages remaining';

  @override
  String get daysRemaining => 'Days remaining';

  @override
  String get completeToday => 'Complete today\'s target';

  @override
  String get khatmahComplete => 'Khatmah complete';

  @override
  String get updateProgress => 'Update progress';

  @override
  String get pagesCompleted => 'Pages completed';

  @override
  String get pausePlan => 'Pause plan';

  @override
  String get resumePlan => 'Resume plan';

  @override
  String get progressSavedLocally =>
      'Your progress is saved locally and remains available offline.';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get noMemorization => 'Create a memorization range';

  @override
  String get noMemorizationBody =>
      'Select a Surah and Ayah range, then practise with repetition, hidden text, and revision markers.';

  @override
  String get createMemorization => 'Create memorization plan';

  @override
  String get createMemorizationBody =>
      'Choose a focused Ayah range and your preferred repetition pattern.';

  @override
  String get newRange => 'New range';

  @override
  String get startAyah => 'Start Ayah';

  @override
  String get endAyah => 'End Ayah';

  @override
  String get repetitionsPerAyah => 'Repetitions per Ayah';

  @override
  String get rangeRepetitions => 'Full-range repetitions';

  @override
  String get delayBetween => 'Delay between repetitions';

  @override
  String secondsCount(int seconds) {
    return '$seconds sec';
  }

  @override
  String get startWithAyahHidden => 'Start practice with the Ayah hidden';

  @override
  String get startMemorizing => 'Start memorizing';

  @override
  String ayahRangeError(int maximum) {
    return 'Enter an Ayah from 1 to $maximum';
  }

  @override
  String get endBeforeStart =>
      'The ending Ayah must be after the starting Ayah.';

  @override
  String ayahRange(int start, int end) {
    return 'Ayahs $start–$end';
  }

  @override
  String currentAyah(int ayah) {
    return 'Current Ayah · $ayah';
  }

  @override
  String get ayahHidden => 'Recite from memory, then reveal the Ayah to check.';

  @override
  String get hideAyah => 'Hide Ayah';

  @override
  String get revealAyah => 'Reveal Ayah';

  @override
  String repeatCount(int count) {
    return 'Repeat ×$count';
  }

  @override
  String delayCount(int seconds) {
    return '${seconds}s delay';
  }

  @override
  String get repeatCurrent => 'Repeat current Ayah';

  @override
  String get repeatRange => 'Repeat full range';

  @override
  String get stop => 'Stop';

  @override
  String get openInMushaf => 'Open in Mushaf';

  @override
  String get markForRevision => 'Mark for revision';

  @override
  String get markMemorized => 'Mark memorized';

  @override
  String get memorized => 'Memorized';

  @override
  String get deleteMemorizationBody =>
      'This memorization range and its progress will be removed from this device.';

  @override
  String get audioFailed =>
      'Practice audio could not be played. Check your connection and try again.';

  @override
  String get previousAyah => 'Previous Ayah';

  @override
  String get nextAyah => 'Next Ayah';

  @override
  String get removeRevisionMarker => 'Remove revision marker';

  @override
  String get dailyReminder => 'Daily reading reminder';

  @override
  String get remindMeDaily => 'Remind me every day';

  @override
  String get reminderBody => 'Receive one gentle reminder at your chosen time.';

  @override
  String get reminderMobileOnly =>
      'Scheduled reminders are currently available in the Android and iOS apps.';

  @override
  String reminderTime(String time) {
    return 'Reminder time: $time';
  }

  @override
  String get dailyReminderTitle => 'A moment with the Quran';

  @override
  String get dailyReminderBody =>
      'Take a peaceful moment to read, listen, or review today.';

  @override
  String get reminderEnabled => 'Your daily Quran reminder is active.';

  @override
  String get reminderUpdateFailed =>
      'The reminder could not be scheduled or updated. Check notification settings and try again.';

  @override
  String get reminderStateUncertain =>
      'The reminder state could not be recovered safely. Check notification settings and reopen the app before relying on it.';

  @override
  String get notificationDenied => 'Notification permission was not granted.';

  @override
  String get contentServerNotConfigured =>
      'The Quran, included Tafsir and saved downloads are available. Additional reading resources will be available when the content service is connected.';

  @override
  String get offlineTitle => 'Offline reading';

  @override
  String get offlineBody =>
      'Save the app and Quran pages on this browser before going offline. Tafsir and translations can be saved separately in Library. Audio is not included.';

  @override
  String get offlinePrepare => 'Prepare offline reading';

  @override
  String get offlinePreparing => 'Saving Quran for offline reading…';

  @override
  String get offlineReady => 'Ready for offline reading';

  @override
  String get offlineUpdateReady => 'An offline update is ready';

  @override
  String get offlineActivate => 'Apply update and reload';

  @override
  String get offlineCancel => 'Cancel download';

  @override
  String get offlineRemove => 'Remove offline app files';

  @override
  String get offlineRemoveWarning =>
      'Remove only the saved app and Quran page files from this browser? Your reading progress and saved Tafsir are kept. You will need internet to reopen the app.';

  @override
  String get offlineRemoved => 'Offline app files removed';

  @override
  String get offlineUnavailable =>
      'Offline preparation is unavailable in this browser. Try a supported browser over HTTPS.';

  @override
  String get offlineError =>
      'Offline preparation could not finish. Check your connection and available storage, then try again.';

  @override
  String get offlineOtherTabs =>
      'Close other Quran Haven tabs, then apply the update again.';

  @override
  String get offlineActivationTimeout =>
      'The update could not activate yet. Reload this tab and try again.';

  @override
  String get offlineStorageWarning =>
      'The browser may remove saved files when storage is low. Check this screen before relying on offline reading.';

  @override
  String offlineProgress(String completed, String total) {
    return '$completed / $total MB saved';
  }

  @override
  String get offlineNotReady => 'Not prepared for offline reading';

  @override
  String get offlineCancelled =>
      'Download cancelled. A previously prepared version, if any, is kept.';

  @override
  String get localStorageTitle => 'On-device storage';

  @override
  String get localStorageBody =>
      'Your bookmarks, last-read position, plans, settings and downloads are saved only on this device or in this browser. There are no accounts, cloud backups or cross-device sync. Uninstalling the app or clearing its data/site storage can erase these saved items.';

  @override
  String get guideStartHere => 'START HERE';

  @override
  String get guideChooseLesson => 'Choose your next lesson';

  @override
  String guideLesson(int number, int total) {
    return 'Lesson $number of $total';
  }

  @override
  String get guideWrittenSteps => 'Follow along, step by step';

  @override
  String get guidePauseVideo => 'Pause video';

  @override
  String get guideRestartVideo => 'Restart video';

  @override
  String get guideFullScreen => 'Full-screen view';

  @override
  String get guideSeekVideo => 'Video position';

  @override
  String get guideVideoLoading => 'Preparing your lesson…';

  @override
  String get guideVideoRetry => 'Retry video';

  @override
  String get guideVideoFinished => 'Lesson complete. Replay whenever you need.';

  @override
  String get guideVideoHint =>
      'Follow the highlighted pointer and numbered instructions. Nothing plays until you choose Play.';

  @override
  String get guideNativeFiles =>
      'On Android, choose a private save location in the system document chooser. On iOS, use the system share sheet to save or share the file. Use the document chooser to restore a JSON backup.';

  @override
  String get guideNativeShareImage => 'Save or share Ayah image';

  @override
  String get guideNativeSaveImage => 'Save Ayah image';

  @override
  String get privacyTitle => 'Privacy and contact';

  @override
  String get privacyLocalSummary =>
      'Quran Haven is free and has no accounts or advertising. Your bookmarks, notes, plans, reading position and preferences stay on this device or in this browser. Clearing app or browser data may erase them. Backup export, file restore and sharing happen only when you choose them; you control the destination.';

  @override
  String get privacyNetworkSummary =>
      'Online reading resources and recitations contact the project host and audio/content providers. These requests reveal network information such as your IP address and requested files; providers may keep technical access logs. The website also uses a Cloudflare beacon for performance and usage analytics. Your personal notes and progress are not automatically uploaded.';

  @override
  String get privacyOpen => 'Read the full privacy policy';

  @override
  String get contactProject => 'Contact the project';

  @override
  String get copyContactEmail => 'Copy contact email';

  @override
  String get privacyLinkCopied =>
      'The address was copied. Open it in your browser or email app.';

  @override
  String get privacyLinkFailed =>
      'The address could not be opened or copied. Use the address shown here.';

  @override
  String get backupSafetyConfirm =>
      'I have saved the safety copy in a private place.';

  @override
  String get backupRefreshFailed =>
      'Your backup was restored. Close and reopen the app to load the restored data.';

  @override
  String get guideTitle => 'How to use Quran Haven';

  @override
  String get guideOpen => 'Open the guide';

  @override
  String get guideEntryBody =>
      'Short visual demonstrations and practical steps for reading, listening and building a daily practice.';

  @override
  String get guideIntroTitle => 'Your journey, one step at a time';

  @override
  String get guideIntro =>
      'Start with the Mushaf, then explore the tools that support your reading. These instructions describe the features available now, with separate guidance for the website and phone app.';

  @override
  String get guideMediaHint =>
      'Demonstrations stay still until you choose Play. Every demonstration has written steps below it.';

  @override
  String get guideGoodToKnow => 'Good to know';

  @override
  String get guidePlayDemo => 'Play demonstration';

  @override
  String get guideStopDemo => 'Stop demonstration';

  @override
  String get guideMediaUnavailable =>
      'Demonstration unavailable. Follow the written steps below.';

  @override
  String get guideReducedMotion =>
      'Reduced motion is enabled. The preview remains still; you may choose Play if you wish.';

  @override
  String guideDemoDescription(String topic) {
    return 'Screen demonstration: $topic';
  }

  @override
  String get guideReadingTitle => 'Read and find your place';

  @override
  String get guideReadingStep1 =>
      'From Home, choose Open the Mushaf to continue at your last-read page.';

  @override
  String get guideReadingStep2 =>
      'Open Quick navigation in the reader. Choose a Surah or Juz, or enter a page number from 1 to 604 and choose Go to page.';

  @override
  String get guideReadingStep3 =>
      'Use page arrows on the website, or swipe on a touch device to change pages. Your last-read position is saved automatically on this device.';

  @override
  String get guideReadingTip =>
      'The Quran remains Arabic when you change the interface language. You do not need an account to read.';

  @override
  String get guideSearchTitle => 'Search and save bookmarks';

  @override
  String get guideSearchStep1 =>
      'Choose Search Quran on Home, or open Search in the reader. Enter a word or phrase from the Arabic Quran.';

  @override
  String get guideSearchStep2 =>
      'Select a search result. The panel closes and opens the Mushaf at that Ayah automatically. Press and hold an Ayah to open its actions.';

  @override
  String get guideSearchStep3 =>
      'Choose a bookmark color from the Ayah actions. Open Bookmarks to return to your saved Ayahs.';

  @override
  String get guideSearchTip =>
      'Search currently covers the Arabic Quran, not Tafsir or translations. Bookmarks use the existing yellow, red and green groups.';

  @override
  String get guideLibraryTitle => 'Choose Tafsir and translations';

  @override
  String get guideLibraryStep1 =>
      'Open Library, then choose Tafsir or Translations.';

  @override
  String get guideLibraryStep2 =>
      'Use Download for an additional resource, or Select for one already available. Wait for the ready confirmation.';

  @override
  String get guideLibraryStep3 =>
      'Return to the Mushaf, press and hold an Ayah and open its Tafsir action to read the selected resource.';

  @override
  String get guideLibraryTip =>
      'Interface language and reading resource are independent. Saved resources can be read offline; browser storage must be available.';

  @override
  String get guideAudioTitle => 'Listen to recitations';

  @override
  String get guideAudioStep1 =>
      'Open the reader audio controls to choose a reciter. Different controls may offer different reciter lists.';

  @override
  String get guideAudioStep2 =>
      'In Library, choose Recitations, select a Surah and press Play. You can also play an Ayah from its actions in the Mushaf.';

  @override
  String get guideAudioStep3 =>
      'Use the audio player to pause or continue. Resume listening returns to the saved audio position when one is available.';

  @override
  String get guideAudioTip =>
      'Online audio comes from external recitation providers. Download complete Surah recordings separately under Recitations for offline listening; word-by-word audio still needs internet.';

  @override
  String get guideOfflineTitle => 'Prepare before going offline';

  @override
  String get guideOfflineStep1 =>
      'On the website, open Settings and choose Prepare offline reading. Keep the tab open until Ready for offline reading appears. The phone app includes the Mushaf.';

  @override
  String get guideOfflineStep2 =>
      'In Library, download the Tafsir and translations you want while connected. Offline app preparation does not download these additional resources or audio.';

  @override
  String get guideOfflineStep3 =>
      'In the phone app, choose a Surah under Library → Recitations and use Download for offline. Test your saved content without a connection before relying on it.';

  @override
  String get guideOfflineTip =>
      'Browsers may remove saved files when space is low. Private browsing is not suitable for lasting storage. App preparation, downloaded books and saved Surah recordings are separate downloads.';

  @override
  String get guidePlansTitle => 'Build a reading and memorization routine';

  @override
  String get guidePlansStep1 =>
      'Open Plans → Khatmah. Create a plan, choose a completion period and start it. Mark the daily reading only after you finish it.';

  @override
  String get guidePlansStep2 =>
      'Open Memorization and create a plan with a Surah, Ayah range, repetition count and delay.';

  @override
  String get guidePlansStep3 =>
      'Play the range, hide or reveal the text, and mark Ayahs as memorized or for revision. Use the previous and next controls to move within your range.';

  @override
  String get guidePlansTip =>
      'Plan progress is saved on this device. Audio repetition still needs a playable source or a supported saved download.';

  @override
  String get guideSettingsTitle => 'Make the experience comfortable';

  @override
  String get guideSettingsStep1 =>
      'In Settings → Language, choose العربية, English or Español. The guide and interface follow your choice.';

  @override
  String get guideSettingsStep2 =>
      'In Settings → Appearance, choose light, dark or the system setting.';

  @override
  String get guideSettingsStep3 =>
      'In the phone app, optionally enable a daily reminder, choose its time and grant notification permission.';

  @override
  String get guideSettingsTip =>
      'Daily reminder notifications are available on supported phones, not the website. You can turn them off again in Settings.';

  @override
  String get guideStorageTitle => 'Understand your local data';

  @override
  String get guideStorageStep1 =>
      'Bookmarks, reading position, plans, preferences and saved downloads remain on this device or in this browser. There is no account or cross-device sync.';

  @override
  String get guideStorageStep2 =>
      'Keep using the same browser profile to retain website data. Another device, browser or profile has its own separate data.';

  @override
  String get guideStorageTip =>
      'Clearing app/site data or losing the device can erase saved items. Use Local backup in Settings to export personal data privately; downloaded books and audio are not included.';

  @override
  String get playAyah => 'Play ayah';

  @override
  String get playFromAyah => 'Play from this ayah';

  @override
  String get copyAyah => 'Copy ayah';

  @override
  String get saveYellowBookmark => 'Save a yellow bookmark';

  @override
  String get saveRedBookmark => 'Save a red bookmark';

  @override
  String get saveGreenBookmark => 'Save a green bookmark';

  @override
  String get guideViewLarger => 'View larger';

  @override
  String get guideZoomHint =>
      'Pinch or scroll to zoom, then drag to move around the screen. Use Reset zoom to see the full demonstration again.';

  @override
  String get guideResetZoom => 'Reset zoom';

  @override
  String get guideRotateHint =>
      'Rotate your phone for a wider view, or zoom in and drag to inspect the demonstration.';

  @override
  String get guideZoomIn => 'Zoom in';

  @override
  String get guideZoomOut => 'Zoom out';

  @override
  String get creatorCreditTitle => 'Created by YahyazLab';

  @override
  String get quranBrandLabel => 'Quran Haven: open Quran book logo';

  @override
  String get creatorCreditHint => 'Creator’s external website';

  @override
  String get creatorCreditSemantics =>
      'Created by YahyazLab. Open the creator’s external website after confirmation.';

  @override
  String get creatorExternalTitle => 'You’re leaving Quran Haven';

  @override
  String get creatorExternalBody =>
      'This is the creator’s game-development portfolio, not a Quran-content website. It will open in your browser.';

  @override
  String get creatorGuardianReminder =>
      'Children: ask a parent or guardian before continuing.';

  @override
  String get creatorContinue => 'Continue to website';

  @override
  String get creatorOpenFailed =>
      'The external website could not be opened. You can keep using Quran Haven.';
}
