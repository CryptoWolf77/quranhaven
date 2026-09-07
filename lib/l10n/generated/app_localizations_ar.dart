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
  String get accountAndSync => 'الحساب والنسخ الاحتياطي السحابي';

  @override
  String get cloudNotConfigured =>
      'الحسابات السحابية جاهزة داخل التطبيق، وستتوفر عند ربط عنوان الخادم الخاص بالمشروع.';

  @override
  String get cloudInvalidConfiguration =>
      'عنوان الخادم السحابي غير صالح أو غير آمن. الحسابات السحابية غير متاحة في هذا الإصدار، ولا تتأثر قراءة القرآن على الجهاز.';

  @override
  String get accountOptionalBody =>
      'الحساب اختياري. أنشئ حسابًا فقط إذا أردت نسخ تقدّمك احتياطيًا واستعادته بين أجهزتك.';

  @override
  String get cloudRegistrationNotice =>
      'الحساب اختياري. يُخزّن بريدك الإلكتروني واسمك الظاهر وأي تقدّم تختار نسخه احتياطيًا على خادم المشروع. إنشاء الحساب أو حذفه لا يغيّر قراءة القرآن أو تقدّمك على هذا الجهاز. التحقق من البريد الإلكتروني واستعادة كلمة المرور غير متاحين بعد، لذا احفظ كلمة مرورك في مكان آمن. النسخ السحابية ليست مشفّرة من طرف إلى طرف، ويمكن لمشغّل الخادم الوصول إليها.';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get deleteCloudAccount => 'حذف الحساب السحابي';

  @override
  String get deleteCloudAccountWarning =>
      'هل تريد حذف حسابك ونسخة تقدّمك الاحتياطية من الخادم؟ لا يمكن التراجع عن ذلك. ستبقى مصادر القرآن المحمّلة وتقدّمك على هذا الجهاز. وسيتم تسجيل خروجك أيضًا.';

  @override
  String get cloudAccountDeleted =>
      'تم حذف حسابك السحابي ونسخته الاحتياطية. تبقى بيانات القرآن المحلية على هذا الجهاز.';

  @override
  String get displayName => 'الاسم الظاهر';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get previousAyah => 'الآية السابقة';

  @override
  String get nextAyah => 'الآية التالية';

  @override
  String get removeRevisionMarker => 'إلغاء التحديد للمراجعة';

  @override
  String get passwordRules => 'استخدم 8 أحرف على الأقل.';

  @override
  String get displayNameRequired => 'أدخل حرفين على الأقل.';

  @override
  String get validEmailRequired => 'أدخل بريدًا إلكترونيًا صحيحًا.';

  @override
  String get passwordTooShort =>
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.';

  @override
  String get signedInSuccessfully => 'تم تسجيل دخولك.';

  @override
  String get backupNow => 'نسخ احتياطي الآن';

  @override
  String get backupComplete => 'تم نسخ تقدّمك القرآني احتياطيًا.';

  @override
  String get restoreBackup => 'استعادة النسخة';

  @override
  String get restoreBackupWarning =>
      'سيستبدل هذا آخر صفحة قرأتها وتقدّم الختمة والحفظ واللغة والمظهر على هذا الجهاز بالنسخة السحابية. ستبقى الإعدادات أو بيانات التقدّم غير الموجودة في النسخة القديمة دون تغيير.';

  @override
  String get restore => 'استعادة';

  @override
  String get restoreComplete => 'تمت استعادة تقدّمك من السحابة.';

  @override
  String get noCloudBackup => 'لا توجد نسخة احتياطية سحابية لهذا الحساب بعد.';

  @override
  String get cloudDataInvalid => 'تعذّرت قراءة النسخة السحابية بأمان.';

  @override
  String lastSynced(String date) {
    return 'آخر نسخ احتياطي أو استعادة: $date';
  }

  @override
  String get accountPrivacyNote =>
      'لا يُنسخ تقدّمك احتياطيًا إلا عند اختيار «نسخ احتياطي الآن». قراءة القرآن لا تتطلب حسابًا.';

  @override
  String get invalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get emailAlreadyUsed => 'يوجد حساب يستخدم هذا البريد الإلكتروني.';

  @override
  String get accountValidationFailed => 'تحقق من بيانات الحساب وحاول مرة أخرى.';

  @override
  String get sessionExpired => 'انتهت جلستك. يرجى تسجيل الدخول من جديد.';

  @override
  String get cloudRateLimited =>
      'طلبات سحابية كثيرة. انتظر قليلًا ثم حاول مجددًا. لم تتغيّر بيانات القرآن المحلية.';

  @override
  String get cloudServerError => 'حدثت مشكلة في الخدمة السحابية. حاول لاحقًا.';

  @override
  String get cloudUnavailable =>
      'تعذّر الوصول إلى الخدمة السحابية. بيانات القرآن المحلية ما زالت آمنة.';

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
      'هل تريد إزالة ملفات التطبيق وصفحات القرآن المحفوظة فقط من هذا المتصفح؟ سيبقى تقدّم القراءة وحسابك والتفسير المحفوظ. ستحتاج إلى الإنترنت لفتح التطبيق مجددًا.';

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
}
