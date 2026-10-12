// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
      'On web, selected Tafsir and translations can be saved in this browser (up to 160 MiB); the browser may remove them if storage is low. Audio needs internet. Prepare the app and Quran pages separately in Settings.';

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
      'Animation is off because reduced motion is enabled on your device.';

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
      'Swipe between pages. Your last-read position is saved automatically on this device.';

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
      'Select a search result, then use Close at the top of the panel to return to the Mushaf at that Ayah. Press and hold an Ayah to open its actions.';

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
      'Online audio needs an internet connection and may come from external recitation providers. Browser offline audio downloads are not available.';

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
      'Browsers may remove saved files when space is low. Private browsing is not suitable for lasting storage. Offline audio is available in the phone app, not the website.';

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
      'Uninstalling the app, clearing app or site data, or losing the device can erase your saved items. A local export/import tool is not currently available.';

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
}
