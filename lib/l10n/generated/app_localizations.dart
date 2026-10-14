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

  /// No description provided for @corpusEmptyForm.
  ///
  /// In en, this message translates to:
  /// **'No separate written form in the source'**
  String get corpusEmptyForm;

  /// No description provided for @corpusAcquisition.
  ///
  /// In en, this message translates to:
  /// **'Acquisition and provenance record'**
  String get corpusAcquisition;

  /// No description provided for @corpusLearning.
  ///
  /// In en, this message translates to:
  /// **'Word morphology'**
  String get corpusLearning;

  /// No description provided for @corpusLearningBody.
  ///
  /// In en, this message translates to:
  /// **'Explore the original Quranic Arabic Corpus v0.4 word segments, part-of-speech tags, roots and lemmas. This is a learning resource, not a replacement for the King Fahd Mushaf text.'**
  String get corpusLearningBody;

  /// No description provided for @corpusOffline.
  ///
  /// In en, this message translates to:
  /// **'Bundled for offline learning'**
  String get corpusOffline;

  /// No description provided for @corpusWord.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get corpusWord;

  /// No description provided for @corpusSegment.
  ///
  /// In en, this message translates to:
  /// **'Segment'**
  String get corpusSegment;

  /// No description provided for @corpusPartOfSpeech.
  ///
  /// In en, this message translates to:
  /// **'Part of speech'**
  String get corpusPartOfSpeech;

  /// No description provided for @corpusRoot.
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get corpusRoot;

  /// No description provided for @corpusLemma.
  ///
  /// In en, this message translates to:
  /// **'Lemma'**
  String get corpusLemma;

  /// No description provided for @corpusOriginalForm.
  ///
  /// In en, this message translates to:
  /// **'Original Buckwalter form'**
  String get corpusOriginalForm;

  /// No description provided for @corpusOriginalCodes.
  ///
  /// In en, this message translates to:
  /// **'Original feature codes'**
  String get corpusOriginalCodes;

  /// No description provided for @corpusSource.
  ///
  /// In en, this message translates to:
  /// **'Source and license'**
  String get corpusSource;

  /// No description provided for @corpusSourceBody.
  ///
  /// In en, this message translates to:
  /// **'The original dataset and its notices are preserved unchanged. Word numbering and forms here follow the Corpus, independently of the Mushaf renderer. Raw codes are shown as recorded; this page does not generate interpretations or translations.'**
  String get corpusSourceBody;

  /// No description provided for @corpusLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'The complete learning resource could not be verified or loaded. No partial analysis is shown. Try again.'**
  String get corpusLoadFailed;

  /// No description provided for @corpusPreviousAyah.
  ///
  /// In en, this message translates to:
  /// **'Previous Ayah'**
  String get corpusPreviousAyah;

  /// No description provided for @corpusNextAyah.
  ///
  /// In en, this message translates to:
  /// **'Next Ayah'**
  String get corpusNextAyah;

  /// No description provided for @corpusPrefix.
  ///
  /// In en, this message translates to:
  /// **'Prefix'**
  String get corpusPrefix;

  /// No description provided for @corpusStem.
  ///
  /// In en, this message translates to:
  /// **'Stem'**
  String get corpusStem;

  /// No description provided for @corpusSuffix.
  ///
  /// In en, this message translates to:
  /// **'Suffix'**
  String get corpusSuffix;

  /// No description provided for @corpusSourceDownload.
  ///
  /// In en, this message translates to:
  /// **'Official source and updates'**
  String get corpusSourceDownload;

  /// No description provided for @corpusTagsetDocs.
  ///
  /// In en, this message translates to:
  /// **'Official part-of-speech documentation'**
  String get corpusTagsetDocs;

  /// No description provided for @corpusFeaturesDocs.
  ///
  /// In en, this message translates to:
  /// **'Official morphology documentation'**
  String get corpusFeaturesDocs;

  /// No description provided for @corpusBuckwalterDocs.
  ///
  /// In en, this message translates to:
  /// **'Documented Buckwalter mapping'**
  String get corpusBuckwalterDocs;

  /// No description provided for @corpusTanzilSource.
  ///
  /// In en, this message translates to:
  /// **'Tanzil text source and updates'**
  String get corpusTanzilSource;

  /// No description provided for @corpusLicense.
  ///
  /// In en, this message translates to:
  /// **'Full GNU GPL license for the dataset'**
  String get corpusLicense;

  /// No description provided for @corpusIdentity.
  ///
  /// In en, this message translates to:
  /// **'Immutable dataset identity'**
  String get corpusIdentity;

  /// No description provided for @corpusLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Source link copied. Open it in your browser.'**
  String get corpusLinkCopied;

  /// No description provided for @corpusGuideStep1.
  ///
  /// In en, this message translates to:
  /// **'Library → Word morphology opens the bundled Corpus learning page. You can also long-press an Ayah in the reader and choose Word morphology.'**
  String get corpusGuideStep1;

  /// No description provided for @corpusGuideStep2.
  ///
  /// In en, this message translates to:
  /// **'Choose a Surah and Ayah, or use Previous/Next Ayah. Each original word is broken into its recorded segments, with tags, roots and lemmas when present.'**
  String get corpusGuideStep2;

  /// No description provided for @corpusGuideStep3.
  ///
  /// In en, this message translates to:
  /// **'Original feature codes remain visible. Source and license opens the unchanged copyright notices, full license and official documentation links. This is morphology, not automated Tafsir or full syntactic parsing.'**
  String get corpusGuideStep3;

  /// No description provided for @shareArabicSource.
  ///
  /// In en, this message translates to:
  /// **'Quran text: King Fahd Glorious Quran Printing Complex.'**
  String get shareArabicSource;

  /// No description provided for @audioDownloadSelection.
  ///
  /// In en, this message translates to:
  /// **'Selected recording'**
  String get audioDownloadSelection;

  /// No description provided for @corpusPosN.
  ///
  /// In en, this message translates to:
  /// **'Noun'**
  String get corpusPosN;

  /// No description provided for @corpusPosPN.
  ///
  /// In en, this message translates to:
  /// **'Proper noun'**
  String get corpusPosPN;

  /// No description provided for @corpusPosADJ.
  ///
  /// In en, this message translates to:
  /// **'Adjective'**
  String get corpusPosADJ;

  /// No description provided for @corpusPosIMPN.
  ///
  /// In en, this message translates to:
  /// **'Imperative verbal noun'**
  String get corpusPosIMPN;

  /// No description provided for @corpusPosPRON.
  ///
  /// In en, this message translates to:
  /// **'Personal pronoun'**
  String get corpusPosPRON;

  /// No description provided for @corpusPosDEM.
  ///
  /// In en, this message translates to:
  /// **'Demonstrative pronoun'**
  String get corpusPosDEM;

  /// No description provided for @corpusPosREL.
  ///
  /// In en, this message translates to:
  /// **'Relative pronoun'**
  String get corpusPosREL;

  /// No description provided for @corpusPosT.
  ///
  /// In en, this message translates to:
  /// **'Time adverb'**
  String get corpusPosT;

  /// No description provided for @corpusPosLOC.
  ///
  /// In en, this message translates to:
  /// **'Location adverb'**
  String get corpusPosLOC;

  /// No description provided for @corpusPosV.
  ///
  /// In en, this message translates to:
  /// **'Verb'**
  String get corpusPosV;

  /// No description provided for @corpusPosP.
  ///
  /// In en, this message translates to:
  /// **'Preposition'**
  String get corpusPosP;

  /// No description provided for @corpusPosDET.
  ///
  /// In en, this message translates to:
  /// **'Determiner prefix'**
  String get corpusPosDET;

  /// No description provided for @corpusPosEMPH.
  ///
  /// In en, this message translates to:
  /// **'Emphatic lām prefix'**
  String get corpusPosEMPH;

  /// No description provided for @corpusPosIMPV.
  ///
  /// In en, this message translates to:
  /// **'Imperative lām prefix'**
  String get corpusPosIMPV;

  /// No description provided for @corpusPosPRP.
  ///
  /// In en, this message translates to:
  /// **'Purpose lām prefix'**
  String get corpusPosPRP;

  /// No description provided for @corpusPosCONJ.
  ///
  /// In en, this message translates to:
  /// **'Coordinating conjunction'**
  String get corpusPosCONJ;

  /// No description provided for @corpusPosSUB.
  ///
  /// In en, this message translates to:
  /// **'Subordinating conjunction'**
  String get corpusPosSUB;

  /// No description provided for @corpusPosACC.
  ///
  /// In en, this message translates to:
  /// **'Accusative particle'**
  String get corpusPosACC;

  /// No description provided for @corpusPosAMD.
  ///
  /// In en, this message translates to:
  /// **'Amendment particle'**
  String get corpusPosAMD;

  /// No description provided for @corpusPosANS.
  ///
  /// In en, this message translates to:
  /// **'Answer particle'**
  String get corpusPosANS;

  /// No description provided for @corpusPosAVR.
  ///
  /// In en, this message translates to:
  /// **'Aversion particle'**
  String get corpusPosAVR;

  /// No description provided for @corpusPosCAUS.
  ///
  /// In en, this message translates to:
  /// **'Particle of cause'**
  String get corpusPosCAUS;

  /// No description provided for @corpusPosCERT.
  ///
  /// In en, this message translates to:
  /// **'Particle of certainty'**
  String get corpusPosCERT;

  /// No description provided for @corpusPosCIRC.
  ///
  /// In en, this message translates to:
  /// **'Circumstantial particle'**
  String get corpusPosCIRC;

  /// No description provided for @corpusPosCOM.
  ///
  /// In en, this message translates to:
  /// **'Comitative particle'**
  String get corpusPosCOM;

  /// No description provided for @corpusPosCOND.
  ///
  /// In en, this message translates to:
  /// **'Conditional particle'**
  String get corpusPosCOND;

  /// No description provided for @corpusPosEQ.
  ///
  /// In en, this message translates to:
  /// **'Equalization particle'**
  String get corpusPosEQ;

  /// No description provided for @corpusPosEXH.
  ///
  /// In en, this message translates to:
  /// **'Exhortation particle'**
  String get corpusPosEXH;

  /// No description provided for @corpusPosEXL.
  ///
  /// In en, this message translates to:
  /// **'Explanation particle'**
  String get corpusPosEXL;

  /// No description provided for @corpusPosEXP.
  ///
  /// In en, this message translates to:
  /// **'Exceptive particle'**
  String get corpusPosEXP;

  /// No description provided for @corpusPosFUT.
  ///
  /// In en, this message translates to:
  /// **'Future particle'**
  String get corpusPosFUT;

  /// No description provided for @corpusPosINC.
  ///
  /// In en, this message translates to:
  /// **'Inceptive particle'**
  String get corpusPosINC;

  /// No description provided for @corpusPosINT.
  ///
  /// In en, this message translates to:
  /// **'Particle of interpretation'**
  String get corpusPosINT;

  /// No description provided for @corpusPosINTG.
  ///
  /// In en, this message translates to:
  /// **'Interrogative particle'**
  String get corpusPosINTG;

  /// No description provided for @corpusPosNEG.
  ///
  /// In en, this message translates to:
  /// **'Negative particle'**
  String get corpusPosNEG;

  /// No description provided for @corpusPosPREV.
  ///
  /// In en, this message translates to:
  /// **'Preventive particle'**
  String get corpusPosPREV;

  /// No description provided for @corpusPosPRO.
  ///
  /// In en, this message translates to:
  /// **'Prohibition particle'**
  String get corpusPosPRO;

  /// No description provided for @corpusPosREM.
  ///
  /// In en, this message translates to:
  /// **'Resumption particle'**
  String get corpusPosREM;

  /// No description provided for @corpusPosRES.
  ///
  /// In en, this message translates to:
  /// **'Restriction particle'**
  String get corpusPosRES;

  /// No description provided for @corpusPosRET.
  ///
  /// In en, this message translates to:
  /// **'Retraction particle'**
  String get corpusPosRET;

  /// No description provided for @corpusPosRSLT.
  ///
  /// In en, this message translates to:
  /// **'Result particle'**
  String get corpusPosRSLT;

  /// No description provided for @corpusPosSUP.
  ///
  /// In en, this message translates to:
  /// **'Supplemental particle'**
  String get corpusPosSUP;

  /// No description provided for @corpusPosSUR.
  ///
  /// In en, this message translates to:
  /// **'Surprise particle'**
  String get corpusPosSUR;

  /// No description provided for @corpusPosVOC.
  ///
  /// In en, this message translates to:
  /// **'Vocative particle'**
  String get corpusPosVOC;

  /// No description provided for @corpusPosINL.
  ///
  /// In en, this message translates to:
  /// **'Quranic initials'**
  String get corpusPosINL;

  /// No description provided for @backupNativeHint.
  ///
  /// In en, this message translates to:
  /// **'On this mobile build, export copies JSON to the clipboard. File restore and PNG download are available on the website; native file tools are not yet enabled.'**
  String get backupNativeHint;

  /// No description provided for @backupRecoveryFailed.
  ///
  /// In en, this message translates to:
  /// **'Storage refused both restore and rollback. Recovery may be incomplete. Keep your safety copy; do not clear app/site data.'**
  String get backupRecoveryFailed;

  /// No description provided for @guidePersonalTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes and collections'**
  String get guidePersonalTitle;

  /// No description provided for @guidePersonalStep1.
  ///
  /// In en, this message translates to:
  /// **'Open Library → My Quran space. Create a note linked to a Surah and Ayah, or create a named collection.'**
  String get guidePersonalStep1;

  /// No description provided for @guidePersonalStep2.
  ///
  /// In en, this message translates to:
  /// **'Long-press an Ayah in the reader, then choose Add a note or Add to collection. Existing color bookmarks still work.'**
  String get guidePersonalStep2;

  /// No description provided for @guidePersonalStep3.
  ///
  /// In en, this message translates to:
  /// **'Use Edit to change text or a collection name. Open Ayah returns to the reader; deletions ask for confirmation.'**
  String get guidePersonalStep3;

  /// No description provided for @guideBackupStep1.
  ///
  /// In en, this message translates to:
  /// **'In Settings → Local backup, export the JSON file and keep it privately in a safe location. It contains personal text, not downloaded audio or books.'**
  String get guideBackupStep1;

  /// No description provided for @guideBackupStep2.
  ///
  /// In en, this message translates to:
  /// **'Choose a backup file or paste its JSON. Review its date and item counts; invalid or oversized files are rejected without changes.'**
  String get guideBackupStep2;

  /// No description provided for @guideBackupStep3.
  ///
  /// In en, this message translates to:
  /// **'Save a safety copy, then explicitly confirm replacement. The backup replaces current data instead of merging it. On the website choose Reload; in the phone app close the confirmation to refresh. Reminders remain disabled.'**
  String get guideBackupStep3;

  /// No description provided for @guideShareSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Share an Ayah and search books'**
  String get guideShareSearchTitle;

  /// No description provided for @guideShareSearchStep1.
  ///
  /// In en, this message translates to:
  /// **'Long-press an Ayah → Share Ayah. Preview the complete Arabic text, optionally select a saved translation, then save PNG or copy text/link.'**
  String get guideShareSearchStep1;

  /// No description provided for @guideShareSearchStep2.
  ///
  /// In en, this message translates to:
  /// **'The public link opens the exact Surah and Ayah. Your private note and collection data is never included in the link or image.'**
  String get guideShareSearchStep2;

  /// No description provided for @guideShareSearchStep3.
  ///
  /// In en, this message translates to:
  /// **'Library → Search saved books searches the whole chosen Tafsir or translation, not only the current page. Enter at least two characters; use result paging and Open Ayah.'**
  String get guideShareSearchStep3;

  /// No description provided for @guideSavedAudioStep1.
  ///
  /// In en, this message translates to:
  /// **'In Library → Recitations, choose a Surah. The reader’s reciter selection determines the recording to download.'**
  String get guideSavedAudioStep1;

  /// No description provided for @guideSavedAudioStep2.
  ///
  /// In en, this message translates to:
  /// **'Press Download for offline, watch progress, or cancel. Only complete verified recordings are saved; downloading never starts playback.'**
  String get guideSavedAudioStep2;

  /// No description provided for @guideSavedAudioStep3.
  ///
  /// In en, this message translates to:
  /// **'Saved Surah recordings has Play and Delete actions. Prepare the offline app separately in Settings so the site can reopen without internet.'**
  String get guideSavedAudioStep3;

  /// No description provided for @browserAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Surah recordings'**
  String get browserAudioTitle;

  /// No description provided for @browserAudioBody.
  ///
  /// In en, this message translates to:
  /// **'Download one complete Surah for the selected reciter. This is separate from the offline app and word-by-word audio. Playback starts only when you press Play. Browser storage can be cleared or evicted.'**
  String get browserAudioBody;

  /// No description provided for @browserAudioEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Surah recordings are saved in this browser yet.'**
  String get browserAudioEmpty;

  /// No description provided for @browserAudioUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Persistent audio storage is unavailable in this browser. Online playback remains available.'**
  String get browserAudioUnavailable;

  /// No description provided for @browserAudioStorageFull.
  ///
  /// In en, this message translates to:
  /// **'There is not enough browser storage. Remove a saved recording and try again.'**
  String get browserAudioStorageFull;

  /// No description provided for @browserAudioCancelled.
  ///
  /// In en, this message translates to:
  /// **'Download cancelled. No partial recording was saved.'**
  String get browserAudioCancelled;

  /// No description provided for @browserAudioDelete.
  ///
  /// In en, this message translates to:
  /// **'Remove this recording from this browser? Other recordings and your personal data are kept.'**
  String get browserAudioDelete;

  /// No description provided for @browserAudioBusy.
  ///
  /// In en, this message translates to:
  /// **'Another audio download is in progress.'**
  String get browserAudioBusy;

  /// No description provided for @browserAudioTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This recording exceeds the per-file download limit (256 MB).'**
  String get browserAudioTooLarge;

  /// No description provided for @personalTools.
  ///
  /// In en, this message translates to:
  /// **'My Quran space'**
  String get personalTools;

  /// No description provided for @personalToolsBody.
  ///
  /// In en, this message translates to:
  /// **'Your notes and named collections stay on this device.'**
  String get personalToolsBody;

  /// No description provided for @personalNotes.
  ///
  /// In en, this message translates to:
  /// **'Ayah notes'**
  String get personalNotes;

  /// No description provided for @personalCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get personalCollections;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get addNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNote;

  /// No description provided for @noteTitle.
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get noteTitle;

  /// No description provided for @noteBody.
  ///
  /// In en, this message translates to:
  /// **'Your reflection'**
  String get noteBody;

  /// No description provided for @notesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Keep a reflection beside an Ayah. Add a note here or from the reader’s Ayah menu.'**
  String get notesEmpty;

  /// No description provided for @createCollection.
  ///
  /// In en, this message translates to:
  /// **'Create collection'**
  String get createCollection;

  /// No description provided for @editCollection.
  ///
  /// In en, this message translates to:
  /// **'Rename collection'**
  String get editCollection;

  /// No description provided for @collectionName.
  ///
  /// In en, this message translates to:
  /// **'Collection name'**
  String get collectionName;

  /// No description provided for @collectionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Organize Ayahs into your own named collections. Existing color bookmarks remain unchanged.'**
  String get collectionsEmpty;

  /// No description provided for @collectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Ayahs yet. Add one from the reader or use Add Ayah.'**
  String get collectionEmpty;

  /// No description provided for @addAyah.
  ///
  /// In en, this message translates to:
  /// **'Add Ayah'**
  String get addAyah;

  /// No description provided for @openAyah.
  ///
  /// In en, this message translates to:
  /// **'Open Ayah'**
  String get openAyah;

  /// No description provided for @removeAyah.
  ///
  /// In en, this message translates to:
  /// **'Remove Ayah'**
  String get removeAyah;

  /// No description provided for @addToCollection.
  ///
  /// In en, this message translates to:
  /// **'Add to collection'**
  String get addToCollection;

  /// No description provided for @deletePersonalConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this item from this device? This cannot be undone.'**
  String get deletePersonalConfirm;

  /// No description provided for @personalSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device.'**
  String get personalSaved;

  /// No description provided for @personalDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This Ayah is already in the collection.'**
  String get personalDuplicate;

  /// No description provided for @personalLimit.
  ///
  /// In en, this message translates to:
  /// **'The local collection or note limit has been reached. Export a backup before removing old items.'**
  String get personalLimit;

  /// No description provided for @requiredText.
  ///
  /// In en, this message translates to:
  /// **'Enter text to continue.'**
  String get requiredText;

  /// No description provided for @invalidAyahLink.
  ///
  /// In en, this message translates to:
  /// **'This Ayah link is not valid. Your last reading position has been kept.'**
  String get invalidAyahLink;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Local backup'**
  String get backupTitle;

  /// No description provided for @backupBody.
  ///
  /// In en, this message translates to:
  /// **'Export a private JSON file for notes, collections, bookmarks, plans and reading settings. Audio and downloaded books are not included. Keep it somewhere safe; no copy is sent to a server.'**
  String get backupBody;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportBackup;

  /// No description provided for @chooseBackup.
  ///
  /// In en, this message translates to:
  /// **'Choose backup file'**
  String get chooseBackup;

  /// No description provided for @pasteBackup.
  ///
  /// In en, this message translates to:
  /// **'Paste backup JSON'**
  String get pasteBackup;

  /// No description provided for @previewBackup.
  ///
  /// In en, this message translates to:
  /// **'Preview backup'**
  String get previewBackup;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Replace with this backup'**
  String get restoreBackup;

  /// No description provided for @backupPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review before restoring'**
  String get backupPreviewTitle;

  /// No description provided for @backupReplaceWarning.
  ///
  /// In en, this message translates to:
  /// **'This replaces the notes, collections, color bookmarks, plans and reader settings on this device. It does not merge them. Download a safety copy first. Reminders will be disabled until you enable them again.'**
  String get backupReplaceWarning;

  /// No description provided for @backupSafetyCopy.
  ///
  /// In en, this message translates to:
  /// **'Download safety copy'**
  String get backupSafetyCopy;

  /// No description provided for @backupSafetyReady.
  ///
  /// In en, this message translates to:
  /// **'Safety copy prepared. Keep the downloaded file before confirming.'**
  String get backupSafetyReady;

  /// No description provided for @backupInvalid.
  ///
  /// In en, this message translates to:
  /// **'This file is invalid, unsupported or larger than 5 MB. Nothing was changed.'**
  String get backupInvalid;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'The operation failed. Your existing data was kept or restored. Keep your safety copy and try again.'**
  String get backupFailed;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored. Reload the app to use the restored settings and plans.'**
  String get backupRestored;

  /// No description provided for @backupRestoredNative.
  ///
  /// In en, this message translates to:
  /// **'Backup restored. Close this confirmation to load the restored data. Reminders remain off.'**
  String get backupRestoredNative;

  /// No description provided for @reloadApp.
  ///
  /// In en, this message translates to:
  /// **'Reload app'**
  String get reloadApp;

  /// No description provided for @backupCopied.
  ///
  /// In en, this message translates to:
  /// **'Private backup copied. Save it to a safe file.'**
  String get backupCopied;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get backupCreated;

  /// No description provided for @shareAyah.
  ///
  /// In en, this message translates to:
  /// **'Share Ayah'**
  String get shareAyah;

  /// No description provided for @shareBody.
  ///
  /// In en, this message translates to:
  /// **'Preview the complete Ayah, then save an image or copy its text or public link.'**
  String get shareBody;

  /// No description provided for @includeTranslation.
  ///
  /// In en, this message translates to:
  /// **'Include translation'**
  String get includeTranslation;

  /// No description provided for @withoutTranslation.
  ///
  /// In en, this message translates to:
  /// **'Arabic only'**
  String get withoutTranslation;

  /// No description provided for @downloadAyahImage.
  ///
  /// In en, this message translates to:
  /// **'Save Ayah image'**
  String get downloadAyahImage;

  /// No description provided for @copyShareText.
  ///
  /// In en, this message translates to:
  /// **'Copy full text'**
  String get copyShareText;

  /// No description provided for @copyAyahLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Ayah link'**
  String get copyAyahLink;

  /// No description provided for @shareCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to the clipboard.'**
  String get shareCopied;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare or save the image. You can still copy the text or link.'**
  String get shareFailed;

  /// No description provided for @shareSource.
  ///
  /// In en, this message translates to:
  /// **'Quran text: King Fahd Quran Complex. Translation resource identified above.'**
  String get shareSource;

  /// No description provided for @savedTextSearch.
  ///
  /// In en, this message translates to:
  /// **'Search saved books'**
  String get savedTextSearch;

  /// No description provided for @savedTextSearchBody.
  ///
  /// In en, this message translates to:
  /// **'Search every Ayah in a bundled or downloaded Tafsir or translation. No book is downloaded automatically and your reader selection is not changed.'**
  String get savedTextSearchBody;

  /// No description provided for @searchBook.
  ///
  /// In en, this message translates to:
  /// **'Book to search'**
  String get searchBook;

  /// No description provided for @searchPhrase.
  ///
  /// In en, this message translates to:
  /// **'Word or phrase (at least 2 characters)'**
  String get searchPhrase;

  /// No description provided for @searchMinimum.
  ///
  /// In en, this message translates to:
  /// **'Enter at least two characters.'**
  String get searchMinimum;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching Ayahs in this book.'**
  String get searchNoResults;

  /// No description provided for @searchSavedOnly.
  ///
  /// In en, this message translates to:
  /// **'Only bundled and downloaded books appear here. Download more from the Library.'**
  String get searchSavedOnly;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get searchResults;

  /// No description provided for @previousResults.
  ///
  /// In en, this message translates to:
  /// **'Previous results'**
  String get previousResults;

  /// No description provided for @nextResults.
  ///
  /// In en, this message translates to:
  /// **'Next results'**
  String get nextResults;

  /// No description provided for @searchLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'This saved book could not be read. Try again, or remove and download it again from the Library.'**
  String get searchLoadFailed;

  /// No description provided for @quranTextTab.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quranTextTab;

  /// No description provided for @localSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Your change could not be saved on this device. The last saved state is kept. Check available storage and try again.'**
  String get localSaveFailed;

  /// No description provided for @localLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Local progress could not be read. No saved data has been replaced. Enable site storage and try again.'**
  String get localLoadFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @planOptions.
  ///
  /// In en, this message translates to:
  /// **'Plan options'**
  String get planOptions;

  /// No description provided for @tenRecitationsTab.
  ///
  /// In en, this message translates to:
  /// **'Ten readings'**
  String get tenRecitationsTab;

  /// No description provided for @readerModeDefault.
  ///
  /// In en, this message translates to:
  /// **'Mushaf'**
  String get readerModeDefault;

  /// No description provided for @readerModeScrollable.
  ///
  /// In en, this message translates to:
  /// **'Scrollable page'**
  String get readerModeScrollable;

  /// No description provided for @readerModeDual.
  ///
  /// In en, this message translates to:
  /// **'Dual page'**
  String get readerModeDual;

  /// No description provided for @readerModeTafsir.
  ///
  /// In en, this message translates to:
  /// **'Quran and Tafsir'**
  String get readerModeTafsir;

  /// No description provided for @readerModeAyahTafsir.
  ///
  /// In en, this message translates to:
  /// **'Ayah with Tafsir'**
  String get readerModeAyahTafsir;

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
  /// **'On web, selected Tafsir and translations can be saved in this browser (up to 160 MiB). Save Surah audio separately under Recitations. Browsers may remove saved files if storage is low. Prepare the app and Quran pages separately in Settings.'**
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

  /// No description provided for @reminderUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'The reminder could not be scheduled or updated. Check notification settings and try again.'**
  String get reminderUpdateFailed;

  /// No description provided for @reminderStateUncertain.
  ///
  /// In en, this message translates to:
  /// **'The reminder state could not be recovered safely. Check notification settings and reopen the app before relying on it.'**
  String get reminderStateUncertain;

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

  /// No description provided for @guideStartHere.
  ///
  /// In en, this message translates to:
  /// **'START HERE'**
  String get guideStartHere;

  /// No description provided for @guideChooseLesson.
  ///
  /// In en, this message translates to:
  /// **'Choose your next lesson'**
  String get guideChooseLesson;

  /// No description provided for @guideLesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson {number} of {total}'**
  String guideLesson(int number, int total);

  /// No description provided for @guideWrittenSteps.
  ///
  /// In en, this message translates to:
  /// **'Follow along, step by step'**
  String get guideWrittenSteps;

  /// No description provided for @guidePauseVideo.
  ///
  /// In en, this message translates to:
  /// **'Pause video'**
  String get guidePauseVideo;

  /// No description provided for @guideRestartVideo.
  ///
  /// In en, this message translates to:
  /// **'Restart video'**
  String get guideRestartVideo;

  /// No description provided for @guideFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Full-screen view'**
  String get guideFullScreen;

  /// No description provided for @guideSeekVideo.
  ///
  /// In en, this message translates to:
  /// **'Video position'**
  String get guideSeekVideo;

  /// No description provided for @guideVideoLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your lesson…'**
  String get guideVideoLoading;

  /// No description provided for @guideVideoRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry video'**
  String get guideVideoRetry;

  /// No description provided for @guideVideoFinished.
  ///
  /// In en, this message translates to:
  /// **'Lesson complete. Replay whenever you need.'**
  String get guideVideoFinished;

  /// No description provided for @guideVideoHint.
  ///
  /// In en, this message translates to:
  /// **'Follow the highlighted pointer and numbered instructions. Nothing plays until you choose Play.'**
  String get guideVideoHint;

  /// No description provided for @guideNativeFiles.
  ///
  /// In en, this message translates to:
  /// **'On Android, choose a private save location in the system document chooser. On iOS, use the system share sheet to save or share the file. Use the document chooser to restore a JSON backup.'**
  String get guideNativeFiles;

  /// No description provided for @guideNativeShareImage.
  ///
  /// In en, this message translates to:
  /// **'Save or share Ayah image'**
  String get guideNativeShareImage;

  /// No description provided for @guideNativeSaveImage.
  ///
  /// In en, this message translates to:
  /// **'Save Ayah image'**
  String get guideNativeSaveImage;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy and contact'**
  String get privacyTitle;

  /// No description provided for @privacyLocalSummary.
  ///
  /// In en, this message translates to:
  /// **'Quran Haven is free and has no accounts or advertising. Your bookmarks, notes, plans, reading position and preferences stay on this device or in this browser. Clearing app or browser data may erase them. Backup export, file restore and sharing happen only when you choose them; you control the destination.'**
  String get privacyLocalSummary;

  /// No description provided for @privacyNetworkSummary.
  ///
  /// In en, this message translates to:
  /// **'Online reading resources and recitations contact the project host and audio/content providers. These requests reveal network information such as your IP address and requested files; providers may keep technical access logs. The website also uses a Cloudflare beacon for performance and usage analytics. Your personal notes and progress are not automatically uploaded.'**
  String get privacyNetworkSummary;

  /// No description provided for @privacyOpen.
  ///
  /// In en, this message translates to:
  /// **'Read the full privacy policy'**
  String get privacyOpen;

  /// No description provided for @contactProject.
  ///
  /// In en, this message translates to:
  /// **'Contact the project'**
  String get contactProject;

  /// No description provided for @copyContactEmail.
  ///
  /// In en, this message translates to:
  /// **'Copy contact email'**
  String get copyContactEmail;

  /// No description provided for @privacyLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'The address was copied. Open it in your browser or email app.'**
  String get privacyLinkCopied;

  /// No description provided for @privacyLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'The address could not be opened or copied. Use the address shown here.'**
  String get privacyLinkFailed;

  /// No description provided for @backupSafetyConfirm.
  ///
  /// In en, this message translates to:
  /// **'I have saved the safety copy in a private place.'**
  String get backupSafetyConfirm;

  /// No description provided for @backupRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Your backup was restored. Close and reopen the app to load the restored data.'**
  String get backupRefreshFailed;

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
  /// **'Reduced motion is enabled. The preview remains still; you may choose Play if you wish.'**
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
  /// **'Use page arrows on the website, or swipe on a touch device to change pages. Your last-read position is saved automatically on this device.'**
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
  /// **'Select a search result. The panel closes and opens the Mushaf at that Ayah automatically. Press and hold an Ayah to open its actions.'**
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
  /// **'Online audio comes from external recitation providers. Download complete Surah recordings separately under Recitations for offline listening; word-by-word audio still needs internet.'**
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
  /// **'Browsers may remove saved files when space is low. Private browsing is not suitable for lasting storage. App preparation, downloaded books and saved Surah recordings are separate downloads.'**
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
  /// **'Clearing app/site data or losing the device can erase saved items. Use Local backup in Settings to export personal data privately; downloaded books and audio are not included.'**
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

  /// No description provided for @guideRotateHint.
  ///
  /// In en, this message translates to:
  /// **'Rotate your phone for a wider view, or zoom in and drag to inspect the demonstration.'**
  String get guideRotateHint;

  /// No description provided for @guideZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get guideZoomIn;

  /// No description provided for @guideZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get guideZoomOut;

  /// No description provided for @creatorCreditTitle.
  ///
  /// In en, this message translates to:
  /// **'Created by YahyazLab'**
  String get creatorCreditTitle;

  /// No description provided for @quranBrandLabel.
  ///
  /// In en, this message translates to:
  /// **'Quran Haven: open Quran book logo'**
  String get quranBrandLabel;

  /// No description provided for @creatorCreditHint.
  ///
  /// In en, this message translates to:
  /// **'Creator’s external website'**
  String get creatorCreditHint;

  /// No description provided for @creatorCreditSemantics.
  ///
  /// In en, this message translates to:
  /// **'Created by YahyazLab. Open the creator’s external website after confirmation.'**
  String get creatorCreditSemantics;

  /// No description provided for @creatorExternalTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re leaving Quran Haven'**
  String get creatorExternalTitle;

  /// No description provided for @creatorExternalBody.
  ///
  /// In en, this message translates to:
  /// **'This is the creator’s game-development portfolio, not a Quran-content website. It will open in your browser.'**
  String get creatorExternalBody;

  /// No description provided for @creatorGuardianReminder.
  ///
  /// In en, this message translates to:
  /// **'Children: ask a parent or guardian before continuing.'**
  String get creatorGuardianReminder;

  /// No description provided for @creatorContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue to website'**
  String get creatorContinue;

  /// No description provided for @creatorOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'The external website could not be opened. You can keep using Quran Haven.'**
  String get creatorOpenFailed;
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
