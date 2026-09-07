import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @quran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quran;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @plans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plans;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Peace be upon you'**
  String get greeting;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'A quiet place for the Quran'**
  String get heroTitle;

  /// No description provided for @heroBody.
  ///
  /// In en, this message translates to:
  /// **'Read, listen, reflect, and build a lasting daily practice — completely free.'**
  String get heroBody;

  /// No description provided for @startReading.
  ///
  /// In en, this message translates to:
  /// **'Open the Mushaf'**
  String get startReading;

  /// No description provided for @lastReadPage.
  ///
  /// In en, this message translates to:
  /// **'Last read · Page {page}'**
  String lastReadPage(int page);

  /// No description provided for @quickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get quickAccess;

  /// No description provided for @browseSurahs.
  ///
  /// In en, this message translates to:
  /// **'Browse Surahs'**
  String get browseSurahs;

  /// No description provided for @searchQuran.
  ///
  /// In en, this message translates to:
  /// **'Search Quran'**
  String get searchQuran;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @dailyJourney.
  ///
  /// In en, this message translates to:
  /// **'Your daily journey'**
  String get dailyJourney;

  /// No description provided for @dailyJourneyBody.
  ///
  /// In en, this message translates to:
  /// **'Create a Khatmah plan and keep your memorization goals moving.'**
  String get dailyJourneyBody;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming in a later phase'**
  String get comingSoon;

  /// No description provided for @charityMessage.
  ///
  /// In en, this message translates to:
  /// **'Free for everyone as Sadakah Jariyah.'**
  String get charityMessage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About this project'**
  String get about;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'A charitable Quran platform with no advertisements, subscriptions, or locked features.'**
  String get aboutBody;

  /// No description provided for @index.
  ///
  /// In en, this message translates to:
  /// **'Index'**
  String get index;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @surahs.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get surahs;

  /// No description provided for @juz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get juz;

  /// No description provided for @hizb.
  ///
  /// In en, this message translates to:
  /// **'Hizb'**
  String get hizb;

  /// No description provided for @sajda.
  ///
  /// In en, this message translates to:
  /// **'Prostration'**
  String get sajda;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Quran text or Surah'**
  String get searchHint;

  /// No description provided for @noBookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet. Long-press an Ayah to save one.'**
  String get noBookmarks;

  /// No description provided for @yellowBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Yellow bookmarks'**
  String get yellowBookmarks;

  /// No description provided for @redBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Red bookmarks'**
  String get redBookmarks;

  /// No description provided for @greenBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Green bookmarks'**
  String get greenBookmarks;

  /// No description provided for @ayahCopied.
  ///
  /// In en, this message translates to:
  /// **'Ayah copied'**
  String get ayahCopied;

  /// No description provided for @quickNavigate.
  ///
  /// In en, this message translates to:
  /// **'Quick navigation'**
  String get quickNavigate;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;

  /// No description provided for @goToPage.
  ///
  /// In en, this message translates to:
  /// **'Go to page'**
  String get goToPage;

  /// No description provided for @pageRangeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a page from 1 to 604'**
  String get pageRangeHint;

  /// No description provided for @invalidPage.
  ///
  /// In en, this message translates to:
  /// **'Enter a page number from 1 to 604'**
  String get invalidPage;

  /// No description provided for @readerMenuHint.
  ///
  /// In en, this message translates to:
  /// **'The reader menu includes the Surah and Juz index, Quran search, and saved bookmarks.'**
  String get readerMenuHint;

  /// No description provided for @juzNumber.
  ///
  /// In en, this message translates to:
  /// **'Juz {number}'**
  String juzNumber(int number);

  /// No description provided for @contentLibrary.
  ///
  /// In en, this message translates to:
  /// **'Quran library'**
  String get contentLibrary;

  /// No description provided for @contentLibraryBody.
  ///
  /// In en, this message translates to:
  /// **'Choose Tafsir and translations, listen to recitations, and prepare content for offline use.'**
  String get contentLibraryBody;

  /// No description provided for @tafsir.
  ///
  /// In en, this message translates to:
  /// **'Tafsir'**
  String get tafsir;

  /// No description provided for @translations.
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get translations;

  /// No description provided for @recitations.
  ///
  /// In en, this message translates to:
  /// **'Recitations'**
  String get recitations;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get downloading;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @resourceReady.
  ///
  /// In en, this message translates to:
  /// **'The selected resource is ready in the reader.'**
  String get resourceReady;

  /// No description provided for @resourceFailed.
  ///
  /// In en, this message translates to:
  /// **'The resource could not be prepared. Check your connection and try again.'**
  String get resourceFailed;

  /// No description provided for @resourceHint.
  ///
  /// In en, this message translates to:
  /// **'Downloaded resources remain available without an internet connection on mobile.'**
  String get resourceHint;

  /// No description provided for @chooseSurah.
  ///
  /// In en, this message translates to:
  /// **'Choose a Surah'**
  String get chooseSurah;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @resumeListening.
  ///
  /// In en, this message translates to:
  /// **'Resume listening'**
  String get resumeListening;

  /// No description provided for @downloadForOffline.
  ///
  /// In en, this message translates to:
  /// **'Download for offline'**
  String get downloadForOffline;

  /// No description provided for @cancelDownload.
  ///
  /// In en, this message translates to:
  /// **'Cancel download'**
  String get cancelDownload;

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'The Surah is ready for offline listening.'**
  String get downloadComplete;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'The audio download failed. Check your connection and storage.'**
  String get downloadFailed;

  /// No description provided for @openReaderControls.
  ///
  /// In en, this message translates to:
  /// **'Open reader audio controls'**
  String get openReaderControls;

  /// No description provided for @readerAudioHint.
  ///
  /// In en, this message translates to:
  /// **'Use the reader audio controls to choose a reciter and manage downloaded Surahs.'**
  String get readerAudioHint;

  /// No description provided for @webOfflineNote.
  ///
  /// In en, this message translates to:
  /// **'Web playback streams online. Managed offline audio downloads are available in the Android and iOS apps.'**
  String get webOfflineNote;

  /// No description provided for @readers.
  ///
  /// In en, this message translates to:
  /// **'Reciters'**
  String get readers;

  /// No description provided for @downloadedSurahs.
  ///
  /// In en, this message translates to:
  /// **'Downloaded Surahs'**
  String get downloadedSurahs;

  /// No description provided for @chooseReader.
  ///
  /// In en, this message translates to:
  /// **'Choose a reciter'**
  String get chooseReader;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @ayahSingular.
  ///
  /// In en, this message translates to:
  /// **'Ayah'**
  String get ayahSingular;

  /// No description provided for @ayahPlural.
  ///
  /// In en, this message translates to:
  /// **'Ayahs'**
  String get ayahPlural;

  /// No description provided for @lastListen.
  ///
  /// In en, this message translates to:
  /// **'Last listened'**
  String get lastListen;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @footnotes.
  ///
  /// In en, this message translates to:
  /// **'Footnotes'**
  String get footnotes;

  /// No description provided for @tafsirEmpty.
  ///
  /// In en, this message translates to:
  /// **'Download or select a Tafsir or translation to view it here.'**
  String get tafsirEmpty;

  /// No description provided for @plansTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Quran journey'**
  String get plansTitle;

  /// No description provided for @plansBody.
  ///
  /// In en, this message translates to:
  /// **'Plan a Khatmah, practise memorization, and keep steady progress at your own pace.'**
  String get plansBody;

  /// No description provided for @khatmah.
  ///
  /// In en, this message translates to:
  /// **'Khatmah'**
  String get khatmah;

  /// No description provided for @memorization.
  ///
  /// In en, this message translates to:
  /// **'Memorization'**
  String get memorization;

  /// No description provided for @noKhatmah.
  ///
  /// In en, this message translates to:
  /// **'Begin a Khatmah plan'**
  String get noKhatmah;

  /// No description provided for @noKhatmahBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a completion period and the app will calculate a manageable daily reading target.'**
  String get noKhatmahBody;

  /// No description provided for @createKhatmah.
  ///
  /// In en, this message translates to:
  /// **'Create Khatmah plan'**
  String get createKhatmah;

  /// No description provided for @createKhatmahBody.
  ///
  /// In en, this message translates to:
  /// **'Set a comfortable target. You can pause the plan or adjust its date at any time.'**
  String get createKhatmahBody;

  /// No description provided for @completionPeriod.
  ///
  /// In en, this message translates to:
  /// **'Completion period'**
  String get completionPeriod;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String daysCount(int days);

  /// No description provided for @ramadanPlan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan plan'**
  String get ramadanPlan;

  /// No description provided for @ramadanPlanBody.
  ///
  /// In en, this message translates to:
  /// **'A focused 30-day Quran completion plan.'**
  String get ramadanPlanBody;

  /// No description provided for @continueFromLastRead.
  ///
  /// In en, this message translates to:
  /// **'Continue from my last-read page'**
  String get continueFromLastRead;

  /// No description provided for @startAtPage.
  ///
  /// In en, this message translates to:
  /// **'Count progress from page {page}'**
  String startAtPage(int page);

  /// No description provided for @startPlan.
  ///
  /// In en, this message translates to:
  /// **'Start plan'**
  String get startPlan;

  /// No description provided for @activeKhatmah.
  ///
  /// In en, this message translates to:
  /// **'Active Khatmah'**
  String get activeKhatmah;

  /// No description provided for @ramadanKhatmah.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Khatmah'**
  String get ramadanKhatmah;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @targetDate.
  ///
  /// In en, this message translates to:
  /// **'Target: {date}'**
  String targetDate(String date);

  /// No description provided for @adjustDate.
  ///
  /// In en, this message translates to:
  /// **'Adjust target date'**
  String get adjustDate;

  /// No description provided for @deletePlan.
  ///
  /// In en, this message translates to:
  /// **'Delete plan'**
  String get deletePlan;

  /// No description provided for @deletePlanBody.
  ///
  /// In en, this message translates to:
  /// **'This Khatmah progress will be removed from this device.'**
  String get deletePlanBody;

  /// No description provided for @pagesOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} pages'**
  String pagesOfTotal(int completed, int total);

  /// No description provided for @pagesToday.
  ///
  /// In en, this message translates to:
  /// **'Pages today'**
  String get pagesToday;

  /// No description provided for @pagesRemaining.
  ///
  /// In en, this message translates to:
  /// **'Pages remaining'**
  String get pagesRemaining;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'Days remaining'**
  String get daysRemaining;

  /// No description provided for @completeToday.
  ///
  /// In en, this message translates to:
  /// **'Complete today\'s target'**
  String get completeToday;

  /// No description provided for @khatmahComplete.
  ///
  /// In en, this message translates to:
  /// **'Khatmah complete'**
  String get khatmahComplete;

  /// No description provided for @updateProgress.
  ///
  /// In en, this message translates to:
  /// **'Update progress'**
  String get updateProgress;

  /// No description provided for @pagesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Pages completed'**
  String get pagesCompleted;

  /// No description provided for @pausePlan.
  ///
  /// In en, this message translates to:
  /// **'Pause plan'**
  String get pausePlan;

  /// No description provided for @resumePlan.
  ///
  /// In en, this message translates to:
  /// **'Resume plan'**
  String get resumePlan;

  /// No description provided for @progressSavedLocally.
  ///
  /// In en, this message translates to:
  /// **'Your progress is saved locally and remains available offline.'**
  String get progressSavedLocally;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noMemorization.
  ///
  /// In en, this message translates to:
  /// **'Create a memorization range'**
  String get noMemorization;

  /// No description provided for @noMemorizationBody.
  ///
  /// In en, this message translates to:
  /// **'Select a Surah and Ayah range, then practise with repetition, hidden text, and revision markers.'**
  String get noMemorizationBody;

  /// No description provided for @createMemorization.
  ///
  /// In en, this message translates to:
  /// **'Create memorization plan'**
  String get createMemorization;

  /// No description provided for @createMemorizationBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a focused Ayah range and your preferred repetition pattern.'**
  String get createMemorizationBody;

  /// No description provided for @newRange.
  ///
  /// In en, this message translates to:
  /// **'New range'**
  String get newRange;

  /// No description provided for @startAyah.
  ///
  /// In en, this message translates to:
  /// **'Start Ayah'**
  String get startAyah;

  /// No description provided for @endAyah.
  ///
  /// In en, this message translates to:
  /// **'End Ayah'**
  String get endAyah;

  /// No description provided for @repetitionsPerAyah.
  ///
  /// In en, this message translates to:
  /// **'Repetitions per Ayah'**
  String get repetitionsPerAyah;

  /// No description provided for @rangeRepetitions.
  ///
  /// In en, this message translates to:
  /// **'Full-range repetitions'**
  String get rangeRepetitions;

  /// No description provided for @delayBetween.
  ///
  /// In en, this message translates to:
  /// **'Delay between repetitions'**
  String get delayBetween;

  /// No description provided for @secondsCount.
  ///
  /// In en, this message translates to:
  /// **'{seconds} sec'**
  String secondsCount(int seconds);

  /// No description provided for @startWithAyahHidden.
  ///
  /// In en, this message translates to:
  /// **'Start practice with the Ayah hidden'**
  String get startWithAyahHidden;

  /// No description provided for @startMemorizing.
  ///
  /// In en, this message translates to:
  /// **'Start memorizing'**
  String get startMemorizing;

  /// No description provided for @ayahRangeError.
  ///
  /// In en, this message translates to:
  /// **'Enter an Ayah from 1 to {maximum}'**
  String ayahRangeError(int maximum);

  /// No description provided for @endBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'The ending Ayah must be after the starting Ayah.'**
  String get endBeforeStart;

  /// No description provided for @ayahRange.
  ///
  /// In en, this message translates to:
  /// **'Ayahs {start}–{end}'**
  String ayahRange(int start, int end);

  /// No description provided for @currentAyah.
  ///
  /// In en, this message translates to:
  /// **'Current Ayah · {ayah}'**
  String currentAyah(int ayah);

  /// No description provided for @ayahHidden.
  ///
  /// In en, this message translates to:
  /// **'Recite from memory, then reveal the Ayah to check.'**
  String get ayahHidden;

  /// No description provided for @hideAyah.
  ///
  /// In en, this message translates to:
  /// **'Hide Ayah'**
  String get hideAyah;

  /// No description provided for @revealAyah.
  ///
  /// In en, this message translates to:
  /// **'Reveal Ayah'**
  String get revealAyah;

  /// No description provided for @repeatCount.
  ///
  /// In en, this message translates to:
  /// **'Repeat ×{count}'**
  String repeatCount(int count);

  /// No description provided for @delayCount.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s delay'**
  String delayCount(int seconds);

  /// No description provided for @repeatCurrent.
  ///
  /// In en, this message translates to:
  /// **'Repeat current Ayah'**
  String get repeatCurrent;

  /// No description provided for @repeatRange.
  ///
  /// In en, this message translates to:
  /// **'Repeat full range'**
  String get repeatRange;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @openInMushaf.
  ///
  /// In en, this message translates to:
  /// **'Open in Mushaf'**
  String get openInMushaf;

  /// No description provided for @markForRevision.
  ///
  /// In en, this message translates to:
  /// **'Mark for revision'**
  String get markForRevision;

  /// No description provided for @markMemorized.
  ///
  /// In en, this message translates to:
  /// **'Mark memorized'**
  String get markMemorized;

  /// No description provided for @memorized.
  ///
  /// In en, this message translates to:
  /// **'Memorized'**
  String get memorized;

  /// No description provided for @deleteMemorizationBody.
  ///
  /// In en, this message translates to:
  /// **'This memorization range and its progress will be removed from this device.'**
  String get deleteMemorizationBody;

  /// No description provided for @audioFailed.
  ///
  /// In en, this message translates to:
  /// **'Practice audio could not be played. Check your connection and try again.'**
  String get audioFailed;

  /// No description provided for @accountAndSync.
  ///
  /// In en, this message translates to:
  /// **'Account and cloud backup'**
  String get accountAndSync;

  /// No description provided for @cloudNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Cloud accounts are ready in the app. They will become available when the project\'s private server address is connected.'**
  String get cloudNotConfigured;

  /// No description provided for @accountOptionalBody.
  ///
  /// In en, this message translates to:
  /// **'An account is optional. Create one only if you want to back up and restore your progress across devices.'**
  String get accountOptionalBody;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordRules.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get passwordRules;

  /// No description provided for @displayNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 2 characters.'**
  String get displayNameRequired;

  /// No description provided for @validEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get validEmailRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'The password must contain at least 8 characters.'**
  String get passwordTooShort;

  /// No description provided for @signedInSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'You are signed in.'**
  String get signedInSuccessfully;

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backupNow;

  /// No description provided for @backupComplete.
  ///
  /// In en, this message translates to:
  /// **'Your Quran progress is safely backed up.'**
  String get backupComplete;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackup;

  /// No description provided for @restoreBackupWarning.
  ///
  /// In en, this message translates to:
  /// **'This will replace the Khatmah and memorization progress stored on this device with the cloud copy.'**
  String get restoreBackupWarning;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreComplete.
  ///
  /// In en, this message translates to:
  /// **'Your cloud progress has been restored.'**
  String get restoreComplete;

  /// No description provided for @noCloudBackup.
  ///
  /// In en, this message translates to:
  /// **'There is no cloud backup for this account yet.'**
  String get noCloudBackup;

  /// No description provided for @cloudDataInvalid.
  ///
  /// In en, this message translates to:
  /// **'The cloud backup could not be read safely.'**
  String get cloudDataInvalid;

  /// No description provided for @lastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced: {date}'**
  String lastSynced(String date);

  /// No description provided for @accountPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your password is never saved in the app. The account only protects your voluntary cloud backup.'**
  String get accountPrivacyNote;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'The email or password is incorrect.'**
  String get invalidCredentials;

  /// No description provided for @emailAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'An account already uses this email address.'**
  String get emailAlreadyUsed;

  /// No description provided for @accountValidationFailed.
  ///
  /// In en, this message translates to:
  /// **'Check the account details and try again.'**
  String get accountValidationFailed;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get sessionExpired;

  /// No description provided for @cloudServerError.
  ///
  /// In en, this message translates to:
  /// **'The cloud service had a problem. Please try again later.'**
  String get cloudServerError;

  /// No description provided for @cloudUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The cloud service cannot be reached. Your local Quran data is still safe.'**
  String get cloudUnavailable;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reading reminder'**
  String get dailyReminder;

  /// No description provided for @remindMeDaily.
  ///
  /// In en, this message translates to:
  /// **'Remind me every day'**
  String get remindMeDaily;

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'Receive one gentle reminder at your chosen time.'**
  String get reminderBody;

  /// No description provided for @reminderMobileOnly.
  ///
  /// In en, this message translates to:
  /// **'Scheduled reminders are currently available in the Android and iOS apps.'**
  String get reminderMobileOnly;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time: {time}'**
  String reminderTime(String time);

  /// No description provided for @dailyReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'A moment with the Quran'**
  String get dailyReminderTitle;

  /// No description provided for @dailyReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Take a peaceful moment to read, listen, or review today.'**
  String get dailyReminderBody;

  /// No description provided for @reminderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Your daily Quran reminder is active.'**
  String get reminderEnabled;

  /// No description provided for @notificationDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission was not granted.'**
  String get notificationDenied;

  /// No description provided for @contentServerNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'The Quran, included Tafsir and saved downloads are available. Additional reading resources will be available when the content service is connected.'**
  String get contentServerNotConfigured;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
