// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class LRu extends L {
  LRu([String locale = 'ru']) : super(locale);

  @override
  String get appTagline => 'Верните себе место на диске';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get actionShow => 'Показать';

  @override
  String get actionClear => 'Очистить';

  @override
  String get actionAll => 'Все';

  @override
  String get actionAllMatching => 'Все совпадения';

  @override
  String get actionNone => 'Ничего';

  @override
  String get actionBack => 'Назад';

  @override
  String get actionNext => 'Далее';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionSkip => 'Пропустить';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionAdd => 'Добавить';

  @override
  String get actionEdit => 'Изменить';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get actionNotNow => 'Не сейчас';

  @override
  String get titleBarGlobalCaches => 'Глобальные кэши SDK';

  @override
  String get titleBarSettings => 'Настройки';

  @override
  String get titleBarDiskUsage => 'Использование диска';

  @override
  String get titleBarSchedule => 'Запланированные очистки';

  @override
  String get titleBarProfiles => 'Профили очистки';

  @override
  String get titleBarChangelog => 'Что нового';

  @override
  String get titleBarAbout => 'О программе Kruftle';

  @override
  String get railFolder => 'Папка';

  @override
  String get railScan => 'Поиск';

  @override
  String get railReview => 'Проверка';

  @override
  String get railClean => 'Очистка';

  @override
  String get railReport => 'Отчёт';

  @override
  String get sourceHeading => 'Какой каталог просмотреть Kruftle?';

  @override
  String get sourceSubheading =>
      'Проверяется всё, что находится внутри. Ничего не трогается, пока вы не скажете.';

  @override
  String get sourceChooseFolder => 'Выберите папку';

  @override
  String get sourceChooseFolderHelp =>
      'Корень вашего кода или любая папка с проектами';

  @override
  String get sourceConfirmButton => 'Просмотреть эту папку';

  @override
  String get sourceRecent => 'Недавние';

  @override
  String get sourceForget => 'Убрать из недавних';

  @override
  String get scanningLooking => 'Идёт поиск проектов';

  @override
  String get scanningMeasuring => 'Измеряется их объём';

  @override
  String get scanningProjectsFound => 'проектов найдено';

  @override
  String get scanningDirectoriesWalked => 'каталогов просмотрено';

  @override
  String get scanningMeasured => 'измерено';

  @override
  String get scanningNothingYet => 'Пока ничего не найдено.';

  @override
  String get scanningStop => 'Остановить поиск';

  @override
  String get reviewScanAgain => 'Искать заново';

  @override
  String get reviewChangeFolder => 'Сменить папку';

  @override
  String reviewProjectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count проекта',
      many: '$count проектов',
      few: '$count проекта',
      one: '$count проект',
    );
    return '$_temp0';
  }

  @override
  String get reviewFilterHint => 'Фильтр по имени, пути или технологии   ( / )';

  @override
  String get reviewSortedBySize => 'По размеру';

  @override
  String get reviewSortedByPath => 'По пути';

  @override
  String get reviewNoProjects =>
      'В этой папке нет проектов с результатами сборки.';

  @override
  String reviewNoMatches(String query) {
    return 'Ничего не совпадает с «$query».';
  }

  @override
  String reviewInSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'в $count выбранных проектах',
      many: 'в $count выбранных проектах',
      few: 'в $count выбранных проектах',
      one: 'в $count выбранном проекте',
    );
    return '$_temp0';
  }

  @override
  String get reviewMeasuredByDryRun => 'измерено пробным запуском';

  @override
  String reviewStillMeasuring(int percent) {
    return 'идёт измерение — $percent %';
  }

  @override
  String reviewFoundInTotal(String size, int count) {
    return 'Всего найдено $size в $count проектах.';
  }

  @override
  String reviewPlanSummary(int steps, int projects) {
    return '$steps шагов в $projects проектах.';
  }

  @override
  String get reviewAlsoDelete => 'Также удалять напрямую';

  @override
  String get reviewAlsoDeleteHelp =>
      'Kruftle предпочитает собственную команду очистки каждого инструмента. Эти категории удаляются вместе с каталогом, поэтому по умолчанию выключены.';

  @override
  String get reviewRiskBuildOutput => 'Результаты сборки, когда нет SDK';

  @override
  String get reviewRiskBuildOutputHelp =>
      'Для проектов, чей инструмент не установлен, вместо этого удаляется известный каталог вывода. Повторная сборка его восстановит.';

  @override
  String get reviewRiskDependencies => 'Загруженные зависимости';

  @override
  String get reviewRiskDependenciesHelp =>
      'node_modules, .venv, deps. Восстанавливаются из lock-файла, но это стоит новой загрузки.';

  @override
  String get reviewRiskCache => 'Кэши инструментов';

  @override
  String get reviewRiskCacheHelp =>
      '.gradle, .turbo, .mypy_cache и им подобные. Единственная плата — более медленная следующая сборка.';

  @override
  String get reviewMissingToolchains =>
      'У части выбранных проектов не установлен SDK. Без первого варианта выше они будут пропущены.';

  @override
  String reviewGitTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count каталога артефактов отслеживаются',
      many: '$count каталогов артефактов отслеживаются',
      few: '$count каталога артефактов отслеживаются',
      one: '$count каталог артефактов отслеживается',
    );
    return '$_temp0 git и останутся нетронутыми. Удаление уже зафиксированного содержимого повторной сборкой не отменить.';
  }

  @override
  String get reviewDryRun => 'Пробный запуск';

  @override
  String get reviewRemeasure => 'Измерить заново';

  @override
  String get reviewCleanNow => 'Очистить сейчас';

  @override
  String get reviewDryRunNote =>
      'Пробный запуск ничего не меняет. Его можно пропустить.';

  @override
  String get reviewLargestDirectories => 'Где занято место';

  @override
  String get reviewLargestDirectoriesHelp =>
      'Самые большие каталоги артефактов в этой папке. Наведите курсор на блок, чтобы увидеть путь.';

  @override
  String get confirmDeleteTitle => 'Удалить эти каталоги?';

  @override
  String get confirmDeleteIntro =>
      'Помимо запуска команды очистки каждого инструмента, Kruftle удалит:';

  @override
  String get confirmCategoryBuildOutput =>
      'каталоги вывода сборки там, где нет SDK';

  @override
  String get confirmCategoryDependencies => 'каталоги загруженных зависимостей';

  @override
  String get confirmCategoryCache => 'каталоги кэшей инструментов';

  @override
  String confirmDeleteScope(int count, String folder) {
    return 'В $count выбранных проектах внутри $folder. Всё это можно создать заново, а то, что отслеживает git, пропускается.';
  }

  @override
  String get confirmDeleteAccept => 'Удалить и очистить';

  @override
  String get runningHeading => 'Идёт очистка';

  @override
  String runningProgress(int done, int total) {
    return '$done из $total шагов';
  }

  @override
  String get runningStop => 'Остановить';

  @override
  String get reportStopped => 'Остановлено';

  @override
  String get reportDone => 'Готово';

  @override
  String reportRanFor(String duration, int projects) {
    return 'Заняло $duration по $projects проектам.';
  }

  @override
  String get reportReclaimed => 'освобождено';

  @override
  String get reportStepsCompleted => 'шагов выполнено';

  @override
  String get reportFailed => 'с ошибкой';

  @override
  String get reportNothingToDo => 'нечего делать';

  @override
  String get reportRefused => 'отклонено';

  @override
  String reportUnderEstimate(String estimate) {
    return 'Пробный запуск оценил $estimate. Команды очистки сами решают, что удалять, — некоторые сохраняют кэши, которые пригодятся следующей сборке, и обычно это именно то, что нужно.';
  }

  @override
  String reportRefusedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count цели отклонены',
      many: '$count целей отклонено',
      few: '$count цели отклонены',
      one: '$count цель отклонена',
    );
    return '$_temp0 проверкой безопасности и оставлены нетронутыми.';
  }

  @override
  String get reportWhatWentWrong => 'Что пошло не так';

  @override
  String get reportNoDetail => 'Подробностей не сообщено.';

  @override
  String get reportScanAgain => 'Искать заново';

  @override
  String get reportAnotherFolder => 'Другая папка';

  @override
  String get reportExportLog => 'Экспорт журнала';

  @override
  String reportLogExported(String name) {
    return 'Журнал экспортирован в $name';
  }

  @override
  String get reportDiskBefore => 'до';

  @override
  String get reportDiskAfter => 'после';

  @override
  String reportDiskHeading(String volume, String free, String total) {
    return '$volume — свободно $free из $total';
  }

  @override
  String get reportDiskUnavailable => 'Этот том не сообщает о свободном месте.';

  @override
  String toolAvailable(String binary, String stack) {
    return '$binary установлен — проекты $stack будут очищены их собственной командой.';
  }

  @override
  String toolMissing(String binary) {
    return '$binary нет в PATH. Kruftle может очистить это только удалением каталога сборки, а для этого нужно ваше явное разрешение.';
  }

  @override
  String toolNotApplicable(String stack) {
    return 'У $stack нет официальной команды очистки.';
  }

  @override
  String get cachesTitle => 'Глобальные кэши';

  @override
  String get cachesRemeasure => 'Измерить заново';

  @override
  String get cachesSortTooltip => 'Сортировать по размеру';

  @override
  String get cachesSortLargest => 'Сначала крупные';

  @override
  String get cachesSortSmallest => 'Сначала мелкие';

  @override
  String get cachesIntro =>
      'Эти кэши общие для всех проектов на компьютере. Очистка одного освобождает место сейчас и стоит повторной загрузки позже — работа при этом никогда не теряется.';

  @override
  String cachesFreed(String size, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count кэшей',
      many: '$count кэшей',
      few: '$count кэшей',
      one: '$count кэша',
    );
    return 'Освобождено $size из $_temp0.';
  }

  @override
  String get cachesNoneFound =>
      'В домашнем каталоге глобальных кэшей не найдено.';

  @override
  String get cachesSelected => 'выбрано';

  @override
  String get cachesEmptySelected => 'Очистить выбранные';

  @override
  String get cachesEmptying => 'Очистка…';

  @override
  String get cachesConfirmTitle => 'Очистить эти кэши?';

  @override
  String cachesConfirmBody(String size) {
    return 'Они общие для всех проектов на этом компьютере, а не только для того, который вы просматривали последним. Очистка освободит $size сейчас и потребует повторной загрузки, когда они снова понадобятся любому проекту.';
  }

  @override
  String get cachesConfirmAccept => 'Очистить';

  @override
  String get cachesUsesCommand =>
      'Очищается собственной командой инструмента, а не удалением файлов.';

  @override
  String get cachesUsesDelete =>
      'Для этого кэша нет официальной команды, поэтому каталог удаляется.';

  @override
  String get cachesDeleteTag => 'удалить';

  @override
  String updateAvailable(String version, String size) {
    return 'Доступен Kruftle $version ($size).';
  }

  @override
  String updateDownloading(String version, int percent) {
    return 'Загрузка $version… $percent %';
  }

  @override
  String updateReady(String version) {
    return 'Kruftle $version проверен и готов. Установщик открыт.';
  }

  @override
  String get updateFailed => 'Не удалось обновить.';

  @override
  String get updateAction => 'Обновить';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsSectionAppearance => 'Внешний вид';

  @override
  String get settingsTheme => 'Оформление';

  @override
  String get settingsThemeSystem => 'Как в системе';

  @override
  String get settingsThemeLight => 'Светлое';

  @override
  String get settingsThemeDark => 'Тёмное';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSystem => 'Как в системе';

  @override
  String get settingsReduceMotion => 'Меньше движения';

  @override
  String get settingsReduceMotionHelp =>
      'Заменяет скользящие и пульсирующие анимации простым индикатором. Также применяется автоматически, когда система просит уменьшить движение.';

  @override
  String get settingsSectionScanning => 'Поиск';

  @override
  String get settingsMaxDepth => 'Максимальная глубина';

  @override
  String get settingsMaxDepthHelp =>
      'Насколько глубоко искать под выбранной папкой. Глубже — больше вложенных проектов и дольше поиск.';

  @override
  String settingsLevels(int count) {
    return '$count уровней';
  }

  @override
  String get settingsHiddenDirectories => 'Включать скрытые каталоги';

  @override
  String get settingsHiddenDirectoriesHelp =>
      'Папки, начинающиеся с точки. Обычно это состояние редактора и кэши инструментов, а не проекты.';

  @override
  String get settingsSectionCleaning => 'Очистка';

  @override
  String get settingsConcurrency => 'Проектов одновременно';

  @override
  String settingsConcurrencyHelp(int cores) {
    return 'Команды очистки, работающие параллельно. Больше — быстрее, пока узким местом не станет диск. Доступно ядер: $cores.';
  }

  @override
  String get settingsTimeout => 'Тайм-аут шага';

  @override
  String get settingsTimeoutHelp =>
      'Команда очистки, которая работает дольше, снимается и записывается в журнал, чтобы один зависший инструмент не задерживал весь запуск.';

  @override
  String settingsSeconds(int count) {
    return '$count секунд';
  }

  @override
  String settingsMinutes(int count) {
    return '$count минут';
  }

  @override
  String get settingsConfirmBeforeDelete => 'Подтверждать перед удалением';

  @override
  String get settingsConfirmBeforeDeleteHelp =>
      'Показывать сводное окно всякий раз, когда запуск будет удалять каталоги напрямую, а не только выполнять команды очистки.';

  @override
  String get settingsSectionPreselect =>
      'Заранее отмечать эти категории удаления';

  @override
  String get settingsPreselectHelp =>
      'Только для удобства. Каждый запуск всё равно показывает их отмеченными и всё равно спрашивает перед удалением.';

  @override
  String get settingsSectionLogging => 'Журналирование';

  @override
  String get settingsLogDetail => 'Подробность';

  @override
  String get settingsLogDebug => 'Отладка';

  @override
  String get settingsLogInfo => 'Информация';

  @override
  String get settingsLogWarning => 'Предупреждение';

  @override
  String get settingsLogError => 'Ошибка';

  @override
  String get settingsLogRetention => 'Сколько файлов журнала хранить';

  @override
  String get settingsLogRetentionHelp =>
      'Более старые файлы удаляются после ротации текущего журнала.';

  @override
  String get settingsNone => 'не хранить';

  @override
  String get settingsSectionUpdates => 'Обновления';

  @override
  String get settingsCheckUpdates => 'Проверять обновления автоматически';

  @override
  String get settingsCheckUpdatesHelp =>
      'При запуске Kruftle обращается к GitHub Releases и предлагает проверенную загрузку. Он никогда не устанавливает ничего без спроса.';

  @override
  String get settingsSectionSizes => 'Размеры';

  @override
  String get settingsSizeMode => 'Как считаются размеры';

  @override
  String get settingsSizeModeOnDisk => 'Место, реально занятое на диске';

  @override
  String get settingsSizeModeApparent => 'Суммарная длина файлов';

  @override
  String get settingsSizeModeHelp =>
      'Значение «на диске» совпадает с тем, что сообщает операционная система и что вы получите обратно, включая округление до блоков и сжатие файловой системы. Оно требует системного вызова, которого нет в Windows, — там используется длина файлов.';

  @override
  String get settingsSectionAbout => 'О программе';

  @override
  String get settingsShowTour => 'Показать обзор возможностей ещё раз';

  @override
  String get settingsChangelog => 'Что нового в этой версии';

  @override
  String get settingsPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get settingsTermsOfService => 'Условия использования';

  @override
  String settingsVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get settingsLicence =>
      'Свободное программное обеспечение под GNU General Public License v3.0 или новее.';

  @override
  String get settingsMadeWith => 'Сделано с ❤️ в Калькутте, Индия';

  @override
  String get settingsSourceCode => 'Исходный код';

  @override
  String get tourWelcomeTitle => 'Добро пожаловать в Kruftle';

  @override
  String get tourWelcomeBody =>
      'Результаты сборки копятся незаметно. Kruftle находит каждый проект на диске, выясняет, чем он собран, и просит этот инструмент убрать за собой.';

  @override
  String get tourWelcomeStart => 'Покажите мне';

  @override
  String get tourWelcomeSkip => 'Пропустить обзор';

  @override
  String get tourScanTitle => 'Укажите папку';

  @override
  String get tourScanBody =>
      'Выберите корень своего кода. Kruftle просматривает всё внутри и распознаёт более сорока языков и инструментов сборки по файлам, которые они оставляют, — включая проекты, вложенные в другие проекты.';

  @override
  String get tourReviewTitle =>
      'Посмотрите, что найдено, до того как что-либо произойдёт';

  @override
  String get tourReviewBody =>
      'Каждый проект, каждый каталог артефактов и то, во сколько он вам обходится, — измерено, а не угадано. Отметьте, что нужно очистить. Ничего не трогается, пока вы не скажете.';

  @override
  String get tourSafetyTitle => 'Безопасность не обсуждается';

  @override
  String get tourSafetyBody =>
      'Kruftle предпочитает команду очистки самого инструмента удалению файлов. Прямое удаление ограничено списком разрешённых имён каталогов, никогда не идёт по символической ссылке, не выходит за пределы выбранной вами папки и всегда сначала спрашивает. Всё, что отслеживает git, остаётся нетронутым.';

  @override
  String get tourCachesTitle => 'И кэши в домашнем каталоге тоже';

  @override
  String get tourCachesBody =>
      'Реестр Cargo, кэши Gradle, кэши npm и pub — они общие для всех проектов и нередко дают наибольший выигрыш. У них свой экран и своё подтверждение.';

  @override
  String get tourScheduleTitle => 'Настройте и забудьте';

  @override
  String get tourScheduleBody =>
      'Пусть Kruftle убирается ежедневно, еженедельно или ежемесячно. Он может напомнить, пока открыт, либо зарегистрироваться в планировщике вашей операционной системы и выполнить очистку при закрытом Kruftle.';

  @override
  String get tourFinishTitle => 'Вот и всё приложение';

  @override
  String get tourFinishBody =>
      'Всё работает на вашем компьютере. Ничего не отправляется, и никакой учётной записи создавать не нужно.';

  @override
  String get tourFinishAction => 'Начать';

  @override
  String get scheduleTitle => 'Запланированные очистки';

  @override
  String get scheduleEnable => 'Напоминать об очистке';

  @override
  String get scheduleEnableHelp =>
      'Kruftle проверяет, пора ли выполнять очистку, пока он запущен, и сообщает при запуске, если какая-то была пропущена. Включите фоновые запуски ниже, чтобы это происходило без открытого Kruftle.';

  @override
  String get scheduleBackground => 'Запускать, даже когда Kruftle закрыт';

  @override
  String get scheduleBackgroundHelp =>
      'Регистрирует задание в собственном планировщике операционной системы, поэтому очистка выполняется в выбранное время независимо от того, открыт ли Kruftle. Она запускает команду очистки каждого набора инструментов и удаляет только те категории, которые вы заранее выбрали в настройках.';

  @override
  String get scheduleBackgroundActive =>
      'Зарегистрировано в планировщике системы.';

  @override
  String get scheduleBackgroundFailed =>
      'Система отказалась зарегистрировать фоновое задание. Напоминание по-прежнему работает, пока Kruftle открыт.';

  @override
  String get scheduleFrequency => 'Как часто';

  @override
  String get scheduleDaily => 'Ежедневно';

  @override
  String get scheduleWeekly => 'Еженедельно';

  @override
  String get scheduleMonthly => 'Ежемесячно';

  @override
  String get scheduleTimeOfDay => 'В';

  @override
  String get scheduleDayOfWeek => 'В день';

  @override
  String get scheduleDayOfMonth => 'Числа';

  @override
  String get scheduleFolder => 'Папка для поиска';

  @override
  String get scheduleChooseFolder => 'Выберите папку…';

  @override
  String scheduleNextRun(String when) {
    return 'Следующее напоминание $when.';
  }

  @override
  String get scheduleNeverRun => 'Очистка ещё ни разу не выполнялась.';

  @override
  String scheduleLastRun(String when) {
    return 'Последняя очистка $when.';
  }

  @override
  String get scheduleDueTitle => 'Пора провести очистку';

  @override
  String scheduleDueBody(int days, String folder) {
    return 'С последней очистки в $folder прошло $days дней.';
  }

  @override
  String get scheduleDueAction => 'Искать сейчас';

  @override
  String get scheduleDueDismiss => 'Позже';

  @override
  String get scheduleNotifyOnFinish => 'Уведомлять о завершении очистки';

  @override
  String get scheduleNotificationDueTitle => 'Kruftle — пора очистить';

  @override
  String scheduleNotificationDueBody(String folder) {
    return 'Пора убрать результаты сборки из $folder.';
  }

  @override
  String scheduleNotificationDoneTitle(String size) {
    return 'Kruftle — освобождено $size';
  }

  @override
  String scheduleNotificationDoneBody(int projects, String duration) {
    return 'Очищено $projects проектов за $duration.';
  }

  @override
  String get profilesTitle => 'Профили очистки';

  @override
  String get profilesIntro =>
      'Профиль обучает Kruftle типу проектов, которого он ещё не знает: какой файл его отмечает, какая команда его очищает и какие каталоги ему позволено удалять. Профили стоят рядом со встроенными технологиями и подчиняются ровно тем же правилам безопасности.';

  @override
  String get profilesNone => 'Своих профилей пока нет.';

  @override
  String get profilesNew => 'Новый профиль';

  @override
  String get profilesImport => 'Импорт…';

  @override
  String get profilesExport => 'Экспорт…';

  @override
  String get profilesName => 'Название';

  @override
  String get profilesNameHint => 'Unreal Engine';

  @override
  String get profilesMarkers => 'Файлы-признаки';

  @override
  String get profilesMarkersHint => '*.uproject';

  @override
  String get profilesMarkersHelp =>
      'Каталог, содержащий любой из них, считается проектом этого типа. По одному в строке. Точка со звёздочкой в начале означает совпадение по расширению.';

  @override
  String get profilesCommand => 'Команда очистки';

  @override
  String get profilesCommandHint => 'make clean';

  @override
  String get profilesCommandHelp =>
      'Выполняется с каталогом проекта в качестве рабочего. Оставьте пустым, чтобы только удалять каталоги, указанные ниже.';

  @override
  String get profilesArtifacts => 'Каталоги, которые можно удалять';

  @override
  String get profilesArtifactsHint => 'Binaries\nIntermediate';

  @override
  String get profilesArtifactsHelp =>
      'По одному в строке, относительно корня проекта. Это список разрешённого: ничего вне его никогда не удаляется, а удаление всё равно требует вашего подтверждения при каждом запуске.';

  @override
  String get profilesExcludes => 'Никогда не просматривать эти пути';

  @override
  String get profilesExcludesHint => '**/vendor/**';

  @override
  String get profilesExcludesHelp =>
      'Шаблоны glob. Совпавшие каталоги пропускаются целиком — всеми профилями и всеми встроенными технологиями.';

  @override
  String get profilesEnabled => 'Включён';

  @override
  String profilesDeleteConfirm(String name) {
    return 'Удалить профиль «$name»?';
  }

  @override
  String get profilesErrorName => 'Дайте профилю название.';

  @override
  String get profilesErrorMarkers =>
      'Профилю нужен хотя бы один файл-признак, иначе он совпадёт с любой папкой.';

  @override
  String get profilesErrorNothingToDo =>
      'Задайте профилю команду очистки, каталоги для удаления или и то и другое.';

  @override
  String profilesErrorAbsolutePath(String path) {
    return 'Каталоги должны задаваться относительно корня проекта: «$path» задан иначе.';
  }

  @override
  String profilesErrorEscapes(String path) {
    return '«$path» указывает за пределы проекта. Это никогда не допускается.';
  }

  @override
  String profilesErrorDuplicate(String name) {
    return 'Профиль с названием «$name» уже существует.';
  }

  @override
  String get profilesImportFailed =>
      'Этот файл не является экспортом профилей Kruftle.';

  @override
  String profilesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортировано $count профиля.',
      many: 'Импортировано $count профилей.',
      few: 'Импортировано $count профиля.',
      one: 'Импортирован $count профиль.',
    );
    return '$_temp0';
  }

  @override
  String get diskTitle => 'Использование диска';

  @override
  String get diskVolume => 'Том';

  @override
  String get diskUsed => 'занято';

  @override
  String get diskFree => 'свободно';

  @override
  String get diskReclaimable => 'можно освободить';

  @override
  String diskOfTotal(String used, String total) {
    return 'занято $used из $total';
  }

  @override
  String diskFreedThisRun(String size) {
    return 'освобождено $size';
  }

  @override
  String get diskTreemapEmpty => 'Пока ничего не измерено.';

  @override
  String get changelogTitle => 'Что нового';

  @override
  String changelogVersionHeading(String version) {
    return 'Версия $version';
  }

  @override
  String get changelogUnavailable => 'Не удалось прочитать список изменений.';

  @override
  String get changelogAdded => 'Добавлено';

  @override
  String get changelogChanged => 'Изменено';

  @override
  String get changelogFixed => 'Исправлено';

  @override
  String changelogWhatsNewBanner(String version) {
    return 'Kruftle обновлён до $version.';
  }

  @override
  String get changelogWhatsNewAction => 'Посмотреть, что изменилось';

  @override
  String get legalPrivacyTitle => 'Политика конфиденциальности';

  @override
  String get legalTermsTitle => 'Условия использования';

  @override
  String get legalUnavailable => 'Не удалось загрузить этот документ.';

  @override
  String get legalOpenInBrowser => 'Открыть в браузере';
}
