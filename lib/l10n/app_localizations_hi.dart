// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class LHi extends L {
  LHi([String locale = 'hi']) : super(locale);

  @override
  String get appTagline => 'अपनी डिस्क वापस पाइए';

  @override
  String get actionCancel => 'रद्द करें';

  @override
  String get actionClose => 'बंद करें';

  @override
  String get actionShow => 'दिखाएँ';

  @override
  String get actionClear => 'खाली करें';

  @override
  String get actionAll => 'सभी';

  @override
  String get actionAllMatching => 'सभी मिलते-जुलते';

  @override
  String get actionNone => 'कोई नहीं';

  @override
  String get actionBack => 'पीछे';

  @override
  String get actionNext => 'आगे';

  @override
  String get actionDone => 'हो गया';

  @override
  String get actionSkip => 'छोड़ें';

  @override
  String get actionSave => 'सहेजें';

  @override
  String get actionDelete => 'हटाएँ';

  @override
  String get actionAdd => 'जोड़ें';

  @override
  String get actionEdit => 'संपादित करें';

  @override
  String get actionRetry => 'फिर कोशिश करें';

  @override
  String get actionNotNow => 'अभी नहीं';

  @override
  String get titleBarGlobalCaches => 'वैश्विक SDK कैश';

  @override
  String get titleBarSettings => 'सेटिंग्स';

  @override
  String get titleBarDiskUsage => 'डिस्क उपयोग';

  @override
  String get titleBarSchedule => 'निर्धारित सफ़ाई';

  @override
  String get titleBarProfiles => 'सफ़ाई प्रोफ़ाइल';

  @override
  String get titleBarChangelog => 'नया क्या है';

  @override
  String get titleBarAbout => 'Kruftle के बारे में';

  @override
  String get railFolder => 'फ़ोल्डर';

  @override
  String get railScan => 'स्कैन';

  @override
  String get railReview => 'समीक्षा';

  @override
  String get railClean => 'सफ़ाई';

  @override
  String get railReport => 'रिपोर्ट';

  @override
  String get sourceHeading => 'Kruftle किस डायरेक्टरी में देखे?';

  @override
  String get sourceSubheading =>
      'उसके नीचे की हर चीज़ जाँची जाती है। जब तक आप न कहें, कुछ भी नहीं छुआ जाता।';

  @override
  String get sourceChooseFolder => 'एक फ़ोल्डर चुनें';

  @override
  String get sourceChooseFolderHelp =>
      'आपके कोडबेस की जड़, या प्रोजेक्ट रखने वाला कोई भी फ़ोल्डर';

  @override
  String get sourceConfirmButton => 'यह फ़ोल्डर स्कैन करें';

  @override
  String get sourceRecent => 'हाल के';

  @override
  String get sourceForget => 'हाल के से हटाएँ';

  @override
  String get scanningLooking => 'प्रोजेक्ट खोजे जा रहे हैं';

  @override
  String get scanningMeasuring => 'उनका आकार मापा जा रहा है';

  @override
  String get scanningProjectsFound => 'प्रोजेक्ट मिले';

  @override
  String get scanningDirectoriesWalked => 'डायरेक्टरियाँ देखी गईं';

  @override
  String get scanningMeasured => 'मापा गया';

  @override
  String get scanningNothingYet => 'अभी तक कुछ नहीं मिला।';

  @override
  String get scanningStop => 'स्कैन रोकें';

  @override
  String get reviewScanAgain => 'फिर से स्कैन करें';

  @override
  String get reviewChangeFolder => 'फ़ोल्डर बदलें';

  @override
  String reviewProjectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रोजेक्ट',
      one: '1 प्रोजेक्ट',
    );
    return '$_temp0';
  }

  @override
  String get reviewFilterHint => 'नाम, पथ या स्टैक से छाँटें   ( / )';

  @override
  String get reviewSortedBySize => 'आकार के क्रम में';

  @override
  String get reviewSortedByPath => 'पथ के क्रम में';

  @override
  String get reviewNoProjects =>
      'इस फ़ोल्डर में बिल्ड आउटपुट वाला कोई प्रोजेक्ट नहीं है।';

  @override
  String reviewNoMatches(String query) {
    return '“$query” से कुछ नहीं मिलता।';
  }

  @override
  String reviewInSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चुने गए प्रोजेक्ट में',
      one: '1 चुने गए प्रोजेक्ट में',
    );
    return '$_temp0';
  }

  @override
  String get reviewMeasuredByDryRun => 'ड्राई रन से मापा गया';

  @override
  String reviewStillMeasuring(int percent) {
    return 'अभी माप जारी है — $percent%';
  }

  @override
  String reviewFoundInTotal(String size, int count) {
    return '$count प्रोजेक्ट में कुल $size मिला।';
  }

  @override
  String reviewPlanSummary(int steps, int projects) {
    return '$projects प्रोजेक्ट में $steps चरण।';
  }

  @override
  String get reviewAlsoDelete => 'सीधे हटाएँ भी';

  @override
  String get reviewAlsoDeleteHelp =>
      'Kruftle हर टूलचेन की अपनी clean कमांड को प्राथमिकता देता है। ये श्रेणियाँ डायरेक्टरी मिटाकर हटाई जाती हैं, इसलिए जब तक आप न कहें ये बंद रहती हैं।';

  @override
  String get reviewRiskBuildOutput => 'SDK न होने पर बिल्ड आउटपुट';

  @override
  String get reviewRiskBuildOutputHelp =>
      'जिन प्रोजेक्ट का टूलचेन इंस्टॉल नहीं है, उनकी ज्ञात आउटपुट डायरेक्टरी हटा दी जाती है। दोबारा बिल्ड करने पर वह वापस आ जाती है।';

  @override
  String get reviewRiskDependencies => 'डाउनलोड की गई निर्भरताएँ';

  @override
  String get reviewRiskDependenciesHelp =>
      'node_modules, .venv, deps। लॉकफ़ाइल से वापस आ जाती हैं, पर उसमें डाउनलोड लगता है।';

  @override
  String get reviewRiskCache => 'टूल कैश';

  @override
  String get reviewRiskCacheHelp =>
      '.gradle, .turbo, .mypy_cache वग़ैरह। बस अगला बिल्ड धीमा होगा।';

  @override
  String get reviewMissingToolchains =>
      'कुछ चुने गए प्रोजेक्ट में SDK इंस्टॉल नहीं है। ऊपर वाला पहला विकल्प चुने बिना वे छोड़ दिए जाएँगे।';

  @override
  String reviewGitTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आर्टिफ़ैक्ट डायरेक्टरियाँ',
      one: '1 आर्टिफ़ैक्ट डायरेक्टरी',
    );
    return '$_temp0 git में ट्रैक हैं और छुई नहीं जाएँगी। कमिट किया गया कुछ मिटाना दोबारा बिल्ड करके वापस नहीं आता।';
  }

  @override
  String get reviewDryRun => 'ड्राई रन';

  @override
  String get reviewRemeasure => 'फिर से मापें';

  @override
  String get reviewCleanNow => 'अभी साफ़ करें';

  @override
  String get reviewDryRunNote =>
      'ड्राई रन कुछ नहीं बदलता। आप इसे छोड़ सकते हैं।';

  @override
  String get reviewLargestDirectories => 'जगह कहाँ जा रही है';

  @override
  String get reviewLargestDirectoriesHelp =>
      'इस फ़ोल्डर की सबसे बड़ी आर्टिफ़ैक्ट डायरेक्टरियाँ। पथ देखने के लिए किसी ब्लॉक पर कर्सर ले जाएँ।';

  @override
  String get confirmDeleteTitle => 'ये डायरेक्टरियाँ हटाएँ?';

  @override
  String get confirmDeleteIntro =>
      'हर टूलचेन की clean कमांड चलाने के साथ-साथ Kruftle यह भी हटाएगा:';

  @override
  String get confirmCategoryBuildOutput =>
      'उन जगहों की बिल्ड आउटपुट डायरेक्टरियाँ जहाँ SDK नहीं है';

  @override
  String get confirmCategoryDependencies =>
      'डाउनलोड की गई निर्भरता डायरेक्टरियाँ';

  @override
  String get confirmCategoryCache => 'टूल कैश डायरेक्टरियाँ';

  @override
  String confirmDeleteScope(int count, String folder) {
    return '$folder के अंदर चुने गए $count प्रोजेक्ट में। यह सब दोबारा बन सकता है, और git जो ट्रैक करता है वह छोड़ दिया जाता है।';
  }

  @override
  String get confirmDeleteAccept => 'हटाएँ और साफ़ करें';

  @override
  String get runningHeading => 'सफ़ाई जारी है';

  @override
  String runningProgress(int done, int total) {
    return '$total में से $done चरण';
  }

  @override
  String get runningStop => 'रोकें';

  @override
  String get reportStopped => 'रोक दिया गया';

  @override
  String get reportDone => 'पूरा हुआ';

  @override
  String reportRanFor(String duration, int projects) {
    return '$projects प्रोजेक्ट पर $duration तक चला।';
  }

  @override
  String get reportReclaimed => 'वापस मिला';

  @override
  String get reportStepsCompleted => 'चरण पूरे';

  @override
  String get reportFailed => 'विफल';

  @override
  String get reportNothingToDo => 'कुछ करना नहीं था';

  @override
  String get reportRefused => 'अस्वीकृत';

  @override
  String reportUnderEstimate(String estimate) {
    return 'ड्राई रन ने $estimate का अनुमान लगाया था। clean कमांड ख़ुद तय करती हैं कि क्या हटाना है — कुछ ऐसे कैश रखती हैं जिन्हें अगला बिल्ड दोबारा इस्तेमाल कर सके, और आमतौर पर यही आप चाहते हैं।';
  }

  @override
  String reportRefusedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लक्ष्य',
      one: '1 लक्ष्य',
    );
    return '$_temp0 सुरक्षा जाँच में अस्वीकृत हुए और अछूते छोड़ दिए गए।';
  }

  @override
  String get reportWhatWentWrong => 'क्या ग़लत हुआ';

  @override
  String get reportNoDetail => 'कोई विवरण नहीं मिला।';

  @override
  String get reportScanAgain => 'फिर से स्कैन करें';

  @override
  String get reportAnotherFolder => 'दूसरा फ़ोल्डर';

  @override
  String get reportExportLog => 'लॉग निर्यात करें';

  @override
  String reportLogExported(String name) {
    return 'लॉग $name में निर्यात हुआ';
  }

  @override
  String get reportDiskBefore => 'पहले';

  @override
  String get reportDiskAfter => 'बाद में';

  @override
  String reportDiskHeading(String volume, String free, String total) {
    return '$volume — $total में से $free ख़ाली';
  }

  @override
  String get reportDiskUnavailable => 'यह वॉल्यूम अपनी ख़ाली जगह नहीं बताता।';

  @override
  String toolAvailable(String binary, String stack) {
    return '$binary इंस्टॉल है — $stack प्रोजेक्ट उसी की अपनी कमांड से साफ़ होंगे।';
  }

  @override
  String toolMissing(String binary) {
    return '$binary PATH में नहीं है। Kruftle इसे केवल बिल्ड डायरेक्टरी हटाकर साफ़ कर सकता है, जिसके लिए आपकी स्पष्ट अनुमति चाहिए।';
  }

  @override
  String toolNotApplicable(String stack) {
    return '$stack की कोई आधिकारिक clean कमांड नहीं है।';
  }

  @override
  String get cachesTitle => 'वैश्विक कैश';

  @override
  String get cachesRemeasure => 'फिर से मापें';

  @override
  String get cachesIntro =>
      'ये कैश इस मशीन के हर प्रोजेक्ट में साझा हैं। किसी एक को ख़ाली करने से अभी जगह मिलती है और बाद में दोबारा डाउनलोड करना पड़ता है — इससे कोई काम नहीं खोता।';

  @override
  String cachesFreed(String size, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कैश',
      one: '1 कैश',
    );
    return '$_temp0 से $size ख़ाली हुआ।';
  }

  @override
  String get cachesNoneFound =>
      'आपकी होम डायरेक्टरी में कोई वैश्विक कैश नहीं मिला।';

  @override
  String get cachesSelected => 'चुने गए';

  @override
  String get cachesEmptySelected => 'चुने हुए ख़ाली करें';

  @override
  String get cachesEmptying => 'ख़ाली किया जा रहा है…';

  @override
  String get cachesConfirmTitle => 'ये कैश ख़ाली करें?';

  @override
  String cachesConfirmBody(String size) {
    return 'ये इस मशीन के हर प्रोजेक्ट में साझा हैं, सिर्फ़ उसमें नहीं जिसे आपने पिछली बार स्कैन किया था। इन्हें ख़ाली करने से अभी $size मिलेंगे और अगली बार किसी भी प्रोजेक्ट को ज़रूरत पड़ने पर दोबारा डाउनलोड करना होगा।';
  }

  @override
  String get cachesConfirmAccept => 'ख़ाली करें';

  @override
  String get cachesUsesCommand =>
      'फ़ाइलें मिटाने के बजाय टूलचेन की अपनी कमांड से ख़ाली किया जाता है।';

  @override
  String get cachesUsesDelete =>
      'इस कैश के लिए कोई आधिकारिक कमांड नहीं है, इसलिए डायरेक्टरी हटा दी जाती है।';

  @override
  String get cachesDeleteTag => 'हटाएँ';

  @override
  String updateAvailable(String version, String size) {
    return 'Kruftle $version उपलब्ध है ($size)।';
  }

  @override
  String updateDownloading(String version, int percent) {
    return '$version डाउनलोड हो रहा है… $percent%';
  }

  @override
  String updateReady(String version) {
    return 'Kruftle $version सत्यापित और तैयार है। इंस्टॉलर खुल गया है।';
  }

  @override
  String get updateFailed => 'अपडेट विफल रहा।';

  @override
  String get updateAction => 'अपडेट करें';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsSectionAppearance => 'रूप-रंग';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get settingsThemeSystem => 'सिस्टम के अनुसार';

  @override
  String get settingsThemeLight => 'हल्की';

  @override
  String get settingsThemeDark => 'गहरी';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsLanguageSystem => 'सिस्टम के अनुसार';

  @override
  String get settingsReduceMotion => 'गति कम करें';

  @override
  String get settingsReduceMotionHelp =>
      'घूमने और धड़कने वाले एनिमेशन की जगह सादा प्रोग्रेस दिखाएँ। जब ऑपरेटिंग सिस्टम कम गति माँगता है तब भी यह अपने आप लागू होता है।';

  @override
  String get settingsSectionScanning => 'स्कैनिंग';

  @override
  String get settingsMaxDepth => 'अधिकतम गहराई';

  @override
  String get settingsMaxDepthHelp =>
      'चुने गए फ़ोल्डर से कितना नीचे तक देखना है। ज़्यादा गहराई में ज़्यादा नेस्टेड प्रोजेक्ट मिलते हैं और समय भी ज़्यादा लगता है।';

  @override
  String settingsLevels(int count) {
    return '$count स्तर';
  }

  @override
  String get settingsHiddenDirectories => 'छिपी डायरेक्टरियाँ शामिल करें';

  @override
  String get settingsHiddenDirectoriesHelp =>
      'बिंदु से शुरू होने वाले फ़ोल्डर। आमतौर पर एडिटर की स्थिति और टूल कैश, प्रोजेक्ट नहीं।';

  @override
  String get settingsSectionCleaning => 'सफ़ाई';

  @override
  String get settingsConcurrency => 'एक साथ कितने प्रोजेक्ट';

  @override
  String settingsConcurrencyHelp(int cores) {
    return 'समानांतर चलने वाली clean कमांड। जब तक डिस्क अड़चन न बने तब तक ज़्यादा का मतलब तेज़। $cores कोर उपलब्ध हैं।';
  }

  @override
  String get settingsTimeout => 'प्रति चरण समय-सीमा';

  @override
  String get settingsTimeoutHelp =>
      'इससे ज़्यादा देर चलने वाली clean कमांड बंद कर दी जाती है और दर्ज कर ली जाती है, ताकि एक अटका हुआ बिल्ड टूल पूरी प्रक्रिया न रोके।';

  @override
  String settingsSeconds(int count) {
    return '$count सेकंड';
  }

  @override
  String settingsMinutes(int count) {
    return '$count मिनट';
  }

  @override
  String get settingsConfirmBeforeDelete => 'हटाने से पहले पुष्टि करें';

  @override
  String get settingsConfirmBeforeDeleteHelp =>
      'जब भी कोई रन केवल clean कमांड चलाने के बजाय डायरेक्टरियाँ सीधे हटाएगा, तब एक सारांश डायलॉग दिखाएँ।';

  @override
  String get settingsSectionPreselect =>
      'इन हटाने की श्रेणियों को पहले से चुनें';

  @override
  String get settingsPreselectHelp =>
      'केवल सुविधा के लिए। हर रन में ये चुनी हुई दिखती हैं और कुछ भी हटाने से पहले पूछा ही जाता है।';

  @override
  String get settingsSectionLogging => 'लॉगिंग';

  @override
  String get settingsLogDetail => 'विवरण';

  @override
  String get settingsLogRetention => 'रखी जाने वाली लॉग फ़ाइलें';

  @override
  String get settingsLogRetentionHelp =>
      'सक्रिय लॉग घुमाए जाने पर पुरानी फ़ाइलें हटा दी जाती हैं।';

  @override
  String get settingsNone => 'कोई नहीं';

  @override
  String get settingsSectionUpdates => 'अपडेट';

  @override
  String get settingsCheckUpdates => 'अपने आप अपडेट जाँचें';

  @override
  String get settingsCheckUpdatesHelp =>
      'Kruftle शुरू होते समय GitHub Releases से पूछता है और एक सत्यापित डाउनलोड सुझाता है। यह पूछे बिना कभी इंस्टॉल नहीं करता।';

  @override
  String get settingsSectionSizes => 'आकार';

  @override
  String get settingsSizeMode => 'आकार कैसे गिने जाएँ';

  @override
  String get settingsSizeModeOnDisk => 'डिस्क पर वास्तव में घिरी जगह';

  @override
  String get settingsSizeModeApparent => 'फ़ाइलों की कुल लंबाई';

  @override
  String get settingsSizeModeHelp =>
      'डिस्क वाला आँकड़ा वही है जो ऑपरेटिंग सिस्टम बताता है और जो आपको वापस मिलता है, ब्लॉक की गोलाई और फ़ाइल सिस्टम कम्प्रेशन सहित। इसके लिए एक नेटिव कॉल चाहिए जो Windows पर नहीं है, वहाँ फ़ाइल लंबाई का सहारा लिया जाता है।';

  @override
  String get settingsSectionAbout => 'परिचय';

  @override
  String get settingsShowTour => 'फ़ीचर टूर दोबारा देखें';

  @override
  String get settingsChangelog => 'इस संस्करण में नया क्या है';

  @override
  String get settingsPrivacyPolicy => 'गोपनीयता नीति';

  @override
  String get settingsTermsOfService => 'सेवा की शर्तें';

  @override
  String settingsVersion(String version) {
    return 'संस्करण $version';
  }

  @override
  String get settingsLicence =>
      'GNU जनरल पब्लिक लाइसेंस v3.0 या बाद के तहत मुक्त सॉफ़्टवेयर।';

  @override
  String get settingsSourceCode => 'स्रोत कोड';

  @override
  String get tourWelcomeTitle => 'Kruftle में आपका स्वागत है';

  @override
  String get tourWelcomeBody =>
      'बिल्ड आर्टिफ़ैक्ट चुपचाप जमा होते रहते हैं। Kruftle आपकी डिस्क का हर प्रोजेक्ट ढूँढता है, पता लगाता है कि उसे किसने बनाया, और उसी टूलचेन से अपनी गंदगी साफ़ करने को कहता है।';

  @override
  String get tourWelcomeStart => 'मुझे दिखाइए';

  @override
  String get tourWelcomeSkip => 'टूर छोड़ें';

  @override
  String get tourScanTitle => 'इसे एक फ़ोल्डर पर लगाइए';

  @override
  String get tourScanBody =>
      'अपने कोडबेस की जड़ चुनिए। Kruftle उसके नीचे सब कुछ देखता है और प्रोजेक्ट जो फ़ाइलें छोड़ते हैं उनसे चालीस से ज़्यादा भाषाएँ और बिल्ड टूल पहचानता है — उन प्रोजेक्ट सहित जो दूसरे प्रोजेक्ट के अंदर हैं।';

  @override
  String get tourReviewTitle => 'कुछ होने से पहले देखिए कि क्या मिला';

  @override
  String get tourReviewBody =>
      'हर प्रोजेक्ट, हर आर्टिफ़ैक्ट डायरेक्टरी, और हर एक की क़ीमत — मापी हुई, अंदाज़े से नहीं। जो साफ़ करना हो उस पर निशान लगाइए। जब तक आप न कहें, कुछ भी नहीं छुआ जाता।';

  @override
  String get tourSafetyTitle => 'सुरक्षा वैकल्पिक नहीं है';

  @override
  String get tourSafetyBody =>
      'Kruftle फ़ाइलें मिटाने के बजाय हर टूलचेन की अपनी clean कमांड को प्राथमिकता देता है। सीधे हटाना डायरेक्टरी के नाम की अनुमति-सूची तक सीमित है, कभी सिमलिंक का पीछा नहीं करता, आपके चुने फ़ोल्डर से बाहर जाने से इनकार करता है, और हमेशा पहले पूछता है। git जो ट्रैक करता है उसे छुआ नहीं जाता।';

  @override
  String get tourCachesTitle => 'आपकी होम डायरेक्टरी के कैश भी';

  @override
  String get tourCachesBody =>
      'Cargo का registry, Gradle के कैश, npm और pub के कैश — हर प्रोजेक्ट में साझा और अक्सर डिस्क पर सबसे बड़ी बचत। इनके लिए अलग स्क्रीन और अलग पुष्टि है।';

  @override
  String get tourScheduleTitle => 'एक बार सेट कीजिए और भूल जाइए';

  @override
  String get tourScheduleBody =>
      'Kruftle से रोज़, हर हफ़्ते या हर महीने याद दिलवाइए, ताकि कचरे को दोबारा जमा होने का मौक़ा ही न मिले।';

  @override
  String get tourFinishTitle => 'बस इतना ही है यह ऐप';

  @override
  String get tourFinishBody =>
      'सब कुछ आपकी मशीन पर चलता है। कुछ भी अपलोड नहीं होता, और कोई खाता बनाने की ज़रूरत नहीं।';

  @override
  String get tourFinishAction => 'शुरू करें';

  @override
  String get scheduleTitle => 'निर्धारित सफ़ाई';

  @override
  String get scheduleEnable => 'मुझे सफ़ाई की याद दिलाएँ';

  @override
  String get scheduleEnableHelp =>
      'Kruftle चलते समय जाँचता है कि सफ़ाई का समय हुआ या नहीं, और कोई छूट गई हो तो शुरू होते ही बता देता है। बंद रहते हुए यह ख़ुद नहीं जाग सकता।';

  @override
  String get scheduleFrequency => 'कितनी बार';

  @override
  String get scheduleDaily => 'रोज़';

  @override
  String get scheduleWeekly => 'हर हफ़्ते';

  @override
  String get scheduleMonthly => 'हर महीने';

  @override
  String get scheduleTimeOfDay => 'समय';

  @override
  String get scheduleDayOfWeek => 'दिन';

  @override
  String get scheduleDayOfMonth => 'तारीख़';

  @override
  String get scheduleFolder => 'स्कैन करने का फ़ोल्डर';

  @override
  String get scheduleChooseFolder => 'एक फ़ोल्डर चुनें…';

  @override
  String scheduleNextRun(String when) {
    return 'अगली याद $when।';
  }

  @override
  String get scheduleNeverRun => 'अभी तक कोई सफ़ाई नहीं हुई है।';

  @override
  String scheduleLastRun(String when) {
    return 'पिछली सफ़ाई $when।';
  }

  @override
  String get scheduleDueTitle => 'सफ़ाई का समय हो गया';

  @override
  String scheduleDueBody(int days, String folder) {
    return '$folder में पिछली सफ़ाई को $days दिन हो गए।';
  }

  @override
  String get scheduleDueAction => 'अभी स्कैन करें';

  @override
  String get scheduleDueDismiss => 'बाद में';

  @override
  String get scheduleNotifyOnFinish => 'सफ़ाई पूरी होने पर मुझे सूचित करें';

  @override
  String get scheduleNotificationDueTitle => 'Kruftle — सफ़ाई का समय';

  @override
  String scheduleNotificationDueBody(String folder) {
    return '$folder से बिल्ड आर्टिफ़ैक्ट हटाने का समय हो गया है।';
  }

  @override
  String scheduleNotificationDoneTitle(String size) {
    return 'Kruftle — $size वापस मिला';
  }

  @override
  String scheduleNotificationDoneBody(int projects, String duration) {
    return '$duration में $projects प्रोजेक्ट साफ़ किए।';
  }

  @override
  String get profilesTitle => 'सफ़ाई प्रोफ़ाइल';

  @override
  String get profilesIntro =>
      'प्रोफ़ाइल Kruftle को ऐसा प्रोजेक्ट प्रकार सिखाती है जिसे वह अभी नहीं जानता: कौन-सी फ़ाइल उसे पहचानती है, कौन-सी कमांड उसे साफ़ करती है, और वह कौन-सी डायरेक्टरियाँ हटा सकता है। प्रोफ़ाइलें अंतर्निहित स्टैक के बराबर हैं और ठीक वही सुरक्षा नियम मानती हैं।';

  @override
  String get profilesNone => 'अभी कोई कस्टम प्रोफ़ाइल नहीं है।';

  @override
  String get profilesNew => 'नई प्रोफ़ाइल';

  @override
  String get profilesImport => 'आयात करें…';

  @override
  String get profilesExport => 'निर्यात करें…';

  @override
  String get profilesName => 'नाम';

  @override
  String get profilesNameHint => 'Unreal Engine';

  @override
  String get profilesMarkers => 'पहचान फ़ाइलें';

  @override
  String get profilesMarkersHint => '*.uproject';

  @override
  String get profilesMarkersHelp =>
      'इनमें से कोई भी रखने वाली डायरेक्टरी को इसी तरह का प्रोजेक्ट माना जाता है। हर पंक्ति में एक। शुरुआती बिंदु-तारांकन एक्सटेंशन से मिलान करता है।';

  @override
  String get profilesCommand => 'clean कमांड';

  @override
  String get profilesCommandHint => 'make clean';

  @override
  String get profilesCommandHelp =>
      'प्रोजेक्ट डायरेक्टरी को कार्यशील डायरेक्टरी बनाकर चलाई जाती है। नीचे दी गई डायरेक्टरियाँ ही हटानी हों तो इसे खाली छोड़ दें।';

  @override
  String get profilesArtifacts => 'जिन डायरेक्टरियों को हटाया जा सकता है';

  @override
  String get profilesArtifactsHint => 'Binaries\nIntermediate';

  @override
  String get profilesArtifactsHelp =>
      'हर पंक्ति में एक, प्रोजेक्ट की जड़ के सापेक्ष। यह अनुमति-सूची है: इससे बाहर कुछ भी कभी नहीं हटता, और हटाने के लिए हर रन में आपकी पुष्टि फिर भी चाहिए।';

  @override
  String get profilesExcludes => 'इन पथों को कभी स्कैन न करें';

  @override
  String get profilesExcludesHint => '**/vendor/**';

  @override
  String get profilesExcludesHelp =>
      'glob पैटर्न। मिलती डायरेक्टरियाँ पूरी तरह छोड़ दी जाती हैं, हर प्रोफ़ाइल और हर अंतर्निहित स्टैक के लिए।';

  @override
  String get profilesEnabled => 'सक्षम';

  @override
  String profilesDeleteConfirm(String name) {
    return 'प्रोफ़ाइल “$name” हटाएँ?';
  }

  @override
  String get profilesErrorName => 'प्रोफ़ाइल को एक नाम दीजिए।';

  @override
  String get profilesErrorMarkers =>
      'प्रोफ़ाइल को कम से कम एक पहचान फ़ाइल चाहिए, वरना वह हर फ़ोल्डर से मिल जाएगी।';

  @override
  String get profilesErrorNothingToDo =>
      'प्रोफ़ाइल को एक clean कमांड दीजिए, कुछ डायरेक्टरियाँ दीजिए, या दोनों।';

  @override
  String profilesErrorAbsolutePath(String path) {
    return 'डायरेक्टरियाँ प्रोजेक्ट की जड़ के सापेक्ष होनी चाहिए: “$path” नहीं है।';
  }

  @override
  String profilesErrorEscapes(String path) {
    return '“$path” प्रोजेक्ट के बाहर इशारा करता है। यह कभी अनुमत नहीं है।';
  }

  @override
  String profilesErrorDuplicate(String name) {
    return '“$name” नाम की प्रोफ़ाइल पहले से मौजूद है।';
  }

  @override
  String get profilesImportFailed =>
      'वह फ़ाइल Kruftle प्रोफ़ाइल निर्यात नहीं है।';

  @override
  String profilesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रोफ़ाइलें आयात हुईं।',
      one: '1 प्रोफ़ाइल आयात हुई।',
    );
    return '$_temp0';
  }

  @override
  String get diskTitle => 'डिस्क उपयोग';

  @override
  String get diskVolume => 'वॉल्यूम';

  @override
  String get diskUsed => 'उपयोग में';

  @override
  String get diskFree => 'ख़ाली';

  @override
  String get diskReclaimable => 'वापस पाने योग्य';

  @override
  String diskOfTotal(String used, String total) {
    return '$total में से $used उपयोग में';
  }

  @override
  String diskFreedThisRun(String size) {
    return '$size ख़ाली हुआ';
  }

  @override
  String get diskTreemapEmpty => 'अभी तक कुछ नहीं मापा गया।';

  @override
  String get changelogTitle => 'नया क्या है';

  @override
  String changelogVersionHeading(String version) {
    return 'संस्करण $version';
  }

  @override
  String get changelogUnavailable => 'बदलाव की सूची नहीं पढ़ी जा सकी।';

  @override
  String get changelogAdded => 'जोड़ा गया';

  @override
  String get changelogChanged => 'बदला गया';

  @override
  String get changelogFixed => 'ठीक किया गया';

  @override
  String changelogWhatsNewBanner(String version) {
    return 'Kruftle $version में अपडेट हो गया है।';
  }

  @override
  String get changelogWhatsNewAction => 'देखें क्या बदला';

  @override
  String get legalPrivacyTitle => 'गोपनीयता नीति';

  @override
  String get legalTermsTitle => 'सेवा की शर्तें';

  @override
  String get legalUnavailable => 'यह दस्तावेज़ लोड नहीं हो सका।';

  @override
  String get legalOpenInBrowser => 'ब्राउज़र में खोलें';
}
