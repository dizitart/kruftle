// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'Reclaim your disk';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClose => 'Close';

  @override
  String get actionShow => 'Show';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionAll => 'All';

  @override
  String get actionAllMatching => 'All matching';

  @override
  String get actionNone => 'None';

  @override
  String get actionBack => 'Back';

  @override
  String get actionNext => 'Next';

  @override
  String get actionDone => 'Done';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionNotNow => 'Not now';

  @override
  String get titleBarGlobalCaches => 'Global SDK caches';

  @override
  String get titleBarSettings => 'Settings';

  @override
  String get titleBarDiskUsage => 'Disk usage';

  @override
  String get titleBarSchedule => 'Scheduled cleanups';

  @override
  String get titleBarProfiles => 'Cleanup profiles';

  @override
  String get titleBarChangelog => 'What\'s new';

  @override
  String get titleBarAbout => 'About Kruftle';

  @override
  String get railFolder => 'Folder';

  @override
  String get railScan => 'Scan';

  @override
  String get railReview => 'Review';

  @override
  String get railClean => 'Clean';

  @override
  String get railReport => 'Report';

  @override
  String get sourceHeading => 'Which directory should Kruftle look through?';

  @override
  String get sourceSubheading =>
      'Everything underneath it is examined. Nothing is touched until you say so.';

  @override
  String get sourceChooseFolder => 'Choose a folder';

  @override
  String get sourceChooseFolderHelp =>
      'Your codebase root, or any folder holding projects';

  @override
  String get sourceConfirmButton => 'Scan this folder';

  @override
  String get sourceRecent => 'Recent';

  @override
  String get sourceForget => 'Remove from recents';

  @override
  String get scanningLooking => 'Looking for projects';

  @override
  String get scanningMeasuring => 'Measuring what they hold';

  @override
  String get scanningProjectsFound => 'projects found';

  @override
  String get scanningDirectoriesWalked => 'directories walked';

  @override
  String get scanningMeasured => 'measured';

  @override
  String get scanningNothingYet => 'Nothing found yet.';

  @override
  String get scanningStop => 'Stop scanning';

  @override
  String get reviewScanAgain => 'Scan again';

  @override
  String get reviewChangeFolder => 'Change folder';

  @override
  String reviewProjectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projects',
      one: '1 project',
    );
    return '$_temp0';
  }

  @override
  String get reviewFilterHint => 'Filter by name, path or stack   ( / )';

  @override
  String get reviewSortedBySize => 'Sorted by size';

  @override
  String get reviewSortedByPath => 'Sorted by path';

  @override
  String get reviewNoProjects =>
      'No projects with build output under this folder.';

  @override
  String reviewNoMatches(String query) {
    return 'Nothing matches \"$query\".';
  }

  @override
  String reviewInSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count selected projects',
      one: 'in 1 selected project',
    );
    return '$_temp0';
  }

  @override
  String get reviewMeasuredByDryRun => 'measured by the dry run';

  @override
  String reviewStillMeasuring(int percent) {
    return 'still measuring — $percent%';
  }

  @override
  String reviewFoundInTotal(String size, int count) {
    return '$size found in total across $count projects.';
  }

  @override
  String reviewPlanSummary(int steps, int projects) {
    return '$steps steps across $projects projects.';
  }

  @override
  String get reviewAlsoDelete => 'Also delete outright';

  @override
  String get reviewAlsoDeleteHelp =>
      'Kruftle prefers each toolchain’s own clean command. These categories are removed by deleting the directory, so they are off unless you say otherwise.';

  @override
  String get reviewRiskBuildOutput => 'Build output when the SDK is missing';

  @override
  String get reviewRiskBuildOutputHelp =>
      'For projects whose toolchain is not installed, delete the known output directory instead. Rebuilding restores it.';

  @override
  String get reviewRiskDependencies => 'Downloaded dependencies';

  @override
  String get reviewRiskDependenciesHelp =>
      'node_modules, .venv, deps. Restored from the lockfile, but that costs a download.';

  @override
  String get reviewRiskCache => 'Tool caches';

  @override
  String get reviewRiskCacheHelp =>
      '.gradle, .turbo, .mypy_cache and friends. Only cost is a slower next build.';

  @override
  String get reviewMissingToolchains =>
      'Some selected projects have no SDK installed. Without the first option above, they will be skipped.';

  @override
  String reviewGitTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artifact directories are',
      one: '1 artifact directory is',
    );
    return '$_temp0 tracked by git and will be left alone. Deleting committed content is not something a rebuild can undo.';
  }

  @override
  String get reviewDryRun => 'Dry run';

  @override
  String get reviewRemeasure => 'Re-measure';

  @override
  String get reviewCleanNow => 'Clean now';

  @override
  String get reviewDryRunNote => 'A dry run changes nothing. You can skip it.';

  @override
  String get reviewLargestDirectories => 'Where the space is';

  @override
  String get reviewLargestDirectoriesHelp =>
      'The biggest artifact directories under this folder. Hover a block for its path.';

  @override
  String get confirmDeleteTitle => 'Delete these directories?';

  @override
  String get confirmDeleteIntro =>
      'Alongside running each toolchain’s clean command, Kruftle will delete:';

  @override
  String get confirmCategoryBuildOutput =>
      'build output directories where the SDK is missing';

  @override
  String get confirmCategoryDependencies => 'downloaded dependency directories';

  @override
  String get confirmCategoryCache => 'tool cache directories';

  @override
  String confirmDeleteScope(int count, String folder) {
    return 'Across $count selected projects under $folder. Everything here is regenerable, and anything git tracks is skipped.';
  }

  @override
  String get confirmDeleteAccept => 'Delete and clean';

  @override
  String get runningHeading => 'Cleaning';

  @override
  String runningProgress(int done, int total) {
    return '$done of $total steps';
  }

  @override
  String get runningStop => 'Stop';

  @override
  String get reportStopped => 'Stopped';

  @override
  String get reportDone => 'Done';

  @override
  String reportRanFor(String duration, int projects) {
    return 'Ran for $duration across $projects projects.';
  }

  @override
  String get reportReclaimed => 'reclaimed';

  @override
  String get reportStepsCompleted => 'steps completed';

  @override
  String get reportFailed => 'failed';

  @override
  String get reportNothingToDo => 'nothing to do';

  @override
  String get reportRefused => 'refused';

  @override
  String reportUnderEstimate(String estimate) {
    return 'The dry run estimated $estimate. Clean commands decide for themselves what to remove — some keep caches a rebuild can reuse, which is usually what you want.';
  }

  @override
  String reportRefusedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count targets were',
      one: '1 target was',
    );
    return '$_temp0 refused by a safety check and left untouched.';
  }

  @override
  String get reportWhatWentWrong => 'What went wrong';

  @override
  String get reportNoDetail => 'No detail reported.';

  @override
  String get reportScanAgain => 'Scan again';

  @override
  String get reportAnotherFolder => 'Another folder';

  @override
  String get reportExportLog => 'Export log';

  @override
  String reportLogExported(String name) {
    return 'Log exported to $name';
  }

  @override
  String get reportDiskBefore => 'before';

  @override
  String get reportDiskAfter => 'after';

  @override
  String reportDiskHeading(String volume, String free, String total) {
    return '$volume — $free free of $total';
  }

  @override
  String get reportDiskUnavailable =>
      'This volume does not report its free space.';

  @override
  String toolAvailable(String binary, String stack) {
    return '$binary is installed — $stack projects will be cleaned with their own command.';
  }

  @override
  String toolMissing(String binary) {
    return '$binary is not on PATH. Kruftle can only clean this by deleting the build directory, which needs your explicit permission.';
  }

  @override
  String toolNotApplicable(String stack) {
    return '$stack has no official clean command.';
  }

  @override
  String get cachesTitle => 'Global caches';

  @override
  String get cachesRemeasure => 'Re-measure';

  @override
  String get cachesSortTooltip => 'Sort by size';

  @override
  String get cachesSortLargest => 'Largest first';

  @override
  String get cachesSortSmallest => 'Smallest first';

  @override
  String get cachesIntro =>
      'These caches are shared by every project on this machine. Emptying one frees space now and costs a re-download later — it never loses work.';

  @override
  String cachesFreed(String size, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caches',
      one: '1 cache',
    );
    return 'Freed $size from $_temp0.';
  }

  @override
  String get cachesNoneFound =>
      'No global caches found in your home directory.';

  @override
  String get cachesSelected => 'selected';

  @override
  String get cachesEmptySelected => 'Empty selected';

  @override
  String get cachesEmptying => 'Emptying…';

  @override
  String get cachesConfirmTitle => 'Empty these caches?';

  @override
  String cachesConfirmBody(String size) {
    return 'These are shared by every project on this machine, not just the one you last scanned. Emptying them frees $size now and costs a re-download the next time any project needs them.';
  }

  @override
  String get cachesConfirmAccept => 'Empty them';

  @override
  String get cachesUsesCommand =>
      'Emptied with the toolchain’s own command rather than by deleting files.';

  @override
  String get cachesUsesDelete =>
      'No official command for this cache, so the directory is removed.';

  @override
  String get cachesDeleteTag => 'delete';

  @override
  String updateAvailable(String version, String size) {
    return 'Kruftle $version is available ($size).';
  }

  @override
  String updateDownloading(String version, int percent) {
    return 'Downloading $version… $percent%';
  }

  @override
  String updateReady(String version) {
    return 'Kruftle $version is verified and ready. The installer has been opened.';
  }

  @override
  String get updateFailed => 'The update failed.';

  @override
  String get updateAction => 'Update';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'Match the system';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'Match the system';

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsReduceMotionHelp =>
      'Replace the sweeping and pulsing animations with plain progress. Also honoured automatically when the operating system asks for reduced motion.';

  @override
  String get settingsSectionScanning => 'Scanning';

  @override
  String get settingsMaxDepth => 'Maximum depth';

  @override
  String get settingsMaxDepthHelp =>
      'How far below the chosen folder to look. Deeper finds more nested projects and takes longer.';

  @override
  String settingsLevels(int count) {
    return '$count levels';
  }

  @override
  String get settingsHiddenDirectories => 'Include hidden directories';

  @override
  String get settingsHiddenDirectoriesHelp =>
      'Folders beginning with a dot. Usually editor state and tool caches rather than projects.';

  @override
  String get settingsSectionCleaning => 'Cleaning';

  @override
  String get settingsConcurrency => 'Projects at once';

  @override
  String settingsConcurrencyHelp(int cores) {
    return 'Clean commands that run in parallel. More is faster until the disk becomes the bottleneck. $cores cores available.';
  }

  @override
  String get settingsTimeout => 'Step timeout';

  @override
  String get settingsTimeoutHelp =>
      'A clean command that runs longer than this is killed and reported, so one stuck build tool cannot hold up the whole run.';

  @override
  String settingsSeconds(int count) {
    return '$count seconds';
  }

  @override
  String settingsMinutes(int count) {
    return '$count minutes';
  }

  @override
  String get settingsConfirmBeforeDelete => 'Confirm before deleting';

  @override
  String get settingsConfirmBeforeDeleteHelp =>
      'Show a summary dialog whenever a run will delete directories outright rather than only running clean commands.';

  @override
  String get settingsSectionPreselect => 'Pre-select these deletion categories';

  @override
  String get settingsPreselectHelp =>
      'A convenience only. Every run still shows them ticked and still asks before deleting anything.';

  @override
  String get settingsSectionLogging => 'Logging';

  @override
  String get settingsLogDetail => 'Detail';

  @override
  String get settingsLogDebug => 'Debug';

  @override
  String get settingsLogInfo => 'Info';

  @override
  String get settingsLogWarning => 'Warning';

  @override
  String get settingsLogError => 'Error';

  @override
  String get settingsLogRetention => 'Log files kept';

  @override
  String get settingsLogRetentionHelp =>
      'Older files are removed once the active log is rotated.';

  @override
  String get settingsNone => 'none';

  @override
  String get settingsSectionUpdates => 'Updates';

  @override
  String get settingsCheckUpdates => 'Check for updates automatically';

  @override
  String get settingsCheckUpdatesHelp =>
      'Kruftle asks GitHub Releases on launch and offers a verified download. It never installs without asking.';

  @override
  String get settingsSectionSizes => 'Sizes';

  @override
  String get settingsSizeMode => 'How sizes are counted';

  @override
  String get settingsSizeModeOnDisk => 'Space actually used on disk';

  @override
  String get settingsSizeModeApparent => 'Total length of the files';

  @override
  String get settingsSizeModeHelp =>
      'On-disk matches what the operating system reports and what you get back, including block rounding and filesystem compression. It needs a native call that is unavailable on Windows, which falls back to file lengths.';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsShowTour => 'Show the feature tour again';

  @override
  String get settingsChangelog => 'What\'s new in this version';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsLicence =>
      'Free software under the GNU General Public License v3.0 or later.';

  @override
  String get settingsMadeWith => 'Made with ❤️ in Kolkata, India';

  @override
  String get settingsSourceCode => 'Source code';

  @override
  String get tourWelcomeTitle => 'Welcome to Kruftle';

  @override
  String get tourWelcomeBody =>
      'Build artifacts pile up quietly. Kruftle finds every project on your disk, works out what built it, and asks that toolchain to clean up after itself.';

  @override
  String get tourWelcomeStart => 'Show me around';

  @override
  String get tourWelcomeSkip => 'Skip the tour';

  @override
  String get tourScanTitle => 'Point it at a folder';

  @override
  String get tourScanBody =>
      'Choose your codebase root. Kruftle walks everything underneath, recognising more than forty languages and build tools from the files they leave behind — including projects nested inside other projects.';

  @override
  String get tourReviewTitle => 'See what it found before anything happens';

  @override
  String get tourReviewBody =>
      'Every project, every artifact directory, and what each one costs you — measured, not guessed. Tick what you want cleaned. Nothing is touched until you say so.';

  @override
  String get tourSafetyTitle => 'Safety is not optional';

  @override
  String get tourSafetyBody =>
      'Kruftle prefers each toolchain\'s own clean command over deleting files. Raw deletion is allow-listed by directory name, never follows a symlink, refuses to leave the folder you chose, and always asks first. Anything git tracks is left alone.';

  @override
  String get tourCachesTitle => 'The caches in your home directory too';

  @override
  String get tourCachesBody =>
      'Cargo\'s registry, Gradle\'s caches, the npm and pub caches — shared by every project and often the biggest win on the disk. They get their own screen and their own confirmation.';

  @override
  String get tourScheduleTitle => 'Set it and forget it';

  @override
  String get tourScheduleBody =>
      'Have Kruftle clean daily, weekly or monthly. It can nudge you while it is open, or register with your operating system\'s own scheduler and do the run with Kruftle closed.';

  @override
  String get tourFinishTitle => 'That\'s the whole app';

  @override
  String get tourFinishBody =>
      'Everything runs on your machine. Nothing is uploaded, and there is no account to make.';

  @override
  String get tourFinishAction => 'Get started';

  @override
  String get scheduleTitle => 'Scheduled cleanups';

  @override
  String get scheduleEnable => 'Remind me to clean up';

  @override
  String get scheduleEnableHelp =>
      'Kruftle checks whether a cleanup is due while it is running, and tells you at launch if one was missed. Turn on background runs below to have it happen without Kruftle open.';

  @override
  String get scheduleBackground => 'Run even when Kruftle is closed';

  @override
  String get scheduleBackgroundHelp =>
      'Registers a job with your operating system’s own scheduler, so a cleanup runs at the chosen time whether or not Kruftle is open. It runs each toolchain’s clean command and deletes only the categories you pre-selected in Settings.';

  @override
  String get scheduleBackgroundActive =>
      'Registered with the system scheduler.';

  @override
  String get scheduleBackgroundFailed =>
      'Your system refused to register the background job. The reminder still works while Kruftle is open.';

  @override
  String get scheduleFrequency => 'How often';

  @override
  String get scheduleDaily => 'Daily';

  @override
  String get scheduleWeekly => 'Weekly';

  @override
  String get scheduleMonthly => 'Monthly';

  @override
  String get scheduleTimeOfDay => 'At';

  @override
  String get scheduleDayOfWeek => 'On';

  @override
  String get scheduleDayOfMonth => 'On day';

  @override
  String get scheduleFolder => 'Folder to scan';

  @override
  String get scheduleChooseFolder => 'Choose a folder…';

  @override
  String scheduleNextRun(String when) {
    return 'Next reminder $when.';
  }

  @override
  String get scheduleNeverRun => 'No cleanup has run yet.';

  @override
  String scheduleLastRun(String when) {
    return 'Last cleanup $when.';
  }

  @override
  String get scheduleDueTitle => 'A cleanup is due';

  @override
  String scheduleDueBody(int days, String folder) {
    return 'It has been $days days since the last one under $folder.';
  }

  @override
  String get scheduleDueAction => 'Scan now';

  @override
  String get scheduleDueDismiss => 'Later';

  @override
  String get scheduleNotifyOnFinish => 'Notify me when a cleanup finishes';

  @override
  String get scheduleNotificationDueTitle => 'Kruftle — cleanup due';

  @override
  String scheduleNotificationDueBody(String folder) {
    return 'It is time to clear build artifacts out of $folder.';
  }

  @override
  String scheduleNotificationDoneTitle(String size) {
    return 'Kruftle — $size reclaimed';
  }

  @override
  String scheduleNotificationDoneBody(int projects, String duration) {
    return 'Cleaned $projects projects in $duration.';
  }

  @override
  String get profilesTitle => 'Cleanup profiles';

  @override
  String get profilesIntro =>
      'A profile teaches Kruftle a project type it does not know yet: which file marks it, what command cleans it, and which directories it may remove. Profiles sit alongside the built-in stacks and obey exactly the same safety rules.';

  @override
  String get profilesNone => 'No custom profiles yet.';

  @override
  String get profilesNew => 'New profile';

  @override
  String get profilesImport => 'Import…';

  @override
  String get profilesExport => 'Export…';

  @override
  String get profilesName => 'Name';

  @override
  String get profilesNameHint => 'Unreal Engine';

  @override
  String get profilesMarkers => 'Marker files';

  @override
  String get profilesMarkersHint => '*.uproject';

  @override
  String get profilesMarkersHelp =>
      'A directory containing any of these is treated as this kind of project. One per line. A leading dot-star matches by extension.';

  @override
  String get profilesCommand => 'Clean command';

  @override
  String get profilesCommandHint => 'make clean';

  @override
  String get profilesCommandHelp =>
      'Run with the project directory as its working directory. Leave empty to only delete the directories below.';

  @override
  String get profilesArtifacts => 'Directories it may remove';

  @override
  String get profilesArtifactsHint => 'Binaries\nIntermediate';

  @override
  String get profilesArtifactsHelp =>
      'One per line, relative to the project root. This is an allow-list: nothing outside it is ever deleted, and deletion still needs your per-run confirmation.';

  @override
  String get profilesExcludes => 'Never scan these paths';

  @override
  String get profilesExcludesHint => '**/vendor/**';

  @override
  String get profilesExcludesHelp =>
      'Glob patterns. Matching directories are skipped entirely, by every profile and every built-in stack.';

  @override
  String get profilesEnabled => 'Enabled';

  @override
  String profilesDeleteConfirm(String name) {
    return 'Delete the profile “$name”?';
  }

  @override
  String get profilesErrorName => 'Give the profile a name.';

  @override
  String get profilesErrorMarkers =>
      'A profile needs at least one marker file, or it would match every folder.';

  @override
  String get profilesErrorNothingToDo =>
      'Give the profile a clean command, some directories to remove, or both.';

  @override
  String profilesErrorAbsolutePath(String path) {
    return 'Directories must be relative to the project root: “$path” is not.';
  }

  @override
  String profilesErrorEscapes(String path) {
    return '“$path” points outside the project. That is never allowed.';
  }

  @override
  String profilesErrorDuplicate(String name) {
    return 'A profile called “$name” already exists.';
  }

  @override
  String get profilesImportFailed =>
      'That file is not a Kruftle profile export.';

  @override
  String profilesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count profiles.',
      one: 'Imported 1 profile.',
    );
    return '$_temp0';
  }

  @override
  String get diskTitle => 'Disk usage';

  @override
  String get diskVolume => 'Volume';

  @override
  String get diskUsed => 'used';

  @override
  String get diskFree => 'free';

  @override
  String get diskReclaimable => 'reclaimable';

  @override
  String diskOfTotal(String used, String total) {
    return '$used of $total used';
  }

  @override
  String diskFreedThisRun(String size) {
    return '$size freed';
  }

  @override
  String get diskTreemapEmpty => 'Nothing measured yet.';

  @override
  String get changelogTitle => 'What\'s new';

  @override
  String changelogVersionHeading(String version) {
    return 'Version $version';
  }

  @override
  String get changelogUnavailable => 'The changelog could not be read.';

  @override
  String get changelogAdded => 'Added';

  @override
  String get changelogChanged => 'Changed';

  @override
  String get changelogFixed => 'Fixed';

  @override
  String changelogWhatsNewBanner(String version) {
    return 'Kruftle has been updated to $version.';
  }

  @override
  String get changelogWhatsNewAction => 'See what changed';

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get legalTermsTitle => 'Terms of Service';

  @override
  String get legalUnavailable => 'This document could not be loaded.';

  @override
  String get legalOpenInBrowser => 'Open in browser';

  @override
  String get consentTitle => 'Terms & Privacy';

  @override
  String get consentBody =>
      'Kruftle runs each toolchain\'s own clean command, and that deletes build output from this machine. Read the Terms of Service and the Privacy Policy before you start — continuing means you accept both.';

  @override
  String get consentAccept => 'Accept and continue';

  @override
  String get consentDecline => 'Decline and quit';
}
