// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class LZh extends L {
  LZh([String locale = 'zh']) : super(locale);

  @override
  String get appTagline => '找回你的磁盘空间';

  @override
  String get actionCancel => '取消';

  @override
  String get actionClose => '关闭';

  @override
  String get actionShow => '显示';

  @override
  String get actionClear => '清空';

  @override
  String get actionAll => '全选';

  @override
  String get actionAllMatching => '全选匹配项';

  @override
  String get actionNone => '全不选';

  @override
  String get actionBack => '返回';

  @override
  String get actionNext => '下一步';

  @override
  String get actionDone => '完成';

  @override
  String get actionSkip => '跳过';

  @override
  String get actionSave => '保存';

  @override
  String get actionDelete => '删除';

  @override
  String get actionAdd => '添加';

  @override
  String get actionEdit => '编辑';

  @override
  String get actionRetry => '重试';

  @override
  String get actionNotNow => '暂不';

  @override
  String get alreadyRunningTitle => 'Kruftle 已在运行';

  @override
  String get alreadyRunningBody =>
      '另一个 Kruftle 窗口正在运行。两个同时清理可能导致构建目录被删除到一半，因此不会打开此窗口。';

  @override
  String get titleBarGlobalCaches => '全局 SDK 缓存';

  @override
  String get titleBarSettings => '设置';

  @override
  String get titleBarDiskUsage => '磁盘占用';

  @override
  String get titleBarSchedule => '定时清理';

  @override
  String get titleBarProfiles => '清理配置';

  @override
  String get titleBarChangelog => '更新内容';

  @override
  String get titleBarAbout => '关于 Kruftle';

  @override
  String get railFolder => '文件夹';

  @override
  String get railScan => '扫描';

  @override
  String get railReview => '查看';

  @override
  String get railClean => '清理';

  @override
  String get railReport => '报告';

  @override
  String get sourceHeading => '让 Kruftle 检查哪个目录？';

  @override
  String get sourceSubheading => '它下面的所有内容都会被检查。在你同意之前不会改动任何东西。';

  @override
  String get sourceChooseFolder => '选择一个文件夹';

  @override
  String get sourceChooseFolderHelp => '你的代码库根目录，或任何存放项目的文件夹';

  @override
  String get sourceConfirmButton => '扫描此文件夹';

  @override
  String get sourceRecent => '最近使用';

  @override
  String get sourceForget => '从最近使用中移除';

  @override
  String get scanningLooking => '正在查找项目';

  @override
  String get scanningMeasuring => '正在测量它们的大小';

  @override
  String get scanningProjectsFound => '个项目';

  @override
  String get scanningDirectoriesWalked => '个目录已遍历';

  @override
  String get scanningMeasured => '已测量';

  @override
  String get scanningNothingYet => '暂未找到任何内容。';

  @override
  String get scanningStop => '停止扫描';

  @override
  String get reviewScanAgain => '重新扫描';

  @override
  String get reviewChangeFolder => '更换文件夹';

  @override
  String reviewProjectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个项目',
    );
    return '$_temp0';
  }

  @override
  String get reviewFilterHint => '按名称、路径或技术栈筛选   ( / )';

  @override
  String get reviewSortedBySize => '按大小排序';

  @override
  String get reviewSortedByPath => '按路径排序';

  @override
  String get reviewNoProjects => '此文件夹下没有包含构建产物的项目。';

  @override
  String reviewNoMatches(String query) {
    return '没有与“$query”匹配的内容。';
  }

  @override
  String reviewInSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '在选中的 $count 个项目中',
    );
    return '$_temp0';
  }

  @override
  String get reviewMeasuredByDryRun => '由试运行测得';

  @override
  String reviewStillMeasuring(int percent) {
    return '仍在测量 — $percent%';
  }

  @override
  String reviewFoundInTotal(String size, int count) {
    return '在 $count 个项目中共发现 $size。';
  }

  @override
  String reviewPlanSummary(int steps, int projects) {
    return '$projects 个项目共 $steps 个步骤。';
  }

  @override
  String get reviewAlsoDelete => '同时直接删除';

  @override
  String get reviewAlsoDeleteHelp =>
      'Kruftle 优先使用每个工具链自带的清理命令。以下类别只能通过删除目录来清除，因此默认关闭，除非你另行选择。';

  @override
  String get reviewRiskBuildOutput => '缺少 SDK 时的构建产物';

  @override
  String get reviewRiskBuildOutputHelp => '对于未安装工具链的项目，改为删除已知的输出目录。重新构建即可恢复。';

  @override
  String get reviewRiskDependencies => '已下载的依赖';

  @override
  String get reviewRiskDependenciesHelp =>
      'node_modules、.venv、deps。可从锁文件恢复，但需要重新下载。';

  @override
  String get reviewRiskCache => '工具缓存';

  @override
  String get reviewRiskCacheHelp =>
      '.gradle、.turbo、.mypy_cache 之类。唯一的代价是下次构建变慢。';

  @override
  String get reviewMissingToolchains => '部分选中的项目未安装 SDK。如果不勾选上面的第一项，它们会被跳过。';

  @override
  String reviewGitTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 个产物目录',
    );
    return '$_temp0已被 git 跟踪，将保持不变。删除已提交的内容不是重新构建能挽回的。';
  }

  @override
  String get reviewDryRun => '试运行';

  @override
  String get reviewRemeasure => '重新测量';

  @override
  String get reviewCleanNow => '立即清理';

  @override
  String get reviewDryRunNote => '试运行不会改动任何东西，可以跳过。';

  @override
  String get reviewLargestDirectories => '空间都在哪里';

  @override
  String get reviewLargestDirectoriesHelp => '此文件夹下最大的产物目录。将鼠标悬停在方块上可查看路径。';

  @override
  String get confirmDeleteTitle => '删除这些目录？';

  @override
  String get confirmDeleteIntro => '除了运行各工具链的清理命令外，Kruftle 还将删除：';

  @override
  String get confirmCategoryBuildOutput => '缺少 SDK 的构建输出目录';

  @override
  String get confirmCategoryDependencies => '已下载的依赖目录';

  @override
  String get confirmCategoryCache => '工具缓存目录';

  @override
  String confirmDeleteScope(int count, String folder) {
    return '涉及 $folder 下选中的 $count 个项目。这些内容都可以重新生成，git 跟踪的内容会被跳过。';
  }

  @override
  String get confirmDeleteAccept => '删除并清理';

  @override
  String get runningHeading => '正在清理';

  @override
  String runningProgress(int done, int total) {
    return '已完成 $done / $total 步';
  }

  @override
  String get runningStop => '停止';

  @override
  String get reportStopped => '已停止';

  @override
  String get reportDone => '已完成';

  @override
  String reportRanFor(String duration, int projects) {
    return '在 $projects 个项目上运行了 $duration。';
  }

  @override
  String get reportReclaimed => '已释放';

  @override
  String get reportStepsCompleted => '个步骤完成';

  @override
  String get reportFailed => '个失败';

  @override
  String get reportNothingToDo => '个无需处理';

  @override
  String get reportRefused => '个被拒绝';

  @override
  String reportUnderEstimate(String estimate) {
    return '试运行估算为 $estimate。清理命令自行决定删除什么——有些会保留重新构建可复用的缓存，这通常正是你想要的。';
  }

  @override
  String reportRefusedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 个目标',
    );
    return '$_temp0被安全检查拒绝，保持原样。';
  }

  @override
  String get reportWhatWentWrong => '出了什么问题';

  @override
  String get reportNoDetail => '未报告详细信息。';

  @override
  String get reportScanAgain => '重新扫描';

  @override
  String get reportAnotherFolder => '换个文件夹';

  @override
  String get reportExportLog => '导出日志';

  @override
  String reportLogExported(String name) {
    return '日志已导出到 $name';
  }

  @override
  String get reportDiskBefore => '之前';

  @override
  String get reportDiskAfter => '之后';

  @override
  String reportDiskHeading(String volume, String free, String total) {
    return '$volume — 可用 $free / 共 $total';
  }

  @override
  String get reportDiskUnavailable => '此卷不报告可用空间。';

  @override
  String toolAvailable(String binary, String stack) {
    return '已安装 $binary——$stack 项目将使用它自己的命令清理。';
  }

  @override
  String toolMissing(String binary) {
    return 'PATH 中没有 $binary。Kruftle 只能通过删除构建目录来清理，这需要你明确许可。';
  }

  @override
  String toolNotApplicable(String stack) {
    return '$stack 没有官方的清理命令。';
  }

  @override
  String get cachesTitle => '全局缓存';

  @override
  String get cachesRemeasure => '重新测量';

  @override
  String get cachesSortTooltip => '按大小排序';

  @override
  String get cachesSortLargest => '从大到小';

  @override
  String get cachesSortSmallest => '从小到大';

  @override
  String get cachesIntro =>
      '这些缓存由本机上的所有项目共享。清空其中一个会立即释放空间，代价是以后需要重新下载——它不会丢失任何工作成果。';

  @override
  String cachesFreed(String size, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个缓存',
    );
    return '从 $_temp0中释放了 $size。';
  }

  @override
  String get cachesNoneFound => '在你的主目录中没有找到全局缓存。';

  @override
  String get cachesSelected => '已选中';

  @override
  String get cachesEmptySelected => '清空所选';

  @override
  String get cachesEmptying => '正在清空…';

  @override
  String get cachesConfirmTitle => '清空这些缓存？';

  @override
  String cachesConfirmBody(String size) {
    return '它们由本机上的所有项目共享，不只是你上次扫描的那个。清空可立即释放 $size，代价是下次任何项目需要时都要重新下载。';
  }

  @override
  String get cachesConfirmAccept => '清空';

  @override
  String get cachesUsesCommand => '使用工具链自己的命令清空，而不是删除文件。';

  @override
  String get cachesUsesDelete => '此缓存没有官方命令，因此直接删除该目录。';

  @override
  String get cachesDeleteTag => '删除';

  @override
  String updateAvailable(String version, String size) {
    return 'Kruftle $version 可用（$size）。';
  }

  @override
  String updateDownloading(String version, int percent) {
    return '正在下载 $version… $percent%';
  }

  @override
  String updateReady(String version) {
    return 'Kruftle $version 已校验完毕，安装程序已打开。';
  }

  @override
  String get updateFailed => '更新失败。';

  @override
  String get updateAction => '更新';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSectionAppearance => '外观';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSystem => '跟随系统';

  @override
  String get settingsReduceMotion => '减弱动态效果';

  @override
  String get settingsReduceMotionHelp =>
      '用普通进度条替代扫描与脉动动画。当操作系统要求减弱动态效果时也会自动生效。';

  @override
  String get settingsSectionScanning => '扫描';

  @override
  String get settingsMaxDepth => '最大深度';

  @override
  String get settingsMaxDepthHelp => '从所选文件夹向下查找多少层。层数越深找到的嵌套项目越多，耗时也越长。';

  @override
  String settingsLevels(int count) {
    return '$count 层';
  }

  @override
  String get settingsHiddenDirectories => '包含隐藏目录';

  @override
  String get settingsHiddenDirectoriesHelp => '以点开头的文件夹。通常是编辑器状态和工具缓存，而不是项目。';

  @override
  String get settingsSectionCleaning => '清理';

  @override
  String get settingsConcurrency => '同时处理的项目数';

  @override
  String settingsConcurrencyHelp(int cores) {
    return '并行运行的清理命令数量。越多越快，直到磁盘成为瓶颈。当前有 $cores 个核心。';
  }

  @override
  String get settingsTimeout => '单步超时';

  @override
  String get settingsTimeoutHelp => '运行超过此时长的清理命令会被终止并记录，这样一个卡住的构建工具不会拖住整次运行。';

  @override
  String settingsSeconds(int count) {
    return '$count 秒';
  }

  @override
  String settingsMinutes(int count) {
    return '$count 分钟';
  }

  @override
  String get settingsConfirmBeforeDelete => '删除前确认';

  @override
  String get settingsConfirmBeforeDeleteHelp =>
      '当一次运行将直接删除目录（而不只是运行清理命令）时，显示一个摘要对话框。';

  @override
  String get settingsSectionPreselect => '预先勾选这些删除类别';

  @override
  String get settingsPreselectHelp => '仅为方便。每次运行仍会显示勾选状态，删除任何东西前仍会询问。';

  @override
  String get settingsSectionLogging => '日志';

  @override
  String get settingsLogDetail => '详细程度';

  @override
  String get settingsLogDebug => '调试';

  @override
  String get settingsLogInfo => '信息';

  @override
  String get settingsLogWarning => '警告';

  @override
  String get settingsLogError => '错误';

  @override
  String get settingsLogRetention => '保留的日志文件数';

  @override
  String get settingsLogRetentionHelp => '当前日志轮转后，较旧的文件会被删除。';

  @override
  String get settingsNone => '不保留';

  @override
  String get settingsSectionUpdates => '更新';

  @override
  String get settingsCheckUpdates => '自动检查更新';

  @override
  String get settingsCheckUpdatesHelp =>
      'Kruftle 会在启动时询问 GitHub Releases，并提供经过校验的下载。未经许可绝不安装。';

  @override
  String get settingsSectionSizes => '大小';

  @override
  String get settingsSizeMode => '大小如何计算';

  @override
  String get settingsSizeModeOnDisk => '磁盘上实际占用的空间';

  @override
  String get settingsSizeModeApparent => '文件长度总和';

  @override
  String get settingsSizeModeHelp =>
      '“磁盘占用”与操作系统的报告以及你实际能拿回的空间一致，包含块对齐和文件系统压缩。它需要一个 Windows 上没有的原生调用，在 Windows 上会退回使用文件长度。';

  @override
  String get settingsSectionAbout => '关于';

  @override
  String get settingsShowTour => '重新查看功能介绍';

  @override
  String get settingsChangelog => '本版本的更新内容';

  @override
  String get settingsPrivacyPolicy => '隐私政策';

  @override
  String get settingsTermsOfService => '服务条款';

  @override
  String settingsVersion(String version) {
    return '版本 $version';
  }

  @override
  String get settingsLicence => '基于 GNU 通用公共许可证 v3.0 或更高版本的自由软件。';

  @override
  String get settingsMadeWith => '用 ❤️ 打造于印度加尔各答';

  @override
  String get settingsSourceCode => '源代码';

  @override
  String get tourWelcomeTitle => '欢迎使用 Kruftle';

  @override
  String get tourWelcomeBody =>
      '构建产物在不知不觉中越积越多。Kruftle 会找出磁盘上的每一个项目，判断它是用什么构建的，然后请那个工具链自己收拾残局。';

  @override
  String get tourWelcomeStart => '带我看看';

  @override
  String get tourWelcomeSkip => '跳过介绍';

  @override
  String get tourScanTitle => '指定一个文件夹';

  @override
  String get tourScanBody =>
      '选择你的代码库根目录。Kruftle 会遍历它下面的一切，通过项目留下的文件识别四十多种语言和构建工具——包括嵌套在其他项目内部的项目。';

  @override
  String get tourReviewTitle => '在动手之前先看清楚';

  @override
  String get tourReviewBody =>
      '每个项目、每个产物目录，以及各自占用多少空间——都是实测的，不是猜的。勾选你想清理的内容。在你同意之前不会改动任何东西。';

  @override
  String get tourSafetyTitle => '安全不是可选项';

  @override
  String get tourSafetyBody =>
      'Kruftle 优先使用各工具链自己的清理命令，而不是删除文件。直接删除仅限于按目录名列入白名单的对象，从不跟随符号链接，绝不越出你选定的文件夹，并且总会先征求同意。git 跟踪的内容一律不动。';

  @override
  String get tourCachesTitle => '还有你主目录里的缓存';

  @override
  String get tourCachesBody =>
      'Cargo 的 registry、Gradle 的缓存、npm 和 pub 的缓存——它们由所有项目共享，往往是磁盘上收获最大的地方。它们有专门的页面和专门的确认步骤。';

  @override
  String get tourScheduleTitle => '设好就不用管了';

  @override
  String get tourScheduleBody =>
      '让 Kruftle 每天、每周或每月清理一次。它可以在打开时提醒你，也可以注册到操作系统自带的计划程序，在 Kruftle 关闭时完成清理。';

  @override
  String get tourFinishTitle => '整个应用就是这些';

  @override
  String get tourFinishBody => '所有操作都在你的机器上完成。不上传任何内容，也不需要注册账号。';

  @override
  String get tourFinishAction => '开始使用';

  @override
  String get scheduleTitle => '定时清理';

  @override
  String get scheduleEnable => '提醒我清理';

  @override
  String get scheduleEnableHelp =>
      'Kruftle 在运行时检查是否该清理了，若错过了会在启动时告诉你。在下方开启后台执行，即可在 Kruftle 未打开时也进行清理。';

  @override
  String get scheduleBackground => '即使 Kruftle 已关闭也执行';

  @override
  String get scheduleBackgroundHelp =>
      '向操作系统自带的计划程序注册一个任务，无论 Kruftle 是否打开，都会在设定的时间执行清理。它会运行各工具链自己的清理命令，并且只删除你在设置中预先勾选的类别。';

  @override
  String get scheduleBackgroundActive => '已注册到系统计划程序。';

  @override
  String get scheduleBackgroundFailed => '系统拒绝注册后台任务。Kruftle 打开时提醒仍然有效。';

  @override
  String get scheduleFrequency => '频率';

  @override
  String get scheduleDaily => '每天';

  @override
  String get scheduleWeekly => '每周';

  @override
  String get scheduleMonthly => '每月';

  @override
  String get scheduleTimeOfDay => '时间';

  @override
  String get scheduleDayOfWeek => '星期';

  @override
  String get scheduleDayOfMonth => '日期';

  @override
  String get scheduleFolder => '要扫描的文件夹';

  @override
  String get scheduleChooseFolder => '选择一个文件夹…';

  @override
  String scheduleNextRun(String when) {
    return '下次提醒：$when。';
  }

  @override
  String get scheduleNeverRun => '还没有执行过清理。';

  @override
  String scheduleLastRun(String when) {
    return '上次清理：$when。';
  }

  @override
  String get scheduleDueTitle => '该清理了';

  @override
  String scheduleDueBody(int days, String folder) {
    return '距上次清理 $folder 已经过去 $days 天。';
  }

  @override
  String get scheduleDueAction => '立即扫描';

  @override
  String get scheduleDueDismiss => '以后再说';

  @override
  String get scheduleNotifyOnFinish => '清理完成时通知我';

  @override
  String get scheduleNotificationDueTitle => 'Kruftle — 该清理了';

  @override
  String scheduleNotificationDueBody(String folder) {
    return '该清理 $folder 里的构建产物了。';
  }

  @override
  String scheduleNotificationDoneTitle(String size) {
    return 'Kruftle — 释放了 $size';
  }

  @override
  String scheduleNotificationDoneBody(int projects, String duration) {
    return '用时 $duration 清理了 $projects 个项目。';
  }

  @override
  String get profilesTitle => '清理配置';

  @override
  String get profilesIntro =>
      '配置可以教会 Kruftle 一种它还不认识的项目类型：用哪个文件识别它、用什么命令清理它、允许删除哪些目录。配置与内置技术栈平级，遵守完全相同的安全规则。';

  @override
  String get profilesNone => '还没有自定义配置。';

  @override
  String get profilesNew => '新建配置';

  @override
  String get profilesImport => '导入…';

  @override
  String get profilesExport => '导出…';

  @override
  String get profilesName => '名称';

  @override
  String get profilesNameHint => 'Unreal Engine';

  @override
  String get profilesMarkers => '标识文件';

  @override
  String get profilesMarkersHint => '*.uproject';

  @override
  String get profilesMarkersHelp =>
      '包含其中任意一个文件的目录会被视为此类项目。每行一个。以点加星号开头表示按扩展名匹配。';

  @override
  String get profilesCommand => '清理命令';

  @override
  String get profilesCommandHint => 'make clean';

  @override
  String get profilesCommandHelp => '以项目目录作为工作目录运行。留空则只删除下方列出的目录。';

  @override
  String get profilesArtifacts => '允许删除的目录';

  @override
  String get profilesArtifactsHint => 'Binaries\nIntermediate';

  @override
  String get profilesArtifactsHelp =>
      '每行一个，相对于项目根目录。这是一份白名单：名单之外的内容永远不会被删除，而且删除仍需要你在每次运行时确认。';

  @override
  String get profilesExcludes => '永不扫描这些路径';

  @override
  String get profilesExcludesHint => '**/vendor/**';

  @override
  String get profilesExcludesHelp => 'glob 模式。匹配的目录会被完全跳过，对所有配置和所有内置技术栈都生效。';

  @override
  String get profilesEnabled => '已启用';

  @override
  String profilesDeleteConfirm(String name) {
    return '删除配置“$name”？';
  }

  @override
  String get profilesErrorName => '给配置起个名字。';

  @override
  String get profilesErrorMarkers => '配置至少需要一个标识文件，否则它会匹配所有文件夹。';

  @override
  String get profilesErrorNothingToDo => '给配置一个清理命令、一些要删除的目录，或者两者都给。';

  @override
  String profilesErrorAbsolutePath(String path) {
    return '目录必须相对于项目根目录：“$path”不是。';
  }

  @override
  String profilesErrorEscapes(String path) {
    return '“$path”指向了项目之外。这是绝对不允许的。';
  }

  @override
  String profilesErrorDuplicate(String name) {
    return '已存在名为“$name”的配置。';
  }

  @override
  String get profilesImportFailed => '该文件不是 Kruftle 的配置导出文件。';

  @override
  String profilesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已导入 $count 个配置。',
    );
    return '$_temp0';
  }

  @override
  String get diskTitle => '磁盘占用';

  @override
  String get diskVolume => '卷';

  @override
  String get diskUsed => '已用';

  @override
  String get diskFree => '可用';

  @override
  String get diskReclaimable => '可释放';

  @override
  String diskOfTotal(String used, String total) {
    return '已用 $used / 共 $total';
  }

  @override
  String diskFreedThisRun(String size) {
    return '释放了 $size';
  }

  @override
  String get diskTreemapEmpty => '尚未测量任何内容。';

  @override
  String get changelogTitle => '更新内容';

  @override
  String changelogVersionHeading(String version) {
    return '版本 $version';
  }

  @override
  String get changelogUnavailable => '无法读取更新日志。';

  @override
  String get changelogAdded => '新增';

  @override
  String get changelogChanged => '变更';

  @override
  String get changelogFixed => '修复';

  @override
  String changelogWhatsNewBanner(String version) {
    return 'Kruftle 已更新到 $version。';
  }

  @override
  String get changelogWhatsNewAction => '查看更新内容';

  @override
  String get legalPrivacyTitle => '隐私政策';

  @override
  String get legalTermsTitle => '服务条款';

  @override
  String get legalUnavailable => '无法加载此文档。';

  @override
  String get legalOpenInBrowser => '在浏览器中打开';

  @override
  String get consentTitle => '条款与隐私';

  @override
  String get consentBody =>
      'Kruftle 会运行每个工具链自带的清理命令，这会删除本机上的构建产物。开始之前请阅读服务条款和隐私政策——继续即表示你接受两者。';

  @override
  String get consentAccept => '接受并继续';

  @override
  String get consentDecline => '拒绝并退出';
}
