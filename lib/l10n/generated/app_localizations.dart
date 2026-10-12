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
  /// **'On web, selected Tafsir and translations can be saved in this browser (up to 160 MiB); the browser may remove them if storage is low. Audio needs internet. Prepare the app and Quran pages separately in Settings.'**
  String get webOfflineNote;

  /// No description provided for @webResourceStorageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This browser cannot save reading resources. Use a supported browser with site storage enabled.'**
  String get webResourceStorageUnavailable;

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

  /// No description provided for @previousAyah.
  ///
  /// In en, this message translates to:
  /// **'Previous Ayah'**
  String get previousAyah;

  /// No description provided for @nextAyah.
  ///
  /// In en, this message translates to:
  /// **'Next Ayah'**
  String get nextAyah;

  /// No description provided for @removeRevisionMarker.
  ///
  /// In en, this message translates to:
  /// **'Remove revision marker'**
  String get removeRevisionMarker;

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

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline reading'**
  String get offlineTitle;

  /// No description provided for @offlineBody.
  ///
  /// In en, this message translates to:
  /// **'Save the app and Quran pages on this browser before going offline. Tafsir and translations can be saved separately in Library. Audio is not included.'**
  String get offlineBody;

  /// No description provided for @offlinePrepare.
  ///
  /// In en, this message translates to:
  /// **'Prepare offline reading'**
  String get offlinePrepare;

  /// No description provided for @offlinePreparing.
  ///
  /// In en, this message translates to:
  /// **'Saving Quran for offline reading…'**
  String get offlinePreparing;

  /// No description provided for @offlineReady.
  ///
  /// In en, this message translates to:
  /// **'Ready for offline reading'**
  String get offlineReady;

  /// No description provided for @offlineUpdateReady.
  ///
  /// In en, this message translates to:
  /// **'An offline update is ready'**
  String get offlineUpdateReady;

  /// No description provided for @offlineActivate.
  ///
  /// In en, this message translates to:
  /// **'Apply update and reload'**
  String get offlineActivate;

  /// No description provided for @offlineCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel download'**
  String get offlineCancel;

  /// No description provided for @offlineRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove offline app files'**
  String get offlineRemove;

  /// No description provided for @offlineRemoveWarning.
  ///
  /// In en, this message translates to:
  /// **'Remove only the saved app and Quran page files from this browser? Your reading progress and saved Tafsir are kept. You will need internet to reopen the app.'**
  String get offlineRemoveWarning;

  /// No description provided for @offlineRemoved.
  ///
  /// In en, this message translates to:
  /// **'Offline app files removed'**
  String get offlineRemoved;

  /// No description provided for @offlineUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Offline preparation is unavailable in this browser. Try a supported browser over HTTPS.'**
  String get offlineUnavailable;

  /// No description provided for @offlineError.
  ///
  /// In en, this message translates to:
  /// **'Offline preparation could not finish. Check your connection and available storage, then try again.'**
  String get offlineError;

  /// No description provided for @offlineOtherTabs.
  ///
  /// In en, this message translates to:
  /// **'Close other Quran Haven tabs, then apply the update again.'**
  String get offlineOtherTabs;

  /// No description provided for @offlineActivationTimeout.
  ///
  /// In en, this message translates to:
  /// **'The update could not activate yet. Reload this tab and try again.'**
  String get offlineActivationTimeout;

  /// No description provided for @offlineStorageWarning.
  ///
  /// In en, this message translates to:
  /// **'The browser may remove saved files when storage is low. Check this screen before relying on offline reading.'**
  String get offlineStorageWarning;

  /// No description provided for @offlineProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} / {total} MB saved'**
  String offlineProgress(String completed, String total);

  /// No description provided for @offlineNotReady.
  ///
  /// In en, this message translates to:
  /// **'Not prepared for offline reading'**
  String get offlineNotReady;

  /// No description provided for @offlineCancelled.
  ///
  /// In en, this message translates to:
  /// **'Download cancelled. A previously prepared version, if any, is kept.'**
  String get offlineCancelled;

  /// No description provided for @localStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'On-device storage'**
  String get localStorageTitle;

  /// No description provided for @localStorageBody.
  ///
  /// In en, this message translates to:
  /// **'Your bookmarks, last-read position, plans, settings and downloads are saved only on this device or in this browser. There are no accounts, cloud backups or cross-device sync. Uninstalling the app or clearing its data/site storage can erase these saved items.'**
  String get localStorageBody;

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use Quran Haven'**
  String get guideTitle;

  /// No description provided for @guideOpen.
  ///
  /// In en, this message translates to:
  /// **'Open the guide'**
  String get guideOpen;

  /// No description provided for @guideEntryBody.
  ///
  /// In en, this message translates to:
  /// **'Short visual demonstrations and practical steps for reading, listening and building a daily practice.'**
  String get guideEntryBody;

  /// No description provided for @guideIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your journey, one step at a time'**
  String get guideIntroTitle;

  /// No description provided for @guideIntro.
  ///
  /// In en, this message translates to:
  /// **'Start with the Mushaf, then explore the tools that support your reading. These instructions describe the features available now, with separate guidance for the website and phone app.'**
  String get guideIntro;

  /// No description provided for @guideMediaHint.
  ///
  /// In en, this message translates to:
  /// **'Demonstrations stay still until you choose Play. Every demonstration has written steps below it.'**
  String get guideMediaHint;

  /// No description provided for @guideGoodToKnow.
  ///
  /// In en, this message translates to:
  /// **'Good to know'**
  String get guideGoodToKnow;

  /// No description provided for @guidePlayDemo.
  ///
  /// In en, this message translates to:
  /// **'Play demonstration'**
  String get guidePlayDemo;

  /// No description provided for @guideStopDemo.
  ///
  /// In en, this message translates to:
  /// **'Stop demonstration'**
  String get guideStopDemo;

  /// No description provided for @guideMediaUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Demonstration unavailable. Follow the written steps below.'**
  String get guideMediaUnavailable;

  /// No description provided for @guideReducedMotion.
  ///
  /// In en, this message translates to:
  /// **'Animation is off because reduced motion is enabled on your device.'**
  String get guideReducedMotion;

  /// No description provided for @guideDemoDescription.
  ///
  /// In en, this message translates to:
  /// **'Screen demonstration: {topic}'**
  String guideDemoDescription(String topic);

  /// No description provided for @guideReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Read and find your place'**
  String get guideReadingTitle;

  /// No description provided for @guideReadingStep1.
  ///
  /// In en, this message translates to:
  /// **'From Home, choose Open the Mushaf to continue at your last-read page.'**
  String get guideReadingStep1;

  /// No description provided for @guideReadingStep2.
  ///
  /// In en, this message translates to:
  /// **'Open Quick navigation in the reader. Choose a Surah or Juz, or enter a page number from 1 to 604 and choose Go to page.'**
  String get guideReadingStep2;

  /// No description provided for @guideReadingStep3.
  ///
  /// In en, this message translates to:
  /// **'Swipe between pages. Your last-read position is saved automatically on this device.'**
  String get guideReadingStep3;

  /// No description provided for @guideReadingTip.
  ///
  /// In en, this message translates to:
  /// **'The Quran remains Arabic when you change the interface language. You do not need an account to read.'**
  String get guideReadingTip;

  /// No description provided for @guideSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search and save bookmarks'**
  String get guideSearchTitle;

  /// No description provided for @guideSearchStep1.
  ///
  /// In en, this message translates to:
  /// **'Choose Search Quran on Home, or open Search in the reader. Enter a word or phrase from the Arabic Quran.'**
  String get guideSearchStep1;

  /// No description provided for @guideSearchStep2.
  ///
  /// In en, this message translates to:
  /// **'Select a search result, then use Close at the top of the panel to return to the Mushaf at that Ayah. Press and hold an Ayah to open its actions.'**
  String get guideSearchStep2;

  /// No description provided for @guideSearchStep3.
  ///
  /// In en, this message translates to:
  /// **'Choose a bookmark color from the Ayah actions. Open Bookmarks to return to your saved Ayahs.'**
  String get guideSearchStep3;

  /// No description provided for @guideSearchTip.
  ///
  /// In en, this message translates to:
  /// **'Search currently covers the Arabic Quran, not Tafsir or translations. Bookmarks use the existing yellow, red and green groups.'**
  String get guideSearchTip;

  /// No description provided for @guideLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Tafsir and translations'**
  String get guideLibraryTitle;

  /// No description provided for @guideLibraryStep1.
  ///
  /// In en, this message translates to:
  /// **'Open Library, then choose Tafsir or Translations.'**
  String get guideLibraryStep1;

  /// No description provided for @guideLibraryStep2.
  ///
  /// In en, this message translates to:
  /// **'Use Download for an additional resource, or Select for one already available. Wait for the ready confirmation.'**
  String get guideLibraryStep2;

  /// No description provided for @guideLibraryStep3.
  ///
  /// In en, this message translates to:
  /// **'Return to the Mushaf, press and hold an Ayah and open its Tafsir action to read the selected resource.'**
  String get guideLibraryStep3;

  /// No description provided for @guideLibraryTip.
  ///
  /// In en, this message translates to:
  /// **'Interface language and reading resource are independent. Saved resources can be read offline; browser storage must be available.'**
  String get guideLibraryTip;

  /// No description provided for @guideAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Listen to recitations'**
  String get guideAudioTitle;

  /// No description provided for @guideAudioStep1.
  ///
  /// In en, this message translates to:
  /// **'Open the reader audio controls to choose a reciter. Different controls may offer different reciter lists.'**
  String get guideAudioStep1;

  /// No description provided for @guideAudioStep2.
  ///
  /// In en, this message translates to:
  /// **'In Library, choose Recitations, select a Surah and press Play. You can also play an Ayah from its actions in the Mushaf.'**
  String get guideAudioStep2;

  /// No description provided for @guideAudioStep3.
  ///
  /// In en, this message translates to:
  /// **'Use the audio player to pause or continue. Resume listening returns to the saved audio position when one is available.'**
  String get guideAudioStep3;

  /// No description provided for @guideAudioTip.
  ///
  /// In en, this message translates to:
  /// **'Online audio needs an internet connection and may come from external recitation providers. Browser offline audio downloads are not available.'**
  String get guideAudioTip;

  /// No description provided for @guideOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare before going offline'**
  String get guideOfflineTitle;

  /// No description provided for @guideOfflineStep1.
  ///
  /// In en, this message translates to:
  /// **'On the website, open Settings and choose Prepare offline reading. Keep the tab open until Ready for offline reading appears. The phone app includes the Mushaf.'**
  String get guideOfflineStep1;

  /// No description provided for @guideOfflineStep2.
  ///
  /// In en, this message translates to:
  /// **'In Library, download the Tafsir and translations you want while connected. Offline app preparation does not download these additional resources or audio.'**
  String get guideOfflineStep2;

  /// No description provided for @guideOfflineStep3.
  ///
  /// In en, this message translates to:
  /// **'In the phone app, choose a Surah under Library → Recitations and use Download for offline. Test your saved content without a connection before relying on it.'**
  String get guideOfflineStep3;

  /// No description provided for @guideOfflineTip.
  ///
  /// In en, this message translates to:
  /// **'Browsers may remove saved files when space is low. Private browsing is not suitable for lasting storage. Offline audio is available in the phone app, not the website.'**
  String get guideOfflineTip;

  /// No description provided for @guidePlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Build a reading and memorization routine'**
  String get guidePlansTitle;

  /// No description provided for @guidePlansStep1.
  ///
  /// In en, this message translates to:
  /// **'Open Plans → Khatmah. Create a plan, choose a completion period and start it. Mark the daily reading only after you finish it.'**
  String get guidePlansStep1;

  /// No description provided for @guidePlansStep2.
  ///
  /// In en, this message translates to:
  /// **'Open Memorization and create a plan with a Surah, Ayah range, repetition count and delay.'**
  String get guidePlansStep2;

  /// No description provided for @guidePlansStep3.
  ///
  /// In en, this message translates to:
  /// **'Play the range, hide or reveal the text, and mark Ayahs as memorized or for revision. Use the previous and next controls to move within your range.'**
  String get guidePlansStep3;

  /// No description provided for @guidePlansTip.
  ///
  /// In en, this message translates to:
  /// **'Plan progress is saved on this device. Audio repetition still needs a playable source or a supported saved download.'**
  String get guidePlansTip;

  /// No description provided for @guideSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Make the experience comfortable'**
  String get guideSettingsTitle;

  /// No description provided for @guideSettingsStep1.
  ///
  /// In en, this message translates to:
  /// **'In Settings → Language, choose العربية, English or Español. The guide and interface follow your choice.'**
  String get guideSettingsStep1;

  /// No description provided for @guideSettingsStep2.
  ///
  /// In en, this message translates to:
  /// **'In Settings → Appearance, choose light, dark or the system setting.'**
  String get guideSettingsStep2;

  /// No description provided for @guideSettingsStep3.
  ///
  /// In en, this message translates to:
  /// **'In the phone app, optionally enable a daily reminder, choose its time and grant notification permission.'**
  String get guideSettingsStep3;

  /// No description provided for @guideSettingsTip.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder notifications are available on supported phones, not the website. You can turn them off again in Settings.'**
  String get guideSettingsTip;

  /// No description provided for @guideStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Understand your local data'**
  String get guideStorageTitle;

  /// No description provided for @guideStorageStep1.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks, reading position, plans, preferences and saved downloads remain on this device or in this browser. There is no account or cross-device sync.'**
  String get guideStorageStep1;

  /// No description provided for @guideStorageStep2.
  ///
  /// In en, this message translates to:
  /// **'Keep using the same browser profile to retain website data. Another device, browser or profile has its own separate data.'**
  String get guideStorageStep2;

  /// No description provided for @guideStorageTip.
  ///
  /// In en, this message translates to:
  /// **'Uninstalling the app, clearing app or site data, or losing the device can erase your saved items. A local export/import tool is not currently available.'**
  String get guideStorageTip;

  /// No description provided for @playAyah.
  ///
  /// In en, this message translates to:
  /// **'Play ayah'**
  String get playAyah;

  /// No description provided for @playFromAyah.
  ///
  /// In en, this message translates to:
  /// **'Play from this ayah'**
  String get playFromAyah;

  /// No description provided for @copyAyah.
  ///
  /// In en, this message translates to:
  /// **'Copy ayah'**
  String get copyAyah;

  /// No description provided for @saveYellowBookmark.
  ///
  /// In en, this message translates to:
  /// **'Save a yellow bookmark'**
  String get saveYellowBookmark;

  /// No description provided for @saveRedBookmark.
  ///
  /// In en, this message translates to:
  /// **'Save a red bookmark'**
  String get saveRedBookmark;

  /// No description provided for @saveGreenBookmark.
  ///
  /// In en, this message translates to:
  /// **'Save a green bookmark'**
  String get saveGreenBookmark;

  /// No description provided for @guideViewLarger.
  ///
  /// In en, this message translates to:
  /// **'View larger'**
  String get guideViewLarger;

  /// No description provided for @guideZoomHint.
  ///
  /// In en, this message translates to:
  /// **'Pinch or scroll to zoom, then drag to move around the screen. Use Reset zoom to see the full demonstration again.'**
  String get guideZoomHint;

  /// No description provided for @guideResetZoom.
  ///
  /// In en, this message translates to:
  /// **'Reset zoom'**
  String get guideResetZoom;
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
