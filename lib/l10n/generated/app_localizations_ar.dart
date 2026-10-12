// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

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
      'على الويب، يمكنك حفظ التفسير والترجمات المحددة في هذا المتصفح (حتى 160 MiB)، وقد يزيلها المتصفح عند انخفاض مساحة التخزين. الصوت يتطلب الإنترنت. جهّز التطبيق وصفحات القرآن بشكل منفصل من الإعدادات.';

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
      'العرض المتحرك معطّل لأن تقليل الحركة مفعّل على جهازك.';

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
      'اسحب للتنقل بين الصفحات. يُحفظ موضع آخر قراءة تلقائياً على هذا الجهاز.';

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
      'اختر نتيجة البحث، ثم اضغط إغلاق أعلى اللوحة للعودة إلى المصحف عند الآية المختارة. اضغط مطولاً على آية لفتح خياراتها.';

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
      'تحتاج التلاوات عبر الإنترنت إلى اتصال، وقد تأتي من مزودي تلاوات خارجيين. تنزيل الصوت للاستخدام دون اتصال غير متاح في المتصفح.';

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
      'قد يحذف المتصفح الملفات المحفوظة عند نقص المساحة. التصفح الخاص لا يناسب الحفظ الدائم. يعمل تنزيل الصوت دون اتصال في تطبيق الهاتف، وليس الموقع.';

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
      'قد تفقد العناصر المحفوظة عند حذف التطبيق أو مسح بيانات التطبيق أو الموقع أو فقدان الجهاز. لا تتوفر حالياً أداة لتصدير البيانات المحلية واستيرادها.';

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
}
