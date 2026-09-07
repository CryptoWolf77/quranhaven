// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
      'Web playback streams online. Managed offline audio downloads are available in the Android and iOS apps.';

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
  String get accountAndSync => 'Account and cloud backup';

  @override
  String get cloudNotConfigured =>
      'Cloud accounts are ready in the app. They will become available when the project\'s private server address is connected.';

  @override
  String get cloudInvalidConfiguration =>
      'The cloud server address is not valid or secure. Cloud accounts are unavailable in this version; local Quran reading is unaffected.';

  @override
  String get accountOptionalBody =>
      'An account is optional. Create one only if you want to back up and restore your progress across devices.';

  @override
  String get cloudRegistrationNotice =>
      'An account is optional. Your email, display name and any progress you choose to back up are stored on the project\'s server. Creating or deleting an account does not change your local Quran reading or progress. Email verification and password recovery are not available yet, so store your password securely. Cloud backups are not end-to-end encrypted; the server operator can access them.';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteCloudAccount => 'Delete cloud account';

  @override
  String get deleteCloudAccountWarning =>
      'Delete your account and its progress backup from the server? This cannot be undone. Your downloaded Quran resources and progress on this device will remain. This also signs you out.';

  @override
  String get cloudAccountDeleted =>
      'Your cloud account and backup were deleted. Your local Quran data remains on this device.';

  @override
  String get displayName => 'Display name';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get passwordRules => 'Use at least 8 characters.';

  @override
  String get displayNameRequired => 'Enter at least 2 characters.';

  @override
  String get validEmailRequired => 'Enter a valid email address.';

  @override
  String get passwordTooShort =>
      'The password must contain at least 8 characters.';

  @override
  String get signedInSuccessfully => 'You are signed in.';

  @override
  String get backupNow => 'Back up now';

  @override
  String get backupComplete => 'Your Quran progress has been backed up.';

  @override
  String get restoreBackup => 'Restore backup';

  @override
  String get restoreBackupWarning =>
      'This will replace the last-read page, Khatmah progress and memorization progress stored on this device with the cloud copy.';

  @override
  String get restore => 'Restore';

  @override
  String get restoreComplete => 'Your cloud progress has been restored.';

  @override
  String get noCloudBackup => 'There is no cloud backup for this account yet.';

  @override
  String get cloudDataInvalid => 'The cloud backup could not be read safely.';

  @override
  String lastSynced(String date) {
    return 'Last backup or restore: $date';
  }

  @override
  String get accountPrivacyNote =>
      'Backups happen only when you choose Back up now. Quran reading works without an account.';

  @override
  String get invalidCredentials => 'The email or password is incorrect.';

  @override
  String get emailAlreadyUsed => 'An account already uses this email address.';

  @override
  String get accountValidationFailed =>
      'Check the account details and try again.';

  @override
  String get sessionExpired => 'Your session expired. Please sign in again.';

  @override
  String get cloudRateLimited =>
      'Too many cloud requests. Wait a moment and try again. Your local Quran data is unchanged.';

  @override
  String get cloudServerError =>
      'The cloud service had a problem. Please try again later.';

  @override
  String get cloudUnavailable =>
      'The cloud service cannot be reached. Your local Quran data is still safe.';

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
}
