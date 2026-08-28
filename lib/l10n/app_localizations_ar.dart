// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class LAr extends L {
  LAr([String locale = 'ar']) : super(locale);

  @override
  String get appTagline => 'استعد مساحة قرصك';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionShow => 'إظهار';

  @override
  String get actionClear => 'مسح';

  @override
  String get actionAll => 'الكل';

  @override
  String get actionAllMatching => 'كل المطابق';

  @override
  String get actionNone => 'لا شيء';

  @override
  String get actionBack => 'رجوع';

  @override
  String get actionNext => 'التالي';

  @override
  String get actionDone => 'تم';

  @override
  String get actionSkip => 'تخطٍ';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionAdd => 'إضافة';

  @override
  String get actionEdit => 'تحرير';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionNotNow => 'ليس الآن';

  @override
  String get alreadyRunningTitle => '‏Kruftle مفتوح بالفعل';

  @override
  String get alreadyRunningBody =>
      'توجد نافذة أخرى من Kruftle قيد التشغيل. تنظيف نافذتين في الوقت نفسه قد يترك مجلد بناء محذوفًا جزئيًا، لذلك لن تُفتح هذه النافذة.';

  @override
  String get titleBarGlobalCaches => 'ذاكرات SDK العامة';

  @override
  String get titleBarSettings => 'الإعدادات';

  @override
  String get titleBarDiskUsage => 'استخدام القرص';

  @override
  String get titleBarSchedule => 'عمليات التنظيف المجدولة';

  @override
  String get titleBarProfiles => 'ملفات التنظيف';

  @override
  String get titleBarChangelog => 'ما الجديد';

  @override
  String get titleBarAbout => 'عن Kruftle';

  @override
  String get railFolder => 'المجلد';

  @override
  String get railScan => 'الفحص';

  @override
  String get railReview => 'المراجعة';

  @override
  String get railClean => 'التنظيف';

  @override
  String get railReport => 'التقرير';

  @override
  String get sourceHeading => 'أي مجلد يفحصه Kruftle؟';

  @override
  String get sourceSubheading =>
      'يُفحص كل ما بداخله. ولا يُمسّ شيء حتى تأذن أنت.';

  @override
  String get sourceChooseFolder => 'اختر مجلدًا';

  @override
  String get sourceChooseFolderHelp =>
      'جذر شفرتك البرمجية، أو أي مجلد يحوي مشاريع';

  @override
  String get sourceConfirmButton => 'افحص هذا المجلد';

  @override
  String get sourceRecent => 'الأحدث';

  @override
  String get sourceForget => 'إزالة من الأحدث';

  @override
  String get sourceShallowTitle => 'أتريد فحص هذا المسار على أي حال؟';

  @override
  String get sourceShallowReason =>
      'يقع قريبًا من جذر محرّكه. يرفض Kruftle ذلك افتراضيًا لأن مسارًا بهذا القِصَر عادةً ما يكون زلّة — لكنّه على محرّك شبكة متصل أو وحدة تخزين مُحمّلة هو بالضبط موضع قاعدة الشفرة. القرار لك.';

  @override
  String get sourceShallowReadOnly =>
      'الفحص يقرأ فقط. لا يحذف شيئًا ولا ينقله ولا يغيّره.';

  @override
  String get sourceShallowChoice =>
      'ستظلّ تختار بعده ما يُنظّف مشروعًا مشروعًا، وتؤكّد مرّة أخرى قبل إزالة أي شيء.';

  @override
  String get sourceShallowStillRefused =>
      'تبقى أدلّة النظام والمجلد الشخصي مرفوضة مهما اخترت هنا، ولا يُحفظ هذا الجواب.';

  @override
  String get sourceShallowAccept => 'افحصه على أي حال';

  @override
  String get scanningLooking => 'جارٍ البحث عن المشاريع';

  @override
  String get scanningMeasuring => 'جارٍ قياس ما تحتويه';

  @override
  String get scanningProjectsFound => 'مشروعًا وُجد';

  @override
  String get scanningDirectoriesWalked => 'مجلدًا جرى تصفحه';

  @override
  String get scanningMeasured => 'تم قياسه';

  @override
  String get scanningNothingYet => 'لم يُعثر على شيء بعد.';

  @override
  String get scanningStop => 'إيقاف الفحص';

  @override
  String get reviewScanAgain => 'افحص مجددًا';

  @override
  String get reviewChangeFolder => 'تغيير المجلد';

  @override
  String reviewProjectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مشروع',
      many: '$count مشروعًا',
      few: '$count مشاريع',
      two: 'مشروعان',
      one: 'مشروع واحد',
      zero: 'لا مشاريع',
    );
    return '$_temp0';
  }

  @override
  String get reviewFilterHint => 'تصفية بالاسم أو المسار أو التقنية   ( / )';

  @override
  String get reviewSortedBySize => 'مرتّب حسب الحجم';

  @override
  String get reviewSortedByPath => 'مرتّب حسب المسار';

  @override
  String get reviewNoProjects =>
      'لا توجد مشاريع ذات مخرجات بناء داخل هذا المجلد.';

  @override
  String reviewNoMatches(String query) {
    return 'لا شيء يطابق «$query».';
  }

  @override
  String reviewInSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'في $count مشروع محدد',
      many: 'في $count مشروعًا محددًا',
      few: 'في $count مشاريع محددة',
      two: 'في مشروعين محددين',
      one: 'في مشروع واحد محدد',
    );
    return '$_temp0';
  }

  @override
  String get reviewMeasuredByDryRun => 'مقيس بالتشغيل التجريبي';

  @override
  String reviewStillMeasuring(int percent) {
    return 'ما زال القياس جاريًا — $percent٪';
  }

  @override
  String reviewFoundInTotal(String size, int count) {
    return 'وُجد $size إجمالًا عبر $count مشروعًا.';
  }

  @override
  String reviewPlanSummary(int steps, int projects) {
    return '$steps خطوة عبر $projects مشروعًا.';
  }

  @override
  String get reviewAlsoDelete => 'احذف أيضًا مباشرةً';

  @override
  String get reviewAlsoDeleteHelp =>
      'يفضّل Kruftle أمر التنظيف الخاص بكل أداة. تُزال هذه الفئات بحذف المجلد، لذا فهي معطّلة ما لم تطلب غير ذلك.';

  @override
  String get reviewRiskBuildOutput => 'مخرجات البناء عند غياب حزمة التطوير';

  @override
  String get reviewRiskBuildOutputHelp =>
      'للمشاريع التي لم تُثبَّت أدواتها، يُحذف مجلد المخرجات المعروف بدلًا من ذلك. وإعادة البناء تستعيده.';

  @override
  String get reviewRiskDependencies => 'الاعتماديات المنزّلة';

  @override
  String get reviewRiskDependenciesHelp =>
      'node_modules و‏.venv و‏deps. تُستعاد من ملف القفل، لكن ذلك يكلّف تنزيلًا.';

  @override
  String get reviewRiskCache => 'ذاكرات الأدوات';

  @override
  String get reviewRiskCacheHelp =>
      '.gradle و‏.turbo و‏.mypy_cache وما شابه. كلفتها الوحيدة بناء تالٍ أبطأ.';

  @override
  String get reviewMissingToolchains =>
      'بعض المشاريع المحددة لا توجد بها حزمة تطوير مثبّتة. وبدون الخيار الأول أعلاه ستُتخطّى.';

  @override
  String reviewGitTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مجلد مخرجات يتتبعها',
      two: 'مجلدا مخرجات يتتبعهما',
      one: 'مجلد مخرجات واحد يتتبعه',
    );
    return '$_temp0 git وسيُترك دون مساس. حذف محتوى مودَع ليس شيئًا تستطيع إعادة البناء التراجع عنه.';
  }

  @override
  String get reviewDryRun => 'تشغيل تجريبي';

  @override
  String get reviewRemeasure => 'إعادة القياس';

  @override
  String get reviewCleanNow => 'نظّف الآن';

  @override
  String get reviewDryRunNote =>
      'التشغيل التجريبي لا يغيّر شيئًا. يمكنك تخطّيه.';

  @override
  String get reviewLargestDirectories => 'أين تذهب المساحة';

  @override
  String get reviewLargestDirectoriesHelp =>
      'أكبر مجلدات المخرجات داخل هذا المجلد. مرّر المؤشر فوق مربّع لترى مساره.';

  @override
  String get confirmDeleteTitle => 'أتريد حذف هذه المجلدات؟';

  @override
  String get confirmDeleteIntro =>
      'إلى جانب تشغيل أمر التنظيف الخاص بكل أداة، سيحذف Kruftle:';

  @override
  String get confirmCategoryBuildOutput =>
      'مجلدات مخرجات البناء حيث تغيب حزمة التطوير';

  @override
  String get confirmCategoryDependencies => 'مجلدات الاعتماديات المنزّلة';

  @override
  String get confirmCategoryCache => 'مجلدات ذاكرات الأدوات';

  @override
  String confirmDeleteScope(int count, String folder) {
    return 'عبر $count مشروعًا محددًا داخل $folder. كل ما هنا قابل لإعادة التوليد، وكل ما يتتبعه git يُتخطّى.';
  }

  @override
  String get confirmDeleteAccept => 'احذف ونظّف';

  @override
  String get runningHeading => 'جارٍ التنظيف';

  @override
  String runningProgress(int done, int total) {
    return '$done من $total خطوة';
  }

  @override
  String get runningStop => 'إيقاف';

  @override
  String get reportStopped => 'أُوقف';

  @override
  String get reportDone => 'انتهى';

  @override
  String reportRanFor(String duration, int projects) {
    return 'استغرق $duration عبر $projects مشروعًا.';
  }

  @override
  String get reportReclaimed => 'استُعيدت';

  @override
  String get reportStepsCompleted => 'خطوة اكتملت';

  @override
  String get reportFailed => 'أخفقت';

  @override
  String get reportNothingToDo => 'لا شيء لفعله';

  @override
  String get reportRefused => 'مرفوضة';

  @override
  String reportUnderEstimate(String estimate) {
    return 'قدّر التشغيل التجريبي $estimate. أوامر التنظيف تقرر بنفسها ما تحذفه — بعضها يُبقي ذاكرات يستفيد منها البناء التالي، وهو غالبًا ما تريده.';
  }

  @override
  String reportRefusedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'رُفضت $count أهداف',
      two: 'رُفض هدفان',
      one: 'رُفض هدف واحد',
    );
    return '$_temp0 بفحص أمان وتُرك دون مساس.';
  }

  @override
  String get reportWhatWentWrong => 'ما الذي أخفق';

  @override
  String get reportNoDetail => 'لم تُبلَّغ أي تفاصيل.';

  @override
  String get reportScanAgain => 'افحص مجددًا';

  @override
  String get reportAnotherFolder => 'مجلد آخر';

  @override
  String get reportExportLog => 'تصدير السجل';

  @override
  String reportLogExported(String name) {
    return 'صُدِّر السجل إلى $name';
  }

  @override
  String get reportDiskBefore => 'قبل';

  @override
  String get reportDiskAfter => 'بعد';

  @override
  String reportDiskHeading(String volume, String free, String total) {
    return '$volume — $free متاحة من $total';
  }

  @override
  String get reportDiskUnavailable => 'هذا القرص لا يُبلّغ عن مساحته المتاحة.';

  @override
  String toolAvailable(String binary, String stack) {
    return '‏$binary مثبّت — ستُنظَّف مشاريع $stack بأمرها الخاص.';
  }

  @override
  String toolMissing(String binary) {
    return '‏$binary ليس في PATH. لا يستطيع Kruftle تنظيف هذا إلا بحذف مجلد البناء، وهو ما يتطلب إذنك الصريح.';
  }

  @override
  String toolNotApplicable(String stack) {
    return '‏$stack ليس له أمر تنظيف رسمي.';
  }

  @override
  String get cachesTitle => 'الذاكرات العامة';

  @override
  String get cachesRemeasure => 'إعادة القياس';

  @override
  String get cachesSortTooltip => 'الترتيب حسب الحجم';

  @override
  String get cachesSortLargest => 'الأكبر أولاً';

  @override
  String get cachesSortSmallest => 'الأصغر أولاً';

  @override
  String get cachesIntro =>
      'تتشارك كل مشاريع هذا الجهاز هذه الذاكرات. إفراغ إحداها يحرّر مساحة الآن ويكلّف تنزيلًا لاحقًا — ولا يُفقد أي عمل.';

  @override
  String cachesFreed(String size, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ذاكرة',
      two: 'ذاكرتين',
      one: 'ذاكرة واحدة',
    );
    return 'حُرّر $size من $_temp0.';
  }

  @override
  String get cachesNoneFound => 'لم تُوجد ذاكرات عامة في مجلد المنزل.';

  @override
  String get cachesSelected => 'محددة';

  @override
  String get cachesEmptySelected => 'أفرغ المحدد';

  @override
  String get cachesEmptying => 'جارٍ الإفراغ…';

  @override
  String get cachesConfirmTitle => 'أتريد إفراغ هذه الذاكرات؟';

  @override
  String cachesConfirmBody(String size) {
    return 'تتشاركها كل مشاريع هذا الجهاز، لا المشروع الذي فحصته آخر مرة فحسب. إفراغها يحرّر $size الآن ويكلّف تنزيلًا في المرة القادمة التي يحتاجها فيها أي مشروع.';
  }

  @override
  String get cachesConfirmAccept => 'أفرغها';

  @override
  String get cachesUsesCommand =>
      'تُفرَّغ بأمر الأداة نفسها بدلًا من حذف الملفات.';

  @override
  String get cachesUsesDelete =>
      'لا يوجد أمر رسمي لهذه الذاكرة، لذا يُزال المجلد.';

  @override
  String get cachesDeleteTag => 'حذف';

  @override
  String updateAvailable(String version, String size) {
    return '‏Kruftle $version متاح ($size).';
  }

  @override
  String updateDownloading(String version, int percent) {
    return 'جارٍ تنزيل $version… $percent٪';
  }

  @override
  String updateReady(String version) {
    return '‏Kruftle $version جاهز. أعد التشغيل للإنهاء.';
  }

  @override
  String get updateFailed => 'أخفق التحديث.';

  @override
  String get updateAction => 'تحديث';

  @override
  String get updateRestart => 'إعادة التشغيل الآن';

  @override
  String get updateChecking => 'جارٍ البحث عن التحديثات…';

  @override
  String get updateUpToDate => '‏Kruftle محدَّث.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSectionAppearance => 'المظهر';

  @override
  String get settingsTheme => 'السمة';

  @override
  String get settingsThemeSystem => 'مطابقة النظام';

  @override
  String get settingsThemeLight => 'فاتحة';

  @override
  String get settingsThemeDark => 'داكنة';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageSystem => 'مطابقة النظام';

  @override
  String get settingsReduceMotion => 'تقليل الحركة';

  @override
  String get settingsReduceMotionHelp =>
      'استبدل الرسوم المتحركة الماسحة والنابضة بشريط تقدم بسيط. يُحترم هذا تلقائيًا أيضًا حين يطلب النظام تقليل الحركة.';

  @override
  String get settingsSectionScanning => 'الفحص';

  @override
  String get settingsMaxDepth => 'أقصى عمق';

  @override
  String get settingsMaxDepthHelp =>
      'إلى أي عمق يُبحث تحت المجلد المختار. العمق الأكبر يجد مشاريع متداخلة أكثر ويستغرق وقتًا أطول.';

  @override
  String settingsLevels(int count) {
    return '$count مستوى';
  }

  @override
  String get settingsHiddenDirectories => 'تضمين المجلدات المخفية';

  @override
  String get settingsHiddenDirectoriesHelp =>
      'المجلدات التي تبدأ بنقطة. غالبًا حالة المحرر وذاكرات الأدوات لا مشاريع.';

  @override
  String get settingsSectionCleaning => 'التنظيف';

  @override
  String get settingsConcurrency => 'عدد المشاريع في الوقت نفسه';

  @override
  String settingsConcurrencyHelp(int cores) {
    return 'أوامر التنظيف التي تعمل بالتوازي. الأكثر أسرع حتى يصبح القرص هو العائق. يتوفر $cores من الأنوية.';
  }

  @override
  String get settingsTimeout => 'مهلة الخطوة';

  @override
  String get settingsTimeoutHelp =>
      'أمر تنظيف يتجاوز هذه المدة يُنهى ويُسجَّل، كي لا تعطّل أداة بناء عالقة التشغيل كله.';

  @override
  String settingsSeconds(int count) {
    return '$count ثانية';
  }

  @override
  String settingsMinutes(int count) {
    return '$count دقيقة';
  }

  @override
  String get settingsConfirmBeforeDelete => 'التأكيد قبل الحذف';

  @override
  String get settingsConfirmBeforeDeleteHelp =>
      'أظهر حوار ملخّص كلما كان التشغيل سيحذف مجلدات مباشرةً بدلًا من تشغيل أوامر التنظيف فقط.';

  @override
  String get settingsSectionPreselect => 'حدّد فئات الحذف هذه مسبقًا';

  @override
  String get settingsPreselectHelp =>
      'لمجرد التيسير. كل تشغيل يظل يعرضها محددة ويظل يسأل قبل حذف أي شيء.';

  @override
  String get settingsSectionLogging => 'السجلات';

  @override
  String get settingsLogDetail => 'التفصيل';

  @override
  String get settingsLogDebug => 'تصحيح';

  @override
  String get settingsLogInfo => 'معلومات';

  @override
  String get settingsLogWarning => 'تحذير';

  @override
  String get settingsLogError => 'خطأ';

  @override
  String get settingsLogRetention => 'عدد ملفات السجل المحفوظة';

  @override
  String get settingsLogRetentionHelp =>
      'تُزال الملفات الأقدم بمجرد تدوير السجل النشط.';

  @override
  String get settingsNone => 'بلا';

  @override
  String get settingsSectionUpdates => 'التحديثات';

  @override
  String get settingsCheckUpdates => 'التحقق من التحديثات تلقائيًا';

  @override
  String get settingsCheckUpdatesHelp =>
      'يسأل Kruftle خدمة إصدارات GitHub عند التشغيل ويعرض تنزيلًا مُتحقَّقًا منه. ولا يثبّت شيئًا دون أن يسأل.';

  @override
  String get settingsCheckNow => 'ابحث عن التحديثات الآن';

  @override
  String get settingsSectionSizes => 'الأحجام';

  @override
  String get settingsSizeMode => 'كيف تُحتسب الأحجام';

  @override
  String get settingsSizeModeOnDisk => 'المساحة المشغولة فعليًا على القرص';

  @override
  String get settingsSizeModeApparent => 'مجموع أطوال الملفات';

  @override
  String get settingsSizeModeHelp =>
      'قياس القرص يطابق ما يبلّغ عنه نظام التشغيل وما تستعيده فعلًا، بما في ذلك تقريب الكتل وضغط نظام الملفات. يتطلب استدعاءً أصليًا غير متاح على Windows، حيث يُرجع إلى أطوال الملفات.';

  @override
  String get settingsSectionAbout => 'عن التطبيق';

  @override
  String get settingsShowTour => 'أعرض جولة المزايا مجددًا';

  @override
  String get settingsChangelog => 'ما الجديد في هذه النسخة';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsTermsOfService => 'شروط الخدمة';

  @override
  String settingsVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get settingsLicence =>
      'برمجية حرة بموجب رخصة جنو العمومية العامة الإصدار 3.0 أو ما بعده.';

  @override
  String get settingsMadeWith => 'صُنع بـ ❤️ في كولكاتا، الهند';

  @override
  String get settingsSourceCode => 'الشفرة المصدرية';

  @override
  String get settingsWebsite => 'موقع Kruftle';

  @override
  String get tourWelcomeTitle => 'مرحبًا بك في Kruftle';

  @override
  String get tourWelcomeBody =>
      'تتراكم مخلفات البناء بهدوء. يعثر Kruftle على كل مشروع في قرصك، ويستنتج ما الذي بناه، ثم يطلب من تلك الأداة أن تنظّف وراءها.';

  @override
  String get tourWelcomeStart => 'أرِني الجولة';

  @override
  String get tourWelcomeSkip => 'تخطّي الجولة';

  @override
  String get tourScanTitle => 'وجّهه إلى مجلد';

  @override
  String get tourScanBody =>
      'اختر جذر شفرتك. يتصفح Kruftle كل ما تحته، ويتعرف على أكثر من أربعين لغة وأداة بناء من الملفات التي تخلّفها — بما في ذلك المشاريع المتداخلة داخل مشاريع أخرى.';

  @override
  String get tourReviewTitle => 'شاهد ما وجده قبل أن يحدث أي شيء';

  @override
  String get tourReviewBody =>
      'كل مشروع، وكل مجلد مخرجات، وكم يكلّفك كل منها — مقيسًا لا مُخمَّنًا. أشّر على ما تريد تنظيفه. ولا يُمسّ شيء حتى تأذن أنت.';

  @override
  String get tourSafetyTitle => 'الأمان ليس اختياريًا';

  @override
  String get tourSafetyBody =>
      'يفضّل Kruftle أمر التنظيف الخاص بكل أداة على حذف الملفات. والحذف المباشر مقيّد بقائمة أسماء مجلدات مسموح بها، ولا يتبع رابطًا رمزيًا أبدًا، ويرفض مغادرة المجلد الذي اخترته، ويسأل دائمًا أولًا. وكل ما يتتبعه git يُترك وشأنه.';

  @override
  String get tourCachesTitle => 'وذاكرات مجلد المنزل أيضًا';

  @override
  String get tourCachesBody =>
      'سجل Cargo، وذاكرات Gradle، وذاكرتا npm وpub — تتشاركها كل المشاريع وغالبًا ما تكون أكبر مكسب على القرص. لها شاشتها الخاصة وتأكيدها الخاص.';

  @override
  String get tourScheduleTitle => 'اضبطه وانسه';

  @override
  String get tourScheduleBody =>
      'اجعل Kruftle ينظّف يوميًا أو أسبوعيًا أو شهريًا. يمكنه تذكيرك أثناء فتحه، أو التسجيل في مُجدوِل نظام التشغيل لديك وتنفيذ العملية وKruftle مغلق.';

  @override
  String get tourFinishTitle => 'هذا هو التطبيق كله';

  @override
  String get tourFinishBody =>
      'كل شيء يعمل على جهازك. لا يُرفع أي شيء، ولا حساب لإنشائه.';

  @override
  String get tourFinishAction => 'لنبدأ';

  @override
  String get scheduleTitle => 'عمليات التنظيف المجدولة';

  @override
  String get scheduleEnable => 'ذكّرني بالتنظيف';

  @override
  String get scheduleEnableHelp =>
      'يتحقق Kruftle أثناء تشغيله مما إذا كان موعد التنظيف قد حان، ويخبرك عند البدء إذا فات أحدها. فعّل التشغيل في الخلفية أدناه ليحدث ذلك دون فتح Kruftle.';

  @override
  String get scheduleBackground => 'التشغيل حتى عندما يكون Kruftle مغلقًا';

  @override
  String get scheduleBackgroundHelp =>
      'يسجّل مهمة في مُجدوِل نظام التشغيل نفسه، فتُنفَّذ عملية التنظيف في الوقت المحدد سواء كان Kruftle مفتوحًا أم لا. يشغّل أمر التنظيف الخاص بكل سلسلة أدوات، ولا يحذف سوى الفئات التي اخترتها مسبقًا في الإعدادات.';

  @override
  String get scheduleBackgroundActive => 'مُسجَّل لدى مُجدوِل النظام.';

  @override
  String get scheduleBackgroundFailed =>
      'رفض نظامك تسجيل المهمة الخلفية. ما زال التذكير يعمل أثناء فتح Kruftle.';

  @override
  String get scheduleFrequency => 'كم مرة';

  @override
  String get scheduleDaily => 'يوميًا';

  @override
  String get scheduleWeekly => 'أسبوعيًا';

  @override
  String get scheduleMonthly => 'شهريًا';

  @override
  String get scheduleTimeOfDay => 'في';

  @override
  String get scheduleDayOfWeek => 'يوم';

  @override
  String get scheduleDayOfMonth => 'في اليوم';

  @override
  String get scheduleFolder => 'المجلد المراد فحصه';

  @override
  String get scheduleChooseFolder => 'اختر مجلدًا…';

  @override
  String scheduleNextRun(String when) {
    return 'التذكير التالي $when.';
  }

  @override
  String get scheduleNeverRun => 'لم يجرِ أي تنظيف بعد.';

  @override
  String scheduleLastRun(String when) {
    return 'آخر تنظيف $when.';
  }

  @override
  String get scheduleDueTitle => 'حان موعد التنظيف';

  @override
  String scheduleDueBody(int days, String folder) {
    return 'مضى $days يومًا على آخر تنظيف داخل $folder.';
  }

  @override
  String get scheduleDueAction => 'افحص الآن';

  @override
  String get scheduleDueDismiss => 'لاحقًا';

  @override
  String get scheduleNotifyOnFinish => 'أعلِمني عند انتهاء التنظيف';

  @override
  String get scheduleNotificationDueTitle => '‏Kruftle — حان موعد التنظيف';

  @override
  String scheduleNotificationDueBody(String folder) {
    return 'حان وقت إزالة مخلفات البناء من $folder.';
  }

  @override
  String scheduleNotificationDoneTitle(String size) {
    return '‏Kruftle — استُعيد $size';
  }

  @override
  String scheduleNotificationDoneBody(int projects, String duration) {
    return 'نُظِّف $projects مشروعًا في $duration.';
  }

  @override
  String get profilesTitle => 'ملفات التنظيف';

  @override
  String get profilesIntro =>
      'يعلّم الملفُّ Kruftle نوعَ مشروع لا يعرفه بعد: أي ملف يميّزه، وأي أمر ينظّفه، وأي مجلدات يجوز له إزالتها. تقف الملفات جنبًا إلى جنب مع التقنيات المدمجة وتخضع لقواعد الأمان نفسها تمامًا.';

  @override
  String get profilesNone => 'لا ملفات مخصصة بعد.';

  @override
  String get profilesNew => 'ملف جديد';

  @override
  String get profilesImport => 'استيراد…';

  @override
  String get profilesExport => 'تصدير…';

  @override
  String get profilesName => 'الاسم';

  @override
  String get profilesNameHint => 'Unreal Engine';

  @override
  String get profilesMarkers => 'الملفات المميِّزة';

  @override
  String get profilesMarkersHint => '*.uproject';

  @override
  String get profilesMarkersHelp =>
      'أي مجلد يحوي واحدًا منها يُعامل كمشروع من هذا النوع. واحد في كل سطر. النقطة والنجمة في البداية تطابق حسب الامتداد.';

  @override
  String get profilesCommand => 'أمر التنظيف';

  @override
  String get profilesCommandHint => 'make clean';

  @override
  String get profilesCommandHelp =>
      'يُشغَّل ومجلد المشروع هو مجلد العمل. اتركه فارغًا لحذف المجلدات أدناه فقط.';

  @override
  String get profilesArtifacts => 'المجلدات التي يجوز إزالتها';

  @override
  String get profilesArtifactsHint => 'Binaries\nIntermediate';

  @override
  String get profilesArtifactsHelp =>
      'واحد في كل سطر، نسبةً إلى جذر المشروع. هذه قائمة سماح: لا يُحذف شيء خارجها أبدًا، ويظل الحذف بحاجة إلى تأكيدك في كل تشغيل.';

  @override
  String get profilesExcludes => 'لا تفحص هذه المسارات أبدًا';

  @override
  String get profilesExcludesHint => '**/vendor/**';

  @override
  String get profilesExcludesHelp =>
      'أنماط glob. تُتخطّى المجلدات المطابقة كليًا، لكل ملف ولكل تقنية مدمجة.';

  @override
  String get profilesEnabled => 'مفعّل';

  @override
  String profilesDeleteConfirm(String name) {
    return 'أتريد حذف الملف «$name»؟';
  }

  @override
  String get profilesErrorName => 'أعطِ الملف اسمًا.';

  @override
  String get profilesErrorMarkers =>
      'يحتاج الملف إلى ملف مميِّز واحد على الأقل، وإلا لطابق كل مجلد.';

  @override
  String get profilesErrorNothingToDo =>
      'أعطِ الملف أمر تنظيف، أو مجلدات لإزالتها، أو كليهما.';

  @override
  String profilesErrorAbsolutePath(String path) {
    return 'يجب أن تكون المجلدات نسبةً إلى جذر المشروع: «$path» ليست كذلك.';
  }

  @override
  String profilesErrorEscapes(String path) {
    return '«$path» يشير إلى خارج المشروع. وهذا غير مسموح أبدًا.';
  }

  @override
  String profilesErrorDuplicate(String name) {
    return 'يوجد ملف باسم «$name» بالفعل.';
  }

  @override
  String get profilesImportFailed => 'هذا الملف ليس تصديرَ ملفات من Kruftle.';

  @override
  String profilesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'استُورد $count ملفًا.',
      two: 'استُورد ملفان.',
      one: 'استُورد ملف واحد.',
    );
    return '$_temp0';
  }

  @override
  String get diskTitle => 'استخدام القرص';

  @override
  String get diskVolume => 'القرص';

  @override
  String get diskUsed => 'مستخدمة';

  @override
  String get diskFree => 'متاحة';

  @override
  String get diskReclaimable => 'قابلة للاستعادة';

  @override
  String diskOfTotal(String used, String total) {
    return '$used مستخدمة من $total';
  }

  @override
  String diskFreedThisRun(String size) {
    return 'حُرّر $size';
  }

  @override
  String get diskTreemapEmpty => 'لم يُقس شيء بعد.';

  @override
  String get changelogTitle => 'ما الجديد';

  @override
  String changelogVersionHeading(String version) {
    return 'الإصدار $version';
  }

  @override
  String get changelogUnavailable => 'تعذّرت قراءة سجل التغييرات.';

  @override
  String get changelogAdded => 'أُضيف';

  @override
  String get changelogChanged => 'تغيّر';

  @override
  String get changelogFixed => 'أُصلح';

  @override
  String changelogWhatsNewBanner(String version) {
    return 'حُدِّث Kruftle إلى $version.';
  }

  @override
  String get changelogWhatsNewAction => 'اطّلع على ما تغيّر';

  @override
  String get legalPrivacyTitle => 'سياسة الخصوصية';

  @override
  String get legalTermsTitle => 'شروط الخدمة';

  @override
  String get legalUnavailable => 'تعذّر تحميل هذا المستند.';

  @override
  String get legalOpenInBrowser => 'فتح في المتصفح';

  @override
  String get consentTitle => 'الشروط والخصوصية';

  @override
  String get consentBody =>
      'يشغّل Kruftle أمر التنظيف الخاص بكل سلسلة أدوات، وهذا يحذف مخرجات البناء من هذا الجهاز. اقرأ شروط الخدمة وسياسة الخصوصية قبل البدء — المتابعة تعني قبولك لكليهما.';

  @override
  String get consentAccept => 'أوافق وأتابع';

  @override
  String get consentDecline => 'أرفض وأخرج';
}
