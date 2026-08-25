// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class LJa extends L {
  LJa([String locale = 'ja']) : super(locale);

  @override
  String get appTagline => 'ディスクを取り戻す';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionClose => '閉じる';

  @override
  String get actionShow => '表示';

  @override
  String get actionClear => '消去';

  @override
  String get actionAll => 'すべて';

  @override
  String get actionAllMatching => '一致するすべて';

  @override
  String get actionNone => 'なし';

  @override
  String get actionBack => '戻る';

  @override
  String get actionNext => '次へ';

  @override
  String get actionDone => '完了';

  @override
  String get actionSkip => 'スキップ';

  @override
  String get actionSave => '保存';

  @override
  String get actionDelete => '削除';

  @override
  String get actionAdd => '追加';

  @override
  String get actionEdit => '編集';

  @override
  String get actionRetry => '再試行';

  @override
  String get actionNotNow => '後で';

  @override
  String get titleBarGlobalCaches => 'グローバル SDK キャッシュ';

  @override
  String get titleBarSettings => '設定';

  @override
  String get titleBarDiskUsage => 'ディスク使用量';

  @override
  String get titleBarSchedule => '定期クリーンアップ';

  @override
  String get titleBarProfiles => 'クリーンアップ プロファイル';

  @override
  String get titleBarChangelog => '新着情報';

  @override
  String get titleBarAbout => 'Kruftle について';

  @override
  String get railFolder => 'フォルダ';

  @override
  String get railScan => 'スキャン';

  @override
  String get railReview => '確認';

  @override
  String get railClean => 'クリーン';

  @override
  String get railReport => 'レポート';

  @override
  String get sourceHeading => 'Kruftle にどのディレクトリを調べさせますか？';

  @override
  String get sourceSubheading => 'その下にあるものはすべて調べます。あなたが指示するまで何も変更しません。';

  @override
  String get sourceChooseFolder => 'フォルダを選択';

  @override
  String get sourceChooseFolderHelp => 'コードベースのルート、またはプロジェクトを含む任意のフォルダ';

  @override
  String get sourceConfirmButton => 'このフォルダをスキャン';

  @override
  String get sourceRecent => '最近使った項目';

  @override
  String get sourceForget => '履歴から削除';

  @override
  String get scanningLooking => 'プロジェクトを探しています';

  @override
  String get scanningMeasuring => 'サイズを測定しています';

  @override
  String get scanningProjectsFound => '件のプロジェクト';

  @override
  String get scanningDirectoriesWalked => '件のディレクトリを走査';

  @override
  String get scanningMeasured => '測定済み';

  @override
  String get scanningNothingYet => 'まだ何も見つかっていません。';

  @override
  String get scanningStop => 'スキャンを停止';

  @override
  String get reviewScanAgain => '再スキャン';

  @override
  String get reviewChangeFolder => 'フォルダを変更';

  @override
  String reviewProjectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件のプロジェクト',
    );
    return '$_temp0';
  }

  @override
  String get reviewFilterHint => '名前・パス・技術で絞り込み   ( / )';

  @override
  String get reviewSortedBySize => 'サイズ順';

  @override
  String get reviewSortedByPath => 'パス順';

  @override
  String get reviewNoProjects => 'このフォルダにはビルド成果物のあるプロジェクトがありません。';

  @override
  String reviewNoMatches(String query) {
    return '「$query」に一致するものはありません。';
  }

  @override
  String reviewInSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '選択中の $count 件のプロジェクト',
    );
    return '$_temp0';
  }

  @override
  String get reviewMeasuredByDryRun => 'ドライランで測定';

  @override
  String reviewStillMeasuring(int percent) {
    return '測定中 — $percent%';
  }

  @override
  String reviewFoundInTotal(String size, int count) {
    return '$count 件のプロジェクトで合計 $size が見つかりました。';
  }

  @override
  String reviewPlanSummary(int steps, int projects) {
    return '$projects 件のプロジェクトで $steps ステップ。';
  }

  @override
  String get reviewAlsoDelete => '直接削除も行う';

  @override
  String get reviewAlsoDeleteHelp =>
      'Kruftle は各ツールチェーン自身の clean コマンドを優先します。以下のカテゴリはディレクトリを削除して取り除くため、指定がない限りオフです。';

  @override
  String get reviewRiskBuildOutput => 'SDK が無い場合のビルド成果物';

  @override
  String get reviewRiskBuildOutputHelp =>
      'ツールチェーンが未インストールのプロジェクトでは、代わりに既知の出力ディレクトリを削除します。再ビルドで元に戻ります。';

  @override
  String get reviewRiskDependencies => 'ダウンロード済みの依存関係';

  @override
  String get reviewRiskDependenciesHelp =>
      'node_modules、.venv、deps。ロックファイルから復元できますが、ダウンロードが必要になります。';

  @override
  String get reviewRiskCache => 'ツールのキャッシュ';

  @override
  String get reviewRiskCacheHelp =>
      '.gradle、.turbo、.mypy_cache など。次回のビルドが遅くなるだけです。';

  @override
  String get reviewMissingToolchains =>
      '選択したプロジェクトの一部は SDK が未インストールです。上の最初のオプションを選ばないとスキップされます。';

  @override
  String reviewGitTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件の成果物ディレクトリ',
    );
    return '$_temp0が git で管理されているため、そのまま残します。コミット済みの内容を削除すると再ビルドでは元に戻せません。';
  }

  @override
  String get reviewDryRun => 'ドライラン';

  @override
  String get reviewRemeasure => '再測定';

  @override
  String get reviewCleanNow => '今すぐクリーン';

  @override
  String get reviewDryRunNote => 'ドライランは何も変更しません。省略できます。';

  @override
  String get reviewLargestDirectories => '容量の内訳';

  @override
  String get reviewLargestDirectoriesHelp =>
      'このフォルダで最も大きい成果物ディレクトリ。ブロックにカーソルを合わせるとパスが表示されます。';

  @override
  String get confirmDeleteTitle => 'これらのディレクトリを削除しますか？';

  @override
  String get confirmDeleteIntro =>
      '各ツールチェーンの clean コマンドの実行に加えて、Kruftle は次を削除します：';

  @override
  String get confirmCategoryBuildOutput => 'SDK が無い場所のビルド出力ディレクトリ';

  @override
  String get confirmCategoryDependencies => 'ダウンロード済み依存関係のディレクトリ';

  @override
  String get confirmCategoryCache => 'ツールのキャッシュ ディレクトリ';

  @override
  String confirmDeleteScope(int count, String folder) {
    return '$folder 配下の選択中 $count 件のプロジェクトが対象です。ここにあるものはすべて再生成でき、git が管理しているものはスキップされます。';
  }

  @override
  String get confirmDeleteAccept => '削除してクリーン';

  @override
  String get runningHeading => 'クリーン中';

  @override
  String runningProgress(int done, int total) {
    return '$total ステップ中 $done 件';
  }

  @override
  String get runningStop => '停止';

  @override
  String get reportStopped => '停止しました';

  @override
  String get reportDone => '完了';

  @override
  String reportRanFor(String duration, int projects) {
    return '$projects 件のプロジェクトで $duration 実行しました。';
  }

  @override
  String get reportReclaimed => '回収';

  @override
  String get reportStepsCompleted => 'ステップ完了';

  @override
  String get reportFailed => '失敗';

  @override
  String get reportNothingToDo => '対象なし';

  @override
  String get reportRefused => '拒否';

  @override
  String reportUnderEstimate(String estimate) {
    return 'ドライランの見積もりは $estimate でした。clean コマンドは何を削除するか自分で判断します。再ビルドで再利用できるキャッシュを残すものもあり、たいていはそれが望ましい動作です。';
  }

  @override
  String reportRefusedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件の対象',
    );
    return '$_temp0が安全チェックで拒否され、そのまま残されました。';
  }

  @override
  String get reportWhatWentWrong => '問題の内容';

  @override
  String get reportNoDetail => '詳細は報告されていません。';

  @override
  String get reportScanAgain => '再スキャン';

  @override
  String get reportAnotherFolder => '別のフォルダ';

  @override
  String get reportExportLog => 'ログを書き出す';

  @override
  String reportLogExported(String name) {
    return 'ログを $name に書き出しました';
  }

  @override
  String get reportDiskBefore => '実行前';

  @override
  String get reportDiskAfter => '実行後';

  @override
  String reportDiskHeading(String volume, String free, String total) {
    return '$volume — $total 中 $free が空き';
  }

  @override
  String get reportDiskUnavailable => 'このボリュームは空き容量を報告しません。';

  @override
  String toolAvailable(String binary, String stack) {
    return '$binary がインストール済みです。$stack のプロジェクトは専用のコマンドでクリーンされます。';
  }

  @override
  String toolMissing(String binary) {
    return '$binary が PATH にありません。Kruftle はビルド ディレクトリを削除する方法でしかクリーンできず、それには明示的な許可が必要です。';
  }

  @override
  String toolNotApplicable(String stack) {
    return '$stack には公式の clean コマンドがありません。';
  }

  @override
  String get cachesTitle => 'グローバル キャッシュ';

  @override
  String get cachesRemeasure => '再測定';

  @override
  String get cachesSortTooltip => 'サイズで並べ替え';

  @override
  String get cachesSortLargest => '大きい順';

  @override
  String get cachesSortSmallest => '小さい順';

  @override
  String get cachesIntro =>
      'これらのキャッシュはこのマシンのすべてのプロジェクトで共有されます。ひとつ空にすると今すぐ容量が空き、後で再ダウンロードが必要になります。作業内容が失われることはありません。';

  @override
  String cachesFreed(String size, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件のキャッシュ',
    );
    return '$_temp0から $size を解放しました。';
  }

  @override
  String get cachesNoneFound => 'ホーム ディレクトリにグローバル キャッシュは見つかりませんでした。';

  @override
  String get cachesSelected => '選択中';

  @override
  String get cachesEmptySelected => '選択項目を空にする';

  @override
  String get cachesEmptying => '空にしています…';

  @override
  String get cachesConfirmTitle => 'これらのキャッシュを空にしますか？';

  @override
  String cachesConfirmBody(String size) {
    return 'これらは最後にスキャンしたプロジェクトだけでなく、このマシンのすべてのプロジェクトで共有されています。空にすると今 $size が解放され、次にいずれかのプロジェクトが必要としたときに再ダウンロードが発生します。';
  }

  @override
  String get cachesConfirmAccept => '空にする';

  @override
  String get cachesUsesCommand => 'ファイルを削除するのではなく、ツールチェーン自身のコマンドで空にします。';

  @override
  String get cachesUsesDelete => 'このキャッシュには公式コマンドが無いため、ディレクトリを削除します。';

  @override
  String get cachesDeleteTag => '削除';

  @override
  String updateAvailable(String version, String size) {
    return 'Kruftle $version が利用できます（$size）。';
  }

  @override
  String updateDownloading(String version, int percent) {
    return '$version をダウンロード中… $percent%';
  }

  @override
  String updateReady(String version) {
    return 'Kruftle $version の検証が完了しました。インストーラを開きました。';
  }

  @override
  String get updateFailed => '更新に失敗しました。';

  @override
  String get updateAction => '更新';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsSectionAppearance => '外観';

  @override
  String get settingsTheme => 'テーマ';

  @override
  String get settingsThemeSystem => 'システムに合わせる';

  @override
  String get settingsThemeLight => 'ライト';

  @override
  String get settingsThemeDark => 'ダーク';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageSystem => 'システムに合わせる';

  @override
  String get settingsReduceMotion => '動きを減らす';

  @override
  String get settingsReduceMotionHelp =>
      '走査やパルスのアニメーションを単純な進行表示に置き換えます。OS が動きの低減を要求している場合も自動的に適用されます。';

  @override
  String get settingsSectionScanning => 'スキャン';

  @override
  String get settingsMaxDepth => '最大の深さ';

  @override
  String get settingsMaxDepthHelp =>
      '選択したフォルダから何階層下まで調べるか。深いほど入れ子のプロジェクトが多く見つかり、時間もかかります。';

  @override
  String settingsLevels(int count) {
    return '$count 階層';
  }

  @override
  String get settingsHiddenDirectories => '隠しディレクトリを含める';

  @override
  String get settingsHiddenDirectoriesHelp =>
      'ドットで始まるフォルダ。多くはプロジェクトではなくエディタの状態やツールのキャッシュです。';

  @override
  String get settingsSectionCleaning => 'クリーンアップ';

  @override
  String get settingsConcurrency => '同時に処理するプロジェクト数';

  @override
  String settingsConcurrencyHelp(int cores) {
    return '並列で実行する clean コマンドの数。ディスクがボトルネックになるまでは多いほど高速です。利用可能なコアは $cores 個です。';
  }

  @override
  String get settingsTimeout => 'ステップのタイムアウト';

  @override
  String get settingsTimeoutHelp =>
      'これより長くかかる clean コマンドは強制終了して記録します。止まったビルド ツールが実行全体を止めないためです。';

  @override
  String settingsSeconds(int count) {
    return '$count 秒';
  }

  @override
  String settingsMinutes(int count) {
    return '$count 分';
  }

  @override
  String get settingsConfirmBeforeDelete => '削除前に確認する';

  @override
  String get settingsConfirmBeforeDeleteHelp =>
      'clean コマンドを実行するだけでなくディレクトリを直接削除する場合に、要約ダイアログを表示します。';

  @override
  String get settingsSectionPreselect => 'これらの削除カテゴリをあらかじめ選択';

  @override
  String get settingsPreselectHelp =>
      '利便性のためだけの設定です。実行ごとにチェック状態は表示され、何かを削除する前には必ず確認します。';

  @override
  String get settingsSectionLogging => 'ログ';

  @override
  String get settingsLogDetail => '詳細度';

  @override
  String get settingsLogDebug => 'デバッグ';

  @override
  String get settingsLogInfo => '情報';

  @override
  String get settingsLogWarning => '警告';

  @override
  String get settingsLogError => 'エラー';

  @override
  String get settingsLogRetention => '保持するログ ファイル数';

  @override
  String get settingsLogRetentionHelp => '現在のログがローテーションされると、古いファイルは削除されます。';

  @override
  String get settingsNone => '保持しない';

  @override
  String get settingsSectionUpdates => '更新';

  @override
  String get settingsCheckUpdates => '自動的に更新を確認する';

  @override
  String get settingsCheckUpdatesHelp =>
      'Kruftle は起動時に GitHub Releases を確認し、検証済みのダウンロードを提示します。確認なしにインストールすることはありません。';

  @override
  String get settingsSectionSizes => 'サイズ';

  @override
  String get settingsSizeMode => 'サイズの数え方';

  @override
  String get settingsSizeModeOnDisk => 'ディスク上の実際の占有量';

  @override
  String get settingsSizeModeApparent => 'ファイル長の合計';

  @override
  String get settingsSizeModeHelp =>
      'ディスク上の値は、ブロック単位の切り上げやファイルシステムの圧縮を含め、OS が報告する値および実際に戻ってくる容量と一致します。Windows には無いネイティブ呼び出しが必要で、Windows ではファイル長を使います。';

  @override
  String get settingsSectionAbout => '情報';

  @override
  String get settingsShowTour => '機能ツアーをもう一度見る';

  @override
  String get settingsChangelog => 'このバージョンの新着情報';

  @override
  String get settingsPrivacyPolicy => 'プライバシー ポリシー';

  @override
  String get settingsTermsOfService => '利用規約';

  @override
  String settingsVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String get settingsLicence => 'GNU 一般公衆利用許諾書 v3.0 以降に基づく自由ソフトウェアです。';

  @override
  String get settingsMadeWith => '❤️ を込めてインド・コルカタで開発';

  @override
  String get settingsSourceCode => 'ソースコード';

  @override
  String get tourWelcomeTitle => 'Kruftle へようこそ';

  @override
  String get tourWelcomeBody =>
      'ビルド成果物は静かに積み上がります。Kruftle はディスク上のすべてのプロジェクトを見つけ、何がビルドしたのかを突き止め、そのツールチェーン自身に後片付けをさせます。';

  @override
  String get tourWelcomeStart => '案内してもらう';

  @override
  String get tourWelcomeSkip => 'ツアーをスキップ';

  @override
  String get tourScanTitle => 'フォルダを指定する';

  @override
  String get tourScanBody =>
      'コードベースのルートを選んでください。Kruftle はその下をすべて走査し、プロジェクトが残したファイルから 40 を超える言語とビルド ツールを識別します。他のプロジェクトの中に入れ子になったものも含みます。';

  @override
  String get tourReviewTitle => '何かが起きる前に、見つかったものを確認';

  @override
  String get tourReviewBody =>
      'すべてのプロジェクト、すべての成果物ディレクトリ、そしてそれぞれの容量を、推測ではなく実測で表示します。クリーンしたいものにチェックを入れてください。あなたが指示するまで何も変更しません。';

  @override
  String get tourSafetyTitle => '安全性は譲れません';

  @override
  String get tourSafetyBody =>
      'Kruftle はファイルを削除するより各ツールチェーン自身の clean コマンドを優先します。直接削除はディレクトリ名の許可リストに限られ、シンボリックリンクを辿らず、選んだフォルダの外には決して出ず、必ず先に確認します。git が管理しているものには触れません。';

  @override
  String get tourCachesTitle => 'ホーム ディレクトリのキャッシュも';

  @override
  String get tourCachesBody =>
      'Cargo のレジストリ、Gradle のキャッシュ、npm と pub のキャッシュ。すべてのプロジェクトで共有され、ディスク上で最も大きな効果になることも少なくありません。専用の画面と専用の確認があります。';

  @override
  String get tourScheduleTitle => '設定したら忘れてよい';

  @override
  String get tourScheduleBody =>
      'Kruftle に毎日・毎週・毎月の掃除をさせましょう。開いている間に知らせることも、オペレーティングシステム自身のスケジューラーに登録して Kruftle を閉じたまま実行することもできます。';

  @override
  String get tourFinishTitle => 'アプリの全体像は以上です';

  @override
  String get tourFinishBody => 'すべてお使いのマシン上で動きます。何もアップロードされず、アカウントを作る必要もありません。';

  @override
  String get tourFinishAction => 'はじめる';

  @override
  String get scheduleTitle => '定期クリーンアップ';

  @override
  String get scheduleEnable => 'クリーンアップを知らせる';

  @override
  String get scheduleEnableHelp =>
      'Kruftle は実行中にクリーンアップの予定を確認し、見逃したものがあれば起動時に知らせます。Kruftle を開かずに実行するには、下のバックグラウンド実行をオンにしてください。';

  @override
  String get scheduleBackground => 'Kruftle を閉じていても実行する';

  @override
  String get scheduleBackgroundHelp =>
      'オペレーティングシステム自身のスケジューラーにジョブを登録します。Kruftle が開いているかどうかにかかわらず、指定した時刻にクリーンアップが実行されます。各ツールチェーンの clean コマンドを実行し、設定であらかじめ選んだ種類だけを削除します。';

  @override
  String get scheduleBackgroundActive => 'システムのスケジューラーに登録済みです。';

  @override
  String get scheduleBackgroundFailed =>
      'システムがバックグラウンドジョブの登録を拒否しました。Kruftle を開いている間はリマインダーが引き続き機能します。';

  @override
  String get scheduleFrequency => '頻度';

  @override
  String get scheduleDaily => '毎日';

  @override
  String get scheduleWeekly => '毎週';

  @override
  String get scheduleMonthly => '毎月';

  @override
  String get scheduleTimeOfDay => '時刻';

  @override
  String get scheduleDayOfWeek => '曜日';

  @override
  String get scheduleDayOfMonth => '日付';

  @override
  String get scheduleFolder => 'スキャンするフォルダ';

  @override
  String get scheduleChooseFolder => 'フォルダを選択…';

  @override
  String scheduleNextRun(String when) {
    return '次回のお知らせは $when。';
  }

  @override
  String get scheduleNeverRun => 'まだクリーンアップは実行されていません。';

  @override
  String scheduleLastRun(String when) {
    return '前回のクリーンアップは $when。';
  }

  @override
  String get scheduleDueTitle => 'クリーンアップの時期です';

  @override
  String scheduleDueBody(int days, String folder) {
    return '$folder の前回のクリーンアップから $days 日が経過しました。';
  }

  @override
  String get scheduleDueAction => '今すぐスキャン';

  @override
  String get scheduleDueDismiss => '後で';

  @override
  String get scheduleNotifyOnFinish => 'クリーンアップの完了を通知する';

  @override
  String get scheduleNotificationDueTitle => 'Kruftle — クリーンアップの時期です';

  @override
  String scheduleNotificationDueBody(String folder) {
    return '$folder のビルド成果物を片付ける時期です。';
  }

  @override
  String scheduleNotificationDoneTitle(String size) {
    return 'Kruftle — $size を回収';
  }

  @override
  String scheduleNotificationDoneBody(int projects, String duration) {
    return '$duration で $projects 件のプロジェクトをクリーンしました。';
  }

  @override
  String get profilesTitle => 'クリーンアップ プロファイル';

  @override
  String get profilesIntro =>
      'プロファイルは Kruftle がまだ知らないプロジェクト種別を教えるものです。どのファイルが目印か、どのコマンドでクリーンするか、どのディレクトリを削除してよいかを指定します。プロファイルは組み込みの技術と対等に扱われ、まったく同じ安全規則に従います。';

  @override
  String get profilesNone => 'カスタム プロファイルはまだありません。';

  @override
  String get profilesNew => '新しいプロファイル';

  @override
  String get profilesImport => '読み込み…';

  @override
  String get profilesExport => '書き出し…';

  @override
  String get profilesName => '名前';

  @override
  String get profilesNameHint => 'Unreal Engine';

  @override
  String get profilesMarkers => '目印となるファイル';

  @override
  String get profilesMarkersHint => '*.uproject';

  @override
  String get profilesMarkersHelp =>
      'これらのいずれかを含むディレクトリを、この種別のプロジェクトとして扱います。1 行に 1 つ。先頭のドットとアスタリスクは拡張子で一致します。';

  @override
  String get profilesCommand => 'clean コマンド';

  @override
  String get profilesCommandHint => 'make clean';

  @override
  String get profilesCommandHelp =>
      'プロジェクトのディレクトリを作業ディレクトリとして実行します。下のディレクトリを削除するだけでよい場合は空のままにしてください。';

  @override
  String get profilesArtifacts => '削除してよいディレクトリ';

  @override
  String get profilesArtifactsHint => 'Binaries\nIntermediate';

  @override
  String get profilesArtifactsHelp =>
      '1 行に 1 つ、プロジェクト ルートからの相対パスで指定します。これは許可リストです。この外にあるものが削除されることはなく、削除には実行ごとの確認が必要です。';

  @override
  String get profilesExcludes => 'これらのパスは決してスキャンしない';

  @override
  String get profilesExcludesHint => '**/vendor/**';

  @override
  String get profilesExcludesHelp =>
      'glob パターン。一致したディレクトリは、すべてのプロファイルと組み込み技術において完全にスキップされます。';

  @override
  String get profilesEnabled => '有効';

  @override
  String profilesDeleteConfirm(String name) {
    return 'プロファイル「$name」を削除しますか？';
  }

  @override
  String get profilesErrorName => 'プロファイルに名前を付けてください。';

  @override
  String get profilesErrorMarkers =>
      'プロファイルには目印となるファイルが少なくとも 1 つ必要です。無いとすべてのフォルダに一致してしまいます。';

  @override
  String get profilesErrorNothingToDo =>
      'プロファイルに clean コマンド、削除するディレクトリ、またはその両方を指定してください。';

  @override
  String profilesErrorAbsolutePath(String path) {
    return 'ディレクトリはプロジェクト ルートからの相対パスである必要があります。「$path」は相対パスではありません。';
  }

  @override
  String profilesErrorEscapes(String path) {
    return '「$path」はプロジェクトの外を指しています。これは決して許可されません。';
  }

  @override
  String profilesErrorDuplicate(String name) {
    return '「$name」という名前のプロファイルはすでに存在します。';
  }

  @override
  String get profilesImportFailed => 'そのファイルは Kruftle のプロファイル書き出しではありません。';

  @override
  String profilesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件のプロファイルを読み込みました。',
    );
    return '$_temp0';
  }

  @override
  String get diskTitle => 'ディスク使用量';

  @override
  String get diskVolume => 'ボリューム';

  @override
  String get diskUsed => '使用中';

  @override
  String get diskFree => '空き';

  @override
  String get diskReclaimable => '回収可能';

  @override
  String diskOfTotal(String used, String total) {
    return '$total 中 $used を使用';
  }

  @override
  String diskFreedThisRun(String size) {
    return '$size を解放';
  }

  @override
  String get diskTreemapEmpty => 'まだ何も測定していません。';

  @override
  String get changelogTitle => '新着情報';

  @override
  String changelogVersionHeading(String version) {
    return 'バージョン $version';
  }

  @override
  String get changelogUnavailable => '変更履歴を読み込めませんでした。';

  @override
  String get changelogAdded => '追加';

  @override
  String get changelogChanged => '変更';

  @override
  String get changelogFixed => '修正';

  @override
  String changelogWhatsNewBanner(String version) {
    return 'Kruftle が $version に更新されました。';
  }

  @override
  String get changelogWhatsNewAction => '変更点を見る';

  @override
  String get legalPrivacyTitle => 'プライバシー ポリシー';

  @override
  String get legalTermsTitle => '利用規約';

  @override
  String get legalUnavailable => 'この文書を読み込めませんでした。';

  @override
  String get legalOpenInBrowser => 'ブラウザで開く';

  @override
  String get consentTitle => '規約とプライバシー';

  @override
  String get consentBody =>
      'Kruftle は各ツールチェーン自身の clean コマンドを実行し、このマシンからビルド出力を削除します。開始する前に利用規約とプライバシーポリシーをお読みください。続行すると両方に同意したものとみなされます。';

  @override
  String get consentAccept => '同意して続ける';

  @override
  String get consentDecline => '同意せず終了する';
}
