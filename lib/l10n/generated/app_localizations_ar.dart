// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get corpusEmptyForm => 'لا توجد صيغة كتابية مستقلة في المصدر';

  @override
  String get corpusAcquisition => 'سجل الحصول على المصدر وتوثيقه';

  @override
  String get corpusLearning => 'تحليل الكلمات صرفياً';

  @override
  String get corpusLearningBody =>
      'استكشف مقاطع الكلمات وتصنيفها وجذورها وصيغها المعجمية في Quranic Arabic Corpus الإصدار 0.4. هذا مصدر تعليمي وليس بديلاً عن نص مصحف مجمع الملك فهد.';

  @override
  String get corpusOffline => 'مضمّن للتعلّم دون إنترنت';

  @override
  String get corpusWord => 'الكلمة';

  @override
  String get corpusSegment => 'المقطع';

  @override
  String get corpusPartOfSpeech => 'نوع الكلمة';

  @override
  String get corpusRoot => 'الجذر';

  @override
  String get corpusLemma => 'الصيغة المعجمية';

  @override
  String get corpusOriginalForm => 'الصيغة الأصلية بترميز Buckwalter';

  @override
  String get corpusOriginalCodes => 'رموز الخصائص الأصلية';

  @override
  String get corpusSource => 'المصدر والترخيص';

  @override
  String get corpusSourceBody =>
      'حُفظت البيانات الأصلية وإشعاراتها دون تعديل. يتبع ترقيم الكلمات وصيغها هنا المصدر الأصلي، مستقلاً عن عرض المصحف. تظهر الرموز كما سُجلت؛ لا تولّد هذه الصفحة تأويلات أو ترجمات.';

  @override
  String get corpusLoadFailed =>
      'تعذر التحقق من المصدر التعليمي كاملاً أو تحميله. لا تُعرض بيانات تحليل جزئية. أعد المحاولة.';

  @override
  String get corpusPreviousAyah => 'الآية السابقة';

  @override
  String get corpusNextAyah => 'الآية التالية';

  @override
  String get corpusPrefix => 'بادئة';

  @override
  String get corpusStem => 'جذع الكلمة';

  @override
  String get corpusSuffix => 'لاحقة';

  @override
  String get corpusSourceDownload => 'المصدر الرسمي والتحديثات';

  @override
  String get corpusTagsetDocs => 'توثيق أنواع الكلمات الرسمي';

  @override
  String get corpusFeaturesDocs => 'توثيق الصرف الرسمي';

  @override
  String get corpusBuckwalterDocs => 'توثيق ترميز Buckwalter';

  @override
  String get corpusTanzilSource => 'مصدر نص Tanzil وتحديثاته';

  @override
  String get corpusLicense => 'نص ترخيص GNU GPL الكامل للبيانات';

  @override
  String get corpusIdentity => 'هوية البيانات الأصلية الثابتة';

  @override
  String get corpusLinkCopied => 'نُسخ رابط المصدر. افتحه في متصفحك.';

  @override
  String get corpusGuideStep1 =>
      'المكتبة ← تحليل الكلمات صرفياً تفتح صفحة التعلّم المضمّنة. يمكنك أيضاً الضغط مطوّلاً على آية في القارئ واختيار تحليل الكلمات صرفياً.';

  @override
  String get corpusGuideStep2 =>
      'اختر سورة وآية، أو استخدم الآية السابقة والتالية. تُعرض مقاطع كل كلمة كما سُجلت، مع نوعها وجذرها وصيغتها المعجمية إن وُجدت.';

  @override
  String get corpusGuideStep3 =>
      'تبقى رموز الخصائص الأصلية ظاهرة. يفتح المصدر والترخيص إشعارات الحقوق المحفوظة ونص الترخيص وروابط التوثيق الرسمي. هذا تحليل صرفي، وليس تفسيراً آلياً أو إعراباً تركيبياً كاملاً.';

  @override
  String get shareArabicSource =>
      'نص القرآن: مجمع الملك فهد لطباعة المصحف الشريف.';

  @override
  String get audioDownloadSelection => 'التسجيل المختار';

  @override
  String get corpusPosN => 'اسم';

  @override
  String get corpusPosPN => 'اسم علم';

  @override
  String get corpusPosADJ => 'صفة';

  @override
  String get corpusPosIMPN => 'اسم فعل أمر';

  @override
  String get corpusPosPRON => 'ضمير';

  @override
  String get corpusPosDEM => 'اسم إشارة';

  @override
  String get corpusPosREL => 'اسم موصول';

  @override
  String get corpusPosT => 'ظرف زمان';

  @override
  String get corpusPosLOC => 'ظرف مكان';

  @override
  String get corpusPosV => 'فعل';

  @override
  String get corpusPosP => 'حرف جر';

  @override
  String get corpusPosDET => 'بادئة التعريف';

  @override
  String get corpusPosEMPH => 'لام التوكيد';

  @override
  String get corpusPosIMPV => 'لام الأمر';

  @override
  String get corpusPosPRP => 'لام التعليل';

  @override
  String get corpusPosCONJ => 'حرف عطف';

  @override
  String get corpusPosSUB => 'حرف مصدري';

  @override
  String get corpusPosACC => 'حرف نصب';

  @override
  String get corpusPosAMD => 'حرف استدراك';

  @override
  String get corpusPosANS => 'حرف جواب';

  @override
  String get corpusPosAVR => 'حرف ردع';

  @override
  String get corpusPosCAUS => 'حرف سببية';

  @override
  String get corpusPosCERT => 'حرف تحقيق';

  @override
  String get corpusPosCIRC => 'حرف حال';

  @override
  String get corpusPosCOM => 'واو المعية';

  @override
  String get corpusPosCOND => 'حرف شرط';

  @override
  String get corpusPosEQ => 'حرف تسوية';

  @override
  String get corpusPosEXH => 'حرف تحضيض';

  @override
  String get corpusPosEXL => 'حرف تفصيل';

  @override
  String get corpusPosEXP => 'أداة استثناء';

  @override
  String get corpusPosFUT => 'حرف استقبال';

  @override
  String get corpusPosINC => 'حرف ابتداء';

  @override
  String get corpusPosINT => 'حرف تفسير';

  @override
  String get corpusPosINTG => 'حرف استفهام';

  @override
  String get corpusPosNEG => 'حرف نفي';

  @override
  String get corpusPosPREV => 'حرف كاف';

  @override
  String get corpusPosPRO => 'حرف نهي';

  @override
  String get corpusPosREM => 'حرف استئنافية';

  @override
  String get corpusPosRES => 'أداة حصر';

  @override
  String get corpusPosRET => 'حرف إضراب';

  @override
  String get corpusPosRSLT => 'حرف واقع في جواب الشرط';

  @override
  String get corpusPosSUP => 'حرف زائد';

  @override
  String get corpusPosSUR => 'حرف فجاءة';

  @override
  String get corpusPosVOC => 'حرف نداء';

  @override
  String get corpusPosINL => 'حروف مقطعة';

  @override
  String get backupNativeHint =>
      'في نسخة الهاتف هذه ينسخ التصدير ملف JSON إلى الحافظة. استعادة الملفات وتنزيل PNG متاحان على الموقع؛ لم تُفعّل أدوات الملفات الأصلية بعد.';

  @override
  String get backupRecoveryFailed =>
      'رفض التخزين الاستعادة والتراجع معاً. قد لا تكون الاستعادة مكتملة. احتفظ بنسخة الأمان ولا تمسح بيانات التطبيق أو الموقع.';

  @override
  String get guidePersonalTitle => 'الملاحظات والمجموعات';

  @override
  String get guidePersonalStep1 =>
      'افتح المكتبة ← مساحتي القرآنية. أنشئ ملاحظة مرتبطة بسورة وآية، أو مجموعة باسم تختاره.';

  @override
  String get guidePersonalStep2 =>
      'اضغط مطوّلاً على آية في القارئ، ثم اختر إضافة ملاحظة أو إضافة إلى مجموعة. تبقى العلامات الملونة متاحة.';

  @override
  String get guidePersonalStep3 =>
      'استخدم التعديل لتغيير النص أو اسم المجموعة. يعيدك فتح الآية إلى القارئ، ويطلب الحذف تأكيدك.';

  @override
  String get guideBackupStep1 =>
      'من الإعدادات ← نسخة احتياطية محلية، صدّر ملف JSON واحتفظ به خصوصياً في مكان آمن. يشمل بياناتك النصية لا الصوت أو الكتب المنزّلة.';

  @override
  String get guideBackupStep2 =>
      'اختر ملف النسخة أو الصق محتواه. راجع تاريخها وعدد العناصر؛ تُرفض الملفات غير الصالحة أو الكبيرة دون تغيير البيانات.';

  @override
  String get guideBackupStep3 =>
      'احفظ نسخة أمان، ثم أكّد الاستبدال صراحةً. تستبدل النسخة البيانات الحالية ولا تدمجها. على الموقع اختر إعادة التحميل؛ وفي تطبيق الهاتف أغلق رسالة التأكيد لتحديث الواجهة. تبقى التذكيرات معطّلة.';

  @override
  String get guideShareSearchTitle => 'مشاركة الآيات والبحث في الكتب';

  @override
  String get guideShareSearchStep1 =>
      'اضغط مطوّلاً على آية ← مشاركة الآية. عاين النص العربي كاملاً، واختر ترجمة محفوظة اختيارياً، ثم احفظ صورة PNG أو انسخ النص أو الرابط.';

  @override
  String get guideShareSearchStep2 =>
      'يفتح الرابط العام السورة والآية المحددتين. لا تُرفق ملاحظاتك أو مجموعاتك الخاصة بالرابط أو الصورة.';

  @override
  String get guideShareSearchStep3 =>
      'المكتبة ← البحث في الكتب المحفوظة يبحث في كامل التفسير أو الترجمة المختارة، لا الصفحة الحالية فقط. أدخل حرفين على الأقل، ثم تصفح النتائج وافتح الآية.';

  @override
  String get guideSavedAudioStep1 =>
      'من المكتبة ← التلاوات، اختر سورة. يحدد القارئ المختار في القارئ التسجيل المراد تنزيله.';

  @override
  String get guideSavedAudioStep2 =>
      'اضغط تنزيل دون إنترنت، وتابع التقدم أو ألغِ التنزيل. تُحفظ التسجيلات الكاملة المتحقّق منها فقط؛ لا يبدأ التنزيل تشغيل الصوت.';

  @override
  String get guideSavedAudioStep3 =>
      'تحت تسجيلات السور المحفوظة توجد إجراءات التشغيل والحذف. جهّز التطبيق دون إنترنت منفصلاً من الإعدادات ليُفتح الموقع دون اتصال.';

  @override
  String get browserAudioTitle => 'تسجيلات السور المحفوظة';

  @override
  String get browserAudioBody =>
      'نزّل سورة كاملة بصوت القارئ المختار. هذا منفصل عن تجهيز التطبيق دون إنترنت وصوت الكلمات. يبدأ التشغيل فقط عند ضغط تشغيل. قد يُمسح تخزين المتصفح أو تُفرغ مساحته.';

  @override
  String get browserAudioEmpty => 'لم تُحفظ تسجيلات سور في هذا المتصفح بعد.';

  @override
  String get browserAudioUnavailable =>
      'التخزين الدائم للصوت غير متاح في هذا المتصفح. لا يزال التشغيل عبر الإنترنت متاحاً.';

  @override
  String get browserAudioStorageFull =>
      'مساحة المتصفح غير كافية. أزل تسجيلاً محفوظاً وأعد المحاولة.';

  @override
  String get browserAudioCancelled => 'أُلغي التنزيل. لم يُحفظ تسجيل جزئي.';

  @override
  String get browserAudioDelete =>
      'هل تريد إزالة هذا التسجيل من هذا المتصفح؟ ستبقى التسجيلات الأخرى وبياناتك الشخصية محفوظة.';

  @override
  String get browserAudioBusy => 'يوجد تنزيل صوتي آخر قيد التنفيذ.';

  @override
  String get browserAudioTooLarge =>
      'يتجاوز هذا التسجيل الحد الأقصى لكل ملف (٢٥٦ ميجابايت).';

  @override
  String get personalTools => 'مساحتي القرآنية';

  @override
  String get personalToolsBody =>
      'ملاحظاتك ومجموعاتك المحفوظة تبقى على هذا الجهاز.';

  @override
  String get personalNotes => 'ملاحظات الآيات';

  @override
  String get personalCollections => 'المجموعات';

  @override
  String get addNote => 'إضافة ملاحظة';

  @override
  String get editNote => 'تعديل الملاحظة';

  @override
  String get noteTitle => 'العنوان (اختياري)';

  @override
  String get noteBody => 'تأملك في الآية';

  @override
  String get notesEmpty =>
      'دوّن تأملك بجانب الآية. أضف ملاحظة هنا أو من قائمة الآية في القارئ.';

  @override
  String get createCollection => 'إنشاء مجموعة';

  @override
  String get editCollection => 'تغيير اسم المجموعة';

  @override
  String get collectionName => 'اسم المجموعة';

  @override
  String get collectionsEmpty =>
      'نظّم الآيات في مجموعات بأسماء تختارها. تبقى العلامات الملونة الحالية كما هي.';

  @override
  String get collectionEmpty =>
      'لا توجد آيات بعد. أضف آية من القارئ أو استخدم إضافة آية.';

  @override
  String get addAyah => 'إضافة آية';

  @override
  String get openAyah => 'فتح الآية';

  @override
  String get removeAyah => 'إزالة الآية';

  @override
  String get addToCollection => 'إضافة إلى مجموعة';

  @override
  String get deletePersonalConfirm =>
      'هل تريد حذف هذا العنصر من هذا الجهاز؟ لا يمكن التراجع عن الحذف.';

  @override
  String get personalSaved => 'تم الحفظ على هذا الجهاز.';

  @override
  String get personalDuplicate => 'هذه الآية موجودة في المجموعة بالفعل.';

  @override
  String get personalLimit =>
      'تم الوصول إلى الحد الأقصى المحلي للملاحظات أو المجموعات. صدّر نسخة احتياطية قبل إزالة العناصر القديمة.';

  @override
  String get requiredText => 'أدخل النص للمتابعة.';

  @override
  String get invalidAyahLink =>
      'رابط الآية غير صالح. تم الاحتفاظ بموضع قراءتك الأخير.';

  @override
  String get backupTitle => 'نسخة احتياطية محلية';

  @override
  String get backupBody =>
      'صدّر ملف JSON خاصاً بملاحظاتك ومجموعاتك وعلاماتك وخططك وإعدادات القراءة. لا يشمل الصوت أو الكتب المنزّلة. احتفظ به في مكان آمن؛ لا تُرسل نسخة إلى أي خادم.';

  @override
  String get exportBackup => 'تصدير نسخة احتياطية';

  @override
  String get chooseBackup => 'اختيار ملف النسخة';

  @override
  String get pasteBackup => 'لصق ملف JSON';

  @override
  String get previewBackup => 'معاينة النسخة';

  @override
  String get restoreBackup => 'استبدال البيانات بهذه النسخة';

  @override
  String get backupPreviewTitle => 'مراجعة قبل الاستعادة';

  @override
  String get backupReplaceWarning =>
      'سيستبدل هذا ملاحظاتك ومجموعاتك وعلاماتك الملونة وخططك وإعدادات القراءة على هذا الجهاز؛ لن يتم دمجها. نزّل نسخة أمان أولاً. ستُعطّل التذكيرات حتى تفعّلها مجدداً.';

  @override
  String get backupSafetyCopy => 'تنزيل نسخة أمان';

  @override
  String get backupSafetyReady =>
      'تم تجهيز نسخة الأمان. احتفظ بالملف المنزّل قبل التأكيد.';

  @override
  String get backupInvalid =>
      'الملف غير صالح أو غير مدعوم أو أكبر من ٥ ميجابايت. لم تتغير أي بيانات.';

  @override
  String get backupFailed =>
      'تعذرت العملية. تم الاحتفاظ ببياناتك السابقة أو إعادتها. احتفظ بنسخة الأمان وأعد المحاولة.';

  @override
  String get backupRestored =>
      'تمت استعادة النسخة. أعد تحميل التطبيق لاستخدام الإعدادات والخطط المستعادة.';

  @override
  String get backupRestoredNative =>
      'تمت استعادة النسخة. أغلق رسالة التأكيد هذه لتحميل البيانات المستعادة. تبقى التذكيرات معطّلة.';

  @override
  String get reloadApp => 'إعادة تحميل التطبيق';

  @override
  String get backupCopied => 'تم نسخ النسخة الخاصة. احفظها في ملف آمن.';

  @override
  String get backupCreated => 'تاريخ الإنشاء';

  @override
  String get shareAyah => 'مشاركة الآية';

  @override
  String get shareBody =>
      'عاين الآية كاملة، ثم احفظ صورة أو انسخ النص أو الرابط العام.';

  @override
  String get includeTranslation => 'إرفاق ترجمة';

  @override
  String get withoutTranslation => 'العربية فقط';

  @override
  String get downloadAyahImage => 'حفظ صورة الآية';

  @override
  String get copyShareText => 'نسخ النص الكامل';

  @override
  String get copyAyahLink => 'نسخ رابط الآية';

  @override
  String get shareCopied => 'تم النسخ إلى الحافظة.';

  @override
  String get shareFailed =>
      'تعذر تجهيز الصورة أو حفظها. لا يزال بإمكانك نسخ النص أو الرابط.';

  @override
  String get shareSource =>
      'نص القرآن: مجمع الملك فهد لطباعة المصحف الشريف. مورد الترجمة محدد أعلاه.';

  @override
  String get savedTextSearch => 'البحث في الكتب المحفوظة';

  @override
  String get savedTextSearchBody =>
      'ابحث في جميع آيات التفسير أو الترجمة المضمّنة أو المنزّلة. لا يُنزّل أي كتاب تلقائياً ولا يتغير اختيارك في القارئ.';

  @override
  String get searchBook => 'الكتاب المراد البحث فيه';

  @override
  String get searchPhrase => 'كلمة أو عبارة (حرفان على الأقل)';

  @override
  String get searchMinimum => 'أدخل حرفين على الأقل.';

  @override
  String get searchNoResults => 'لا توجد آيات مطابقة في هذا الكتاب.';

  @override
  String get searchSavedOnly =>
      'تظهر هنا الكتب المضمّنة والمنزّلة فقط. نزّل المزيد من المكتبة.';

  @override
  String get searchResults => 'النتائج';

  @override
  String get previousResults => 'النتائج السابقة';

  @override
  String get nextResults => 'النتائج التالية';

  @override
  String get searchLoadFailed =>
      'تعذرت قراءة هذا الكتاب المحفوظ. أعد المحاولة أو احذفه ونزّله مجدداً من المكتبة.';

  @override
  String get quranTextTab => 'القرآن الكريم';

  @override
  String get localSaveFailed =>
      'تعذّر حفظ التغيير على هذا الجهاز. تم الاحتفاظ بآخر حالة محفوظة. تحقق من مساحة التخزين وحاول مجددًا.';

  @override
  String get localLoadFailed =>
      'تعذّر قراءة التقدم المحلي. لم يتم استبدال أي بيانات محفوظة. فعّل تخزين الموقع وحاول مجددًا.';

  @override
  String get retry => 'حاول مجددًا';

  @override
  String get planOptions => 'خيارات الخطة';

  @override
  String get tenRecitationsTab => 'القراءات العشر';

  @override
  String get readerModeDefault => 'المصحف';

  @override
  String get readerModeScrollable => 'صفحة قابلة للتمرير';

  @override
  String get readerModeDual => 'صفحتان';

  @override
  String get readerModeTafsir => 'القرآن والتفسير';

  @override
  String get readerModeAyahTafsir => 'الآية مع التفسير';

  @override
  String get appName => 'القرآن الكريم';

  @override
  String get home => 'الرئيسية';

  @override
  String get quran => 'المصحف';

  @override
  String get library => 'المكتبة';

  @override
  String get plans => 'الخطط';

  @override
  String get settings => 'الإعدادات';

  @override
  String get greeting => 'السلام عليكم';

  @override
  String get heroTitle => 'رفيقك الهادئ مع القرآن';

  @override
  String get heroBody =>
      'اقرأ واستمع وتدبّر وابنِ وردًا يوميًا دائمًا — مجانًا للجميع.';

  @override
  String get startReading => 'فتح المصحف';

  @override
  String lastReadPage(int page) {
    return 'آخر قراءة · الصفحة $page';
  }

  @override
  String get quickAccess => 'وصول سريع';

  @override
  String get browseSurahs => 'فهرس السور';

  @override
  String get searchQuran => 'البحث في القرآن';

  @override
  String get bookmarks => 'العلامات المرجعية';

  @override
  String get downloads => 'التنزيلات';

  @override
  String get dailyJourney => 'رحلتك اليومية';

  @override
  String get dailyJourneyBody => 'أنشئ خطة ختمة وواصل التقدم في أهداف الحفظ.';

  @override
  String get comingSoon => 'قادم في مرحلة لاحقة';

  @override
  String get charityMessage => 'مجاني للجميع، صدقة جارية.';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get system => 'النظام';

  @override
  String get about => 'عن المشروع';

  @override
  String get aboutBody =>
      'منصة قرآنية خيرية بلا إعلانات أو اشتراكات أو ميزات مدفوعة.';

  @override
  String get index => 'الفهرس';

  @override
  String get search => 'البحث';

  @override
  String get surahs => 'السور';

  @override
  String get juz => 'الأجزاء';

  @override
  String get hizb => 'الحزب';

  @override
  String get sajda => 'سجدة';

  @override
  String get searchHint => 'ابحث في القرآن أو عن سورة';

  @override
  String get noBookmarks =>
      'لا توجد علامات محفوظة. اضغط مطولًا على آية لحفظها.';

  @override
  String get yellowBookmarks => 'العلامات الصفراء';

  @override
  String get redBookmarks => 'العلامات الحمراء';

  @override
  String get greenBookmarks => 'العلامات الخضراء';

  @override
  String get ayahCopied => 'تم نسخ الآية';

  @override
  String get quickNavigate => 'تنقل سريع';

  @override
  String get page => 'الصفحة';

  @override
  String get goToPage => 'انتقل إلى الصفحة';

  @override
  String get pageRangeHint => 'أدخل رقم صفحة من ١ إلى ٦٠٤';

  @override
  String get invalidPage => 'أدخل رقم صفحة من ١ إلى ٦٠٤';

  @override
  String get readerMenuHint =>
      'تتضمن قائمة المصحف فهرس السور والأجزاء والبحث والعلامات المحفوظة.';

  @override
  String juzNumber(int number) {
    return 'الجزء $number';
  }

  @override
  String get contentLibrary => 'مكتبة القرآن';

  @override
  String get contentLibraryBody =>
      'اختر التفاسير والترجمات، واستمع إلى التلاوات، وجهّز المحتوى للاستخدام دون إنترنت.';

  @override
  String get tafsir => 'التفسير';

  @override
  String get translations => 'الترجمات';

  @override
  String get recitations => 'التلاوات';

  @override
  String get selected => 'محدد';

  @override
  String get available => 'متاح';

  @override
  String get download => 'تنزيل';

  @override
  String get downloading => 'جارٍ التنزيل…';

  @override
  String get select => 'اختيار';

  @override
  String get resourceReady => 'أصبح المصدر المحدد جاهزًا في المصحف.';

  @override
  String get resourceFailed =>
      'تعذر تجهيز المصدر. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get resourceHint => 'تبقى المصادر المنزلة متاحة دون اتصال على الهاتف.';

  @override
  String get chooseSurah => 'اختر سورة';

  @override
  String get play => 'تشغيل';

  @override
  String get resumeListening => 'متابعة الاستماع';

  @override
  String get downloadForOffline => 'تنزيل للاستماع دون اتصال';

  @override
  String get cancelDownload => 'إلغاء التنزيل';

  @override
  String get downloadComplete => 'أصبحت السورة جاهزة للاستماع دون اتصال.';

  @override
  String get downloadFailed =>
      'فشل تنزيل الصوت. تحقق من الاتصال ومساحة التخزين.';

  @override
  String get openReaderControls => 'فتح أدوات الصوت في المصحف';

  @override
  String get readerAudioHint =>
      'استخدم أدوات الصوت في المصحف لاختيار القارئ وإدارة السور المنزلة.';

  @override
  String get webOfflineNote =>
      'على الويب، يمكنك حفظ التفسير والترجمات في هذا المتصفح (حتى 160 MiB). احفظ صوت السور منفصلاً من التلاوات. قد يزيل المتصفح الملفات عند نقص المساحة. جهّز التطبيق وصفحات القرآن منفصلاً من الإعدادات.';

  @override
  String get webResourceStorageUnavailable =>
      'لا يستطيع هذا المتصفح حفظ مصادر القراءة. استخدم متصفحًا مدعومًا مع تفعيل تخزين بيانات المواقع.';

  @override
  String get readers => 'القراء';

  @override
  String get downloadedSurahs => 'السور المنزلة';

  @override
  String get chooseReader => 'اختر قارئًا';

  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get ayahSingular => 'آية';

  @override
  String get ayahPlural => 'آيات';

  @override
  String get lastListen => 'آخر استماع';

  @override
  String get translation => 'الترجمة';

  @override
  String get footnotes => 'الحواشي';

  @override
  String get tafsirEmpty => 'نزّل أو اختر تفسيرًا أو ترجمة لعرضها هنا.';

  @override
  String get plansTitle => 'رحلتك مع القرآن';

  @override
  String get plansBody =>
      'خطط لختمة، وتدرّب على الحفظ، وتابع تقدّمك بالوتيرة المناسبة لك.';

  @override
  String get khatmah => 'الختمة';

  @override
  String get memorization => 'الحفظ';

  @override
  String get noKhatmah => 'ابدأ خطة ختمة';

  @override
  String get noKhatmahBody =>
      'اختر مدة الإكمال وسيحسب التطبيق مقدارًا يوميًا مناسبًا للقراءة.';

  @override
  String get createKhatmah => 'إنشاء خطة ختمة';

  @override
  String get createKhatmahBody =>
      'حدّد هدفًا مريحًا، ويمكنك إيقاف الخطة مؤقتًا أو تعديل تاريخها.';

  @override
  String get completionPeriod => 'مدة الإكمال';

  @override
  String daysCount(int days) {
    return '$days يومًا';
  }

  @override
  String get ramadanPlan => 'خطة رمضان';

  @override
  String get ramadanPlanBody => 'خطة مركّزة لإتمام القرآن خلال 30 يومًا.';

  @override
  String get continueFromLastRead => 'المتابعة من آخر صفحة قرأتها';

  @override
  String startAtPage(int page) {
    return 'احتساب التقدّم من الصفحة $page';
  }

  @override
  String get startPlan => 'بدء الخطة';

  @override
  String get activeKhatmah => 'الختمة الحالية';

  @override
  String get ramadanKhatmah => 'ختمة رمضان';

  @override
  String get paused => 'متوقفة مؤقتًا';

  @override
  String targetDate(String date) {
    return 'الهدف: $date';
  }

  @override
  String get adjustDate => 'تعديل تاريخ الهدف';

  @override
  String get deletePlan => 'حذف الخطة';

  @override
  String get deletePlanBody => 'سيُحذف تقدّم هذه الختمة من هذا الجهاز.';

  @override
  String pagesOfTotal(int completed, int total) {
    return '$completed من $total صفحة';
  }

  @override
  String get pagesToday => 'صفحات اليوم';

  @override
  String get pagesRemaining => 'الصفحات المتبقية';

  @override
  String get daysRemaining => 'الأيام المتبقية';

  @override
  String get completeToday => 'إكمال هدف اليوم';

  @override
  String get khatmahComplete => 'اكتملت الختمة';

  @override
  String get updateProgress => 'تحديث التقدّم';

  @override
  String get pagesCompleted => 'الصفحات المكتملة';

  @override
  String get pausePlan => 'إيقاف الخطة مؤقتًا';

  @override
  String get resumePlan => 'متابعة الخطة';

  @override
  String get progressSavedLocally =>
      'يُحفظ تقدّمك على جهازك ويبقى متاحًا دون اتصال.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get noMemorization => 'أنشئ نطاقًا للحفظ';

  @override
  String get noMemorizationBody =>
      'اختر سورة ونطاق آيات، ثم تدرّب بالتكرار وإخفاء النص وعلامات المراجعة.';

  @override
  String get createMemorization => 'إنشاء خطة حفظ';

  @override
  String get createMemorizationBody =>
      'اختر نطاق آيات محددًا ونمط التكرار الذي تفضّله.';

  @override
  String get newRange => 'نطاق جديد';

  @override
  String get startAyah => 'آية البداية';

  @override
  String get endAyah => 'آية النهاية';

  @override
  String get repetitionsPerAyah => 'تكرار كل آية';

  @override
  String get rangeRepetitions => 'تكرار النطاق كاملًا';

  @override
  String get delayBetween => 'الفاصل بين التكرارات';

  @override
  String secondsCount(int seconds) {
    return '$seconds ث';
  }

  @override
  String get startWithAyahHidden => 'بدء التدريب مع إخفاء الآية';

  @override
  String get startMemorizing => 'بدء الحفظ';

  @override
  String ayahRangeError(int maximum) {
    return 'أدخل رقم آية من 1 إلى $maximum';
  }

  @override
  String get endBeforeStart => 'يجب أن تكون آية النهاية بعد آية البداية.';

  @override
  String ayahRange(int start, int end) {
    return 'الآيات $start–$end';
  }

  @override
  String currentAyah(int ayah) {
    return 'الآية الحالية · $ayah';
  }

  @override
  String get ayahHidden => 'اقرأ من حفظك، ثم أظهر الآية للتحقق.';

  @override
  String get hideAyah => 'إخفاء الآية';

  @override
  String get revealAyah => 'إظهار الآية';

  @override
  String repeatCount(int count) {
    return 'تكرار ×$count';
  }

  @override
  String delayCount(int seconds) {
    return 'فاصل $seconds ث';
  }

  @override
  String get repeatCurrent => 'تكرار الآية الحالية';

  @override
  String get repeatRange => 'تكرار النطاق كاملًا';

  @override
  String get stop => 'إيقاف';

  @override
  String get openInMushaf => 'فتح في المصحف';

  @override
  String get markForRevision => 'تحديد للمراجعة';

  @override
  String get markMemorized => 'تحديد كمحفوظة';

  @override
  String get memorized => 'محفوظة';

  @override
  String get deleteMemorizationBody =>
      'سيُحذف نطاق الحفظ وتقدّمه من هذا الجهاز.';

  @override
  String get audioFailed =>
      'تعذّر تشغيل صوت التدريب. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get previousAyah => 'الآية السابقة';

  @override
  String get nextAyah => 'الآية التالية';

  @override
  String get removeRevisionMarker => 'إلغاء التحديد للمراجعة';

  @override
  String get dailyReminder => 'تذكير القراءة اليومي';

  @override
  String get remindMeDaily => 'ذكّرني كل يوم';

  @override
  String get reminderBody =>
      'استلم تذكيرًا لطيفًا واحدًا في الوقت الذي تختاره.';

  @override
  String get reminderMobileOnly =>
      'التذكيرات المجدولة متاحة حاليًا في تطبيقي أندرويد وiOS.';

  @override
  String reminderTime(String time) {
    return 'وقت التذكير: $time';
  }

  @override
  String get dailyReminderTitle => 'لحظة مع القرآن';

  @override
  String get dailyReminderBody =>
      'خذ لحظة هادئة اليوم للقراءة أو الاستماع أو المراجعة.';

  @override
  String get reminderEnabled => 'تم تفعيل تذكير القرآن اليومي.';

  @override
  String get reminderUpdateFailed =>
      'تعذر جدولة التذكير أو تحديثه. تحقق من إعدادات الإشعارات وحاول مجدداً.';

  @override
  String get reminderStateUncertain =>
      'تعذر استعادة حالة التذكير بأمان. تحقق من إعدادات الإشعارات وأعد فتح التطبيق قبل الاعتماد عليه.';

  @override
  String get notificationDenied => 'لم يتم منح إذن الإشعارات.';

  @override
  String get contentServerNotConfigured =>
      'القرآن والتفسير المرفق والملفات المحمّلة متاحة. ستتوفر مصادر القراءة الإضافية عند ربط خدمة المحتوى.';

  @override
  String get offlineTitle => 'القراءة دون اتصال';

  @override
  String get offlineBody =>
      'احفظ التطبيق وصفحات القرآن في هذا المتصفح قبل قطع الاتصال. يمكنك حفظ التفسير والترجمات بشكل منفصل من المكتبة. لا تشمل هذه العملية الملفات الصوتية.';

  @override
  String get offlinePrepare => 'تجهيز القراءة دون اتصال';

  @override
  String get offlinePreparing => 'جارٍ حفظ القرآن للقراءة دون اتصال…';

  @override
  String get offlineReady => 'جاهز للقراءة دون اتصال';

  @override
  String get offlineUpdateReady => 'تحديث القراءة دون اتصال جاهز';

  @override
  String get offlineActivate => 'تطبيق التحديث وإعادة التحميل';

  @override
  String get offlineCancel => 'إلغاء التحميل';

  @override
  String get offlineRemove => 'إزالة ملفات التطبيق المحفوظة دون اتصال';

  @override
  String get offlineRemoveWarning =>
      'هل تريد إزالة ملفات التطبيق وصفحات القرآن المحفوظة فقط من هذا المتصفح؟ سيبقى تقدّم القراءة والتفسير المحفوظ. ستحتاج إلى الإنترنت لفتح التطبيق مجددًا.';

  @override
  String get offlineRemoved => 'تمت إزالة ملفات التطبيق المحفوظة دون اتصال';

  @override
  String get offlineUnavailable =>
      'تجهيز القراءة دون اتصال غير متاح في هذا المتصفح. جرّب متصفحًا مدعومًا عبر اتصال HTTPS.';

  @override
  String get offlineError =>
      'تعذّر إكمال تجهيز القراءة دون اتصال. تحقق من الاتصال ومساحة التخزين المتاحة ثم حاول مجددًا.';

  @override
  String get offlineOtherTabs =>
      'أغلق تبويبات Quran Haven الأخرى، ثم طبّق التحديث مجددًا.';

  @override
  String get offlineActivationTimeout =>
      'تعذّر تفعيل التحديث بعد. أعد تحميل هذا التبويب وحاول مجددًا.';

  @override
  String get offlineStorageWarning =>
      'قد يزيل المتصفح الملفات المحفوظة عند انخفاض مساحة التخزين. تحقق من هذه الشاشة قبل الاعتماد على القراءة دون اتصال.';

  @override
  String offlineProgress(String completed, String total) {
    return 'تم حفظ $completed / $total ميغابايت';
  }

  @override
  String get offlineNotReady => 'القراءة دون اتصال غير مجهّزة';

  @override
  String get offlineCancelled =>
      'تم إلغاء التحميل. ستبقى النسخة المجهّزة سابقًا، إن وجدت.';

  @override
  String get localStorageTitle => 'التخزين على جهازك';

  @override
  String get localStorageBody =>
      'تُحفظ العلامات المرجعية وآخر قراءة والخطط والإعدادات والتنزيلات على هذا الجهاز أو في هذا المتصفح فقط. لا توجد حسابات أو نسخ سحابية أو مزامنة بين الأجهزة. قد يؤدي حذف التطبيق أو مسح بياناته أو بيانات الموقع إلى فقدان هذه العناصر المحفوظة.';

  @override
  String get guideStartHere => 'ابدأ من هنا';

  @override
  String get guideChooseLesson => 'اختر درسك التالي';

  @override
  String guideLesson(int number, int total) {
    return 'الدرس $number من $total';
  }

  @override
  String get guideWrittenSteps => 'تابع خطوة بخطوة';

  @override
  String get guidePauseVideo => 'إيقاف الفيديو مؤقتاً';

  @override
  String get guideRestartVideo => 'إعادة الفيديو من البداية';

  @override
  String get guideFullScreen => 'عرض بملء الشاشة';

  @override
  String get guideSeekVideo => 'موضع الفيديو';

  @override
  String get guideVideoLoading => 'جارٍ تجهيز الدرس…';

  @override
  String get guideVideoRetry => 'إعادة محاولة الفيديو';

  @override
  String get guideVideoFinished => 'اكتمل الدرس. يمكنك إعادته متى احتجت.';

  @override
  String get guideVideoHint =>
      'تابع المؤشر المميز والتعليمات المرقمة. لا يبدأ أي فيديو إلا عندما تختار تشغيله.';

  @override
  String get guideNativeFiles =>
      'على أندرويد، اختر مكاناً خاصاً للحفظ من منتقي المستندات. على iOS، استخدم قائمة المشاركة لحفظ الملف أو مشاركته. استخدم منتقي المستندات لاسترجاع نسخة JSON.';

  @override
  String get guideNativeShareImage => 'حفظ صورة الآية أو مشاركتها';

  @override
  String get guideNativeSaveImage => 'حفظ صورة الآية';

  @override
  String get privacyTitle => 'الخصوصية والتواصل';

  @override
  String get privacyLocalSummary =>
      'قرآن هيفن مجاني ولا يتضمن حسابات أو إعلانات. تبقى إشاراتك وملاحظاتك وخططك وموضع القراءة وتفضيلاتك على جهازك أو في متصفحك. قد يؤدي مسح بيانات التطبيق أو المتصفح إلى حذفها. لا يتم تصدير النسخ أو استرجاع الملفات أو المشاركة إلا باختيارك، وأنت تحدد الوجهة.';

  @override
  String get privacyNetworkSummary =>
      'تتصل موارد القراءة والتلاوات عبر الإنترنت بمضيف المشروع ومزودي الصوت والمحتوى. تكشف هذه الطلبات معلومات الشبكة مثل عنوان IP والملفات المطلوبة؛ وقد يحتفظ المزودون بسجلات تقنية. يستخدم الموقع أيضاً أداة Cloudflare لقياس الأداء والاستخدام. لا تُرفع ملاحظاتك أو تقدمك الشخصي تلقائياً.';

  @override
  String get privacyOpen => 'اقرأ سياسة الخصوصية كاملة';

  @override
  String get contactProject => 'تواصل مع المشروع';

  @override
  String get copyContactEmail => 'نسخ بريد التواصل';

  @override
  String get privacyLinkCopied =>
      'تم نسخ العنوان. افتحه في المتصفح أو تطبيق البريد.';

  @override
  String get privacyLinkFailed =>
      'تعذر فتح العنوان أو نسخه. استخدم العنوان المعروض هنا.';

  @override
  String get backupSafetyConfirm => 'حفظت نسخة الأمان في مكان خاص.';

  @override
  String get backupRefreshFailed =>
      'تم استرجاع النسخة. أغلق التطبيق وافتحه مجدداً لعرض البيانات المسترجعة.';

  @override
  String get guideTitle => 'دليل استخدام قرآن هيفن';

  @override
  String get guideOpen => 'افتح دليل الاستخدام';

  @override
  String get guideEntryBody =>
      'عروض مرئية قصيرة وخطوات عملية للقراءة والاستماع وبناء ورد يومي.';

  @override
  String get guideIntroTitle => 'رحلتك، خطوة بخطوة';

  @override
  String get guideIntro =>
      'ابدأ بالمصحف، ثم تعرّف على الأدوات التي تساعدك في القراءة. يشرح هذا الدليل المميزات المتاحة حالياً، مع توضيح ما يختلف بين الموقع وتطبيق الهاتف.';

  @override
  String get guideMediaHint =>
      'تبقى العروض ثابتة حتى تضغط تشغيل. وتجد تحت كل عرض خطوات مكتوبة.';

  @override
  String get guideGoodToKnow => 'من المفيد أن تعرف';

  @override
  String get guidePlayDemo => 'تشغيل العرض';

  @override
  String get guideStopDemo => 'إيقاف العرض';

  @override
  String get guideMediaUnavailable =>
      'العرض غير متاح. اتبع الخطوات المكتوبة أدناه.';

  @override
  String get guideReducedMotion =>
      'تقليل الحركة مفعّل. تبقى المعاينة ثابتة، ويمكنك اختيار التشغيل إذا رغبت.';

  @override
  String guideDemoDescription(String topic) {
    return 'عرض توضيحي للشاشة: $topic';
  }

  @override
  String get guideReadingTitle => 'اقرأ وانتقل إلى موضعك';

  @override
  String get guideReadingStep1 =>
      'من الرئيسية، اختر فتح المصحف للمتابعة من آخر صفحة قرأتها.';

  @override
  String get guideReadingStep2 =>
      'افتح التنقل السريع داخل القارئ. اختر سورة أو جزءاً، أو أدخل رقم صفحة من 1 إلى 604 ثم اضغط الانتقال إلى الصفحة.';

  @override
  String get guideReadingStep3 =>
      'استخدم أسهم الصفحات على الموقع، أو اسحب على جهاز يعمل باللمس للتنقل بين الصفحات. يُحفظ موضع آخر قراءة تلقائياً على هذا الجهاز.';

  @override
  String get guideReadingTip =>
      'يبقى نص القرآن بالعربية عند تغيير لغة الواجهة. لا تحتاج إلى حساب لقراءة المصحف.';

  @override
  String get guideSearchTitle => 'ابحث واحفظ العلامات المرجعية';

  @override
  String get guideSearchStep1 =>
      'اختر البحث في القرآن من الرئيسية، أو افتح البحث داخل القارئ. أدخل كلمة أو عبارة من نص القرآن العربي.';

  @override
  String get guideSearchStep2 =>
      'اختر نتيجة البحث. تُغلق اللوحة ويُفتح المصحف عند الآية المختارة تلقائياً. اضغط مطولاً على آية لفتح خياراتها.';

  @override
  String get guideSearchStep3 =>
      'اختر لون العلامة المرجعية من خيارات الآية. افتح العلامات المرجعية للعودة إلى الآيات المحفوظة.';

  @override
  String get guideSearchTip =>
      'يشمل البحث حالياً النص القرآني العربي، وليس التفاسير أو الترجمات. تُنظّم العلامات ضمن المجموعات الصفراء والحمراء والخضراء.';

  @override
  String get guideLibraryTitle => 'اختر التفسير والترجمة';

  @override
  String get guideLibraryStep1 => 'افتح المكتبة، ثم اختر التفسير أو الترجمات.';

  @override
  String get guideLibraryStep2 =>
      'اضغط تنزيل لمصدر إضافي، أو اختيار لمصدر متاح بالفعل. انتظر رسالة تأكيد الجاهزية.';

  @override
  String get guideLibraryStep3 =>
      'عُد إلى المصحف، واضغط مطولاً على آية، ثم افتح خيار التفسير لقراءة المصدر الذي اخترته.';

  @override
  String get guideLibraryTip =>
      'لغة الواجهة مستقلة عن مصدر القراءة. تعمل المصادر المحفوظة دون اتصال، بشرط إتاحة التخزين في المتصفح.';

  @override
  String get guideAudioTitle => 'استمع إلى التلاوات';

  @override
  String get guideAudioStep1 =>
      'افتح أدوات الصوت في القارئ لاختيار قارئ. قد تختلف قائمة القراء بين أدوات التشغيل.';

  @override
  String get guideAudioStep2 =>
      'في المكتبة، اختر التلاوات، ثم حدّد سورة واضغط تشغيل. يمكنك أيضاً تشغيل آية من خياراتها داخل المصحف.';

  @override
  String get guideAudioStep3 =>
      'استخدم مشغّل الصوت للإيقاف المؤقت أو المتابعة. يعيدك استئناف الاستماع إلى موضع الصوت المحفوظ إن كان متاحاً.';

  @override
  String get guideAudioTip =>
      'يأتي الصوت عبر الإنترنت من مزودي تلاوات خارجيين. نزّل تسجيلات السور الكاملة من التلاوات للاستماع دون اتصال؛ لا يزال صوت الكلمات يتطلب الإنترنت.';

  @override
  String get guideOfflineTitle => 'استعد قبل انقطاع الاتصال';

  @override
  String get guideOfflineStep1 =>
      'على الموقع، افتح الإعدادات واضغط تجهيز القراءة دون اتصال. أبقِ الصفحة مفتوحة حتى تظهر رسالة جاهز للقراءة دون اتصال. المصحف مضمّن في تطبيق الهاتف.';

  @override
  String get guideOfflineStep2 =>
      'نزّل التفاسير والترجمات المطلوبة من المكتبة أثناء الاتصال. تجهيز الموقع دون اتصال لا ينزّل هذه المصادر الإضافية أو الصوت.';

  @override
  String get guideOfflineStep3 =>
      'في تطبيق الهاتف، اختر سورة من المكتبة ← التلاوات، ثم اضغط تنزيل دون اتصال. جرّب المحتوى المحفوظ دون إنترنت قبل الاعتماد عليه.';

  @override
  String get guideOfflineTip =>
      'قد يحذف المتصفح الملفات عند نقص المساحة. التصفح الخاص لا يناسب الحفظ الدائم. تجهيز التطبيق والكتب المنزّلة وتسجيلات السور تنزيلات منفصلة.';

  @override
  String get guidePlansTitle => 'نظّم الختمة والحفظ';

  @override
  String get guidePlansStep1 =>
      'افتح الخطط ثم الختمة. أنشئ خطة وحدّد مدة الإتمام وابدأها. سجّل إنجاز الورد اليومي بعد الانتهاء منه فقط.';

  @override
  String get guidePlansStep2 =>
      'افتح الحفظ وأنشئ خطة تحدّد فيها السورة ونطاق الآيات وعدد التكرارات والفاصل بينها.';

  @override
  String get guidePlansStep3 =>
      'شغّل النطاق، وأخفِ النص أو أظهره، وحدّد الآيات المحفوظة أو المطلوبة للمراجعة. تنقّل داخل النطاق بأزرار الآية السابقة والتالية.';

  @override
  String get guidePlansTip =>
      'يُحفظ تقدم الخطط على هذا الجهاز. يحتاج تكرار الصوت إلى مصدر قابل للتشغيل أو تنزيل محفوظ تدعمه أداة التشغيل.';

  @override
  String get guideSettingsTitle => 'اضبط التجربة بما يناسبك';

  @override
  String get guideSettingsStep1 =>
      'من الإعدادات ثم اللغة، اختر العربية أو English أو Español. تتبع الواجهة وهذا الدليل اللغة المختارة.';

  @override
  String get guideSettingsStep2 =>
      'من الإعدادات ثم المظهر، اختر الوضع الفاتح أو الداكن أو إعداد النظام.';

  @override
  String get guideSettingsStep3 =>
      'في تطبيق الهاتف، يمكنك تفعيل تذكير يومي وتحديد وقته والسماح بإشعارات التطبيق.';

  @override
  String get guideSettingsTip =>
      'تتوفر إشعارات التذكير اليومي على الهواتف المدعومة، وليس الموقع. ويمكنك تعطيلها مجدداً من الإعدادات.';

  @override
  String get guideStorageTitle => 'تعرّف على بياناتك المحلية';

  @override
  String get guideStorageStep1 =>
      'تُحفظ العلامات وموضع القراءة والخطط والإعدادات والتنزيلات على هذا الجهاز أو في هذا المتصفح. لا يوجد حساب أو مزامنة بين الأجهزة.';

  @override
  String get guideStorageStep2 =>
      'استخدم ملف المتصفح نفسه للاحتفاظ ببيانات الموقع. لكل جهاز أو متصفح أو ملف مستخدم بيانات مستقلة.';

  @override
  String get guideStorageTip =>
      'قد يمحو مسح بيانات التطبيق أو الموقع أو فقدان الجهاز العناصر المحفوظة. استخدم النسخة الاحتياطية المحلية من الإعدادات لتصدير بياناتك خصوصياً؛ لا تشمل الكتب أو الصوت المنزّلين.';

  @override
  String get playAyah => 'تشغيل الآية';

  @override
  String get playFromAyah => 'التشغيل من هذه الآية';

  @override
  String get copyAyah => 'نسخ الآية';

  @override
  String get saveYellowBookmark => 'حفظ علامة صفراء';

  @override
  String get saveRedBookmark => 'حفظ علامة حمراء';

  @override
  String get saveGreenBookmark => 'حفظ علامة خضراء';

  @override
  String get guideViewLarger => 'عرض بحجم أكبر';

  @override
  String get guideZoomHint =>
      'كبّر بإصبعين أو عجلة التمرير، ثم اسحب لاستكشاف الشاشة. اضغط إعادة ضبط التكبير لرؤية العرض كاملاً من جديد.';

  @override
  String get guideResetZoom => 'إعادة ضبط التكبير';

  @override
  String get guideRotateHint =>
      'أدر الهاتف لعرض أوسع، أو كبّر واسحب لتفحص خطوات العرض.';

  @override
  String get guideZoomIn => 'تكبير';

  @override
  String get guideZoomOut => 'تصغير';

  @override
  String get creatorCreditTitle => 'من تطوير YahyazLab';

  @override
  String get quranBrandLabel => 'شعار Quran Haven: مصحف مفتوح';

  @override
  String get creatorCreditHint => 'موقع المطوّر الخارجي';

  @override
  String get creatorCreditSemantics =>
      'من تطوير YahyazLab. فتح موقع المطوّر الخارجي بعد التأكيد.';

  @override
  String get creatorExternalTitle => 'أنت تغادر Quran Haven';

  @override
  String get creatorExternalBody =>
      'هذا معرض أعمال مطوّر ألعاب، وليس موقعاً لمحتوى القرآن. سيتم فتحه في المتصفح.';

  @override
  String get creatorGuardianReminder =>
      'للأطفال: استأذن أحد الوالدين أو ولي أمرك قبل المتابعة.';

  @override
  String get creatorContinue => 'متابعة إلى الموقع';

  @override
  String get creatorOpenFailed =>
      'تعذّر فتح الموقع الخارجي. يمكنك متابعة استخدام Quran Haven.';
}
