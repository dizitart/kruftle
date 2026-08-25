import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
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
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// Subtitle next to the product name in the title bar
  ///
  /// In en, this message translates to:
  /// **'Reclaim your disk'**
  String get appTagline;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get actionShow;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get actionAll;

  /// No description provided for @actionAllMatching.
  ///
  /// In en, this message translates to:
  /// **'All matching'**
  String get actionAllMatching;

  /// No description provided for @actionNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get actionNone;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get actionNotNow;

  /// Heading of the window shown when a second Kruftle is launched
  ///
  /// In en, this message translates to:
  /// **'Kruftle is already open'**
  String get alreadyRunningTitle;

  /// No description provided for @alreadyRunningBody.
  ///
  /// In en, this message translates to:
  /// **'Another Kruftle window is running. Two of them cleaning at once could leave a build directory half removed, so this one will not open.'**
  String get alreadyRunningBody;

  /// No description provided for @titleBarGlobalCaches.
  ///
  /// In en, this message translates to:
  /// **'Global SDK caches'**
  String get titleBarGlobalCaches;

  /// No description provided for @titleBarSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get titleBarSettings;

  /// No description provided for @titleBarDiskUsage.
  ///
  /// In en, this message translates to:
  /// **'Disk usage'**
  String get titleBarDiskUsage;

  /// No description provided for @titleBarSchedule.
  ///
  /// In en, this message translates to:
  /// **'Scheduled cleanups'**
  String get titleBarSchedule;

  /// No description provided for @titleBarProfiles.
  ///
  /// In en, this message translates to:
  /// **'Cleanup profiles'**
  String get titleBarProfiles;

  /// No description provided for @titleBarChangelog.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get titleBarChangelog;

  /// No description provided for @titleBarAbout.
  ///
  /// In en, this message translates to:
  /// **'About Kruftle'**
  String get titleBarAbout;

  /// No description provided for @railFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get railFolder;

  /// No description provided for @railScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get railScan;

  /// No description provided for @railReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get railReview;

  /// No description provided for @railClean.
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get railClean;

  /// No description provided for @railReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get railReport;

  /// No description provided for @sourceHeading.
  ///
  /// In en, this message translates to:
  /// **'Which directory should Kruftle look through?'**
  String get sourceHeading;

  /// No description provided for @sourceSubheading.
  ///
  /// In en, this message translates to:
  /// **'Everything underneath it is examined. Nothing is touched until you say so.'**
  String get sourceSubheading;

  /// No description provided for @sourceChooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose a folder'**
  String get sourceChooseFolder;

  /// No description provided for @sourceChooseFolderHelp.
  ///
  /// In en, this message translates to:
  /// **'Your codebase root, or any folder holding projects'**
  String get sourceChooseFolderHelp;

  /// No description provided for @sourceConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Scan this folder'**
  String get sourceConfirmButton;

  /// No description provided for @sourceRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get sourceRecent;

  /// No description provided for @sourceForget.
  ///
  /// In en, this message translates to:
  /// **'Remove from recents'**
  String get sourceForget;

  /// No description provided for @scanningLooking.
  ///
  /// In en, this message translates to:
  /// **'Looking for projects'**
  String get scanningLooking;

  /// No description provided for @scanningMeasuring.
  ///
  /// In en, this message translates to:
  /// **'Measuring what they hold'**
  String get scanningMeasuring;

  /// No description provided for @scanningProjectsFound.
  ///
  /// In en, this message translates to:
  /// **'projects found'**
  String get scanningProjectsFound;

  /// No description provided for @scanningDirectoriesWalked.
  ///
  /// In en, this message translates to:
  /// **'directories walked'**
  String get scanningDirectoriesWalked;

  /// No description provided for @scanningMeasured.
  ///
  /// In en, this message translates to:
  /// **'measured'**
  String get scanningMeasured;

  /// No description provided for @scanningNothingYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing found yet.'**
  String get scanningNothingYet;

  /// No description provided for @scanningStop.
  ///
  /// In en, this message translates to:
  /// **'Stop scanning'**
  String get scanningStop;

  /// No description provided for @reviewScanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get reviewScanAgain;

  /// No description provided for @reviewChangeFolder.
  ///
  /// In en, this message translates to:
  /// **'Change folder'**
  String get reviewChangeFolder;

  /// No description provided for @reviewProjectCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 project} other{{count} projects}}'**
  String reviewProjectCount(int count);

  /// No description provided for @reviewFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Filter by name, path or stack   ( / )'**
  String get reviewFilterHint;

  /// No description provided for @reviewSortedBySize.
  ///
  /// In en, this message translates to:
  /// **'Sorted by size'**
  String get reviewSortedBySize;

  /// No description provided for @reviewSortedByPath.
  ///
  /// In en, this message translates to:
  /// **'Sorted by path'**
  String get reviewSortedByPath;

  /// No description provided for @reviewNoProjects.
  ///
  /// In en, this message translates to:
  /// **'No projects with build output under this folder.'**
  String get reviewNoProjects;

  /// No description provided for @reviewNoMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches \"{query}\".'**
  String reviewNoMatches(String query);

  /// No description provided for @reviewInSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{in 1 selected project} other{in {count} selected projects}}'**
  String reviewInSelected(int count);

  /// No description provided for @reviewMeasuredByDryRun.
  ///
  /// In en, this message translates to:
  /// **'measured by the dry run'**
  String get reviewMeasuredByDryRun;

  /// No description provided for @reviewStillMeasuring.
  ///
  /// In en, this message translates to:
  /// **'still measuring — {percent}%'**
  String reviewStillMeasuring(int percent);

  /// No description provided for @reviewFoundInTotal.
  ///
  /// In en, this message translates to:
  /// **'{size} found in total across {count} projects.'**
  String reviewFoundInTotal(String size, int count);

  /// No description provided for @reviewPlanSummary.
  ///
  /// In en, this message translates to:
  /// **'{steps} steps across {projects} projects.'**
  String reviewPlanSummary(int steps, int projects);

  /// No description provided for @reviewAlsoDelete.
  ///
  /// In en, this message translates to:
  /// **'Also delete outright'**
  String get reviewAlsoDelete;

  /// No description provided for @reviewAlsoDeleteHelp.
  ///
  /// In en, this message translates to:
  /// **'Kruftle prefers each toolchain’s own clean command. These categories are removed by deleting the directory, so they are off unless you say otherwise.'**
  String get reviewAlsoDeleteHelp;

  /// No description provided for @reviewRiskBuildOutput.
  ///
  /// In en, this message translates to:
  /// **'Build output when the SDK is missing'**
  String get reviewRiskBuildOutput;

  /// No description provided for @reviewRiskBuildOutputHelp.
  ///
  /// In en, this message translates to:
  /// **'For projects whose toolchain is not installed, delete the known output directory instead. Rebuilding restores it.'**
  String get reviewRiskBuildOutputHelp;

  /// No description provided for @reviewRiskDependencies.
  ///
  /// In en, this message translates to:
  /// **'Downloaded dependencies'**
  String get reviewRiskDependencies;

  /// No description provided for @reviewRiskDependenciesHelp.
  ///
  /// In en, this message translates to:
  /// **'node_modules, .venv, deps. Restored from the lockfile, but that costs a download.'**
  String get reviewRiskDependenciesHelp;

  /// No description provided for @reviewRiskCache.
  ///
  /// In en, this message translates to:
  /// **'Tool caches'**
  String get reviewRiskCache;

  /// No description provided for @reviewRiskCacheHelp.
  ///
  /// In en, this message translates to:
  /// **'.gradle, .turbo, .mypy_cache and friends. Only cost is a slower next build.'**
  String get reviewRiskCacheHelp;

  /// No description provided for @reviewMissingToolchains.
  ///
  /// In en, this message translates to:
  /// **'Some selected projects have no SDK installed. Without the first option above, they will be skipped.'**
  String get reviewMissingToolchains;

  /// No description provided for @reviewGitTracked.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 artifact directory is} other{{count} artifact directories are}} tracked by git and will be left alone. Deleting committed content is not something a rebuild can undo.'**
  String reviewGitTracked(int count);

  /// No description provided for @reviewDryRun.
  ///
  /// In en, this message translates to:
  /// **'Dry run'**
  String get reviewDryRun;

  /// No description provided for @reviewRemeasure.
  ///
  /// In en, this message translates to:
  /// **'Re-measure'**
  String get reviewRemeasure;

  /// No description provided for @reviewCleanNow.
  ///
  /// In en, this message translates to:
  /// **'Clean now'**
  String get reviewCleanNow;

  /// No description provided for @reviewDryRunNote.
  ///
  /// In en, this message translates to:
  /// **'A dry run changes nothing. You can skip it.'**
  String get reviewDryRunNote;

  /// No description provided for @reviewLargestDirectories.
  ///
  /// In en, this message translates to:
  /// **'Where the space is'**
  String get reviewLargestDirectories;

  /// No description provided for @reviewLargestDirectoriesHelp.
  ///
  /// In en, this message translates to:
  /// **'The biggest artifact directories under this folder. Hover a block for its path.'**
  String get reviewLargestDirectoriesHelp;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete these directories?'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteIntro.
  ///
  /// In en, this message translates to:
  /// **'Alongside running each toolchain’s clean command, Kruftle will delete:'**
  String get confirmDeleteIntro;

  /// No description provided for @confirmCategoryBuildOutput.
  ///
  /// In en, this message translates to:
  /// **'build output directories where the SDK is missing'**
  String get confirmCategoryBuildOutput;

  /// No description provided for @confirmCategoryDependencies.
  ///
  /// In en, this message translates to:
  /// **'downloaded dependency directories'**
  String get confirmCategoryDependencies;

  /// No description provided for @confirmCategoryCache.
  ///
  /// In en, this message translates to:
  /// **'tool cache directories'**
  String get confirmCategoryCache;

  /// No description provided for @confirmDeleteScope.
  ///
  /// In en, this message translates to:
  /// **'Across {count} selected projects under {folder}. Everything here is regenerable, and anything git tracks is skipped.'**
  String confirmDeleteScope(int count, String folder);

  /// No description provided for @confirmDeleteAccept.
  ///
  /// In en, this message translates to:
  /// **'Delete and clean'**
  String get confirmDeleteAccept;

  /// No description provided for @runningHeading.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get runningHeading;

  /// No description provided for @runningProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} steps'**
  String runningProgress(int done, int total);

  /// No description provided for @runningStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get runningStop;

  /// No description provided for @reportStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get reportStopped;

  /// No description provided for @reportDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get reportDone;

  /// No description provided for @reportRanFor.
  ///
  /// In en, this message translates to:
  /// **'Ran for {duration} across {projects} projects.'**
  String reportRanFor(String duration, int projects);

  /// No description provided for @reportReclaimed.
  ///
  /// In en, this message translates to:
  /// **'reclaimed'**
  String get reportReclaimed;

  /// No description provided for @reportStepsCompleted.
  ///
  /// In en, this message translates to:
  /// **'steps completed'**
  String get reportStepsCompleted;

  /// No description provided for @reportFailed.
  ///
  /// In en, this message translates to:
  /// **'failed'**
  String get reportFailed;

  /// No description provided for @reportNothingToDo.
  ///
  /// In en, this message translates to:
  /// **'nothing to do'**
  String get reportNothingToDo;

  /// No description provided for @reportRefused.
  ///
  /// In en, this message translates to:
  /// **'refused'**
  String get reportRefused;

  /// No description provided for @reportUnderEstimate.
  ///
  /// In en, this message translates to:
  /// **'The dry run estimated {estimate}. Clean commands decide for themselves what to remove — some keep caches a rebuild can reuse, which is usually what you want.'**
  String reportUnderEstimate(String estimate);

  /// No description provided for @reportRefusedNotice.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 target was} other{{count} targets were}} refused by a safety check and left untouched.'**
  String reportRefusedNotice(int count);

  /// No description provided for @reportWhatWentWrong.
  ///
  /// In en, this message translates to:
  /// **'What went wrong'**
  String get reportWhatWentWrong;

  /// No description provided for @reportNoDetail.
  ///
  /// In en, this message translates to:
  /// **'No detail reported.'**
  String get reportNoDetail;

  /// No description provided for @reportScanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get reportScanAgain;

  /// No description provided for @reportAnotherFolder.
  ///
  /// In en, this message translates to:
  /// **'Another folder'**
  String get reportAnotherFolder;

  /// No description provided for @reportExportLog.
  ///
  /// In en, this message translates to:
  /// **'Export log'**
  String get reportExportLog;

  /// No description provided for @reportLogExported.
  ///
  /// In en, this message translates to:
  /// **'Log exported to {name}'**
  String reportLogExported(String name);

  /// No description provided for @reportDiskBefore.
  ///
  /// In en, this message translates to:
  /// **'before'**
  String get reportDiskBefore;

  /// No description provided for @reportDiskAfter.
  ///
  /// In en, this message translates to:
  /// **'after'**
  String get reportDiskAfter;

  /// No description provided for @reportDiskHeading.
  ///
  /// In en, this message translates to:
  /// **'{volume} — {free} free of {total}'**
  String reportDiskHeading(String volume, String free, String total);

  /// No description provided for @reportDiskUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This volume does not report its free space.'**
  String get reportDiskUnavailable;

  /// No description provided for @toolAvailable.
  ///
  /// In en, this message translates to:
  /// **'{binary} is installed — {stack} projects will be cleaned with their own command.'**
  String toolAvailable(String binary, String stack);

  /// No description provided for @toolMissing.
  ///
  /// In en, this message translates to:
  /// **'{binary} is not on PATH. Kruftle can only clean this by deleting the build directory, which needs your explicit permission.'**
  String toolMissing(String binary);

  /// No description provided for @toolNotApplicable.
  ///
  /// In en, this message translates to:
  /// **'{stack} has no official clean command.'**
  String toolNotApplicable(String stack);

  /// No description provided for @cachesTitle.
  ///
  /// In en, this message translates to:
  /// **'Global caches'**
  String get cachesTitle;

  /// No description provided for @cachesRemeasure.
  ///
  /// In en, this message translates to:
  /// **'Re-measure'**
  String get cachesRemeasure;

  /// No description provided for @cachesSortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort by size'**
  String get cachesSortTooltip;

  /// No description provided for @cachesSortLargest.
  ///
  /// In en, this message translates to:
  /// **'Largest first'**
  String get cachesSortLargest;

  /// No description provided for @cachesSortSmallest.
  ///
  /// In en, this message translates to:
  /// **'Smallest first'**
  String get cachesSortSmallest;

  /// No description provided for @cachesIntro.
  ///
  /// In en, this message translates to:
  /// **'These caches are shared by every project on this machine. Emptying one frees space now and costs a re-download later — it never loses work.'**
  String get cachesIntro;

  /// No description provided for @cachesFreed.
  ///
  /// In en, this message translates to:
  /// **'Freed {size} from {count, plural, =1{1 cache} other{{count} caches}}.'**
  String cachesFreed(String size, int count);

  /// No description provided for @cachesNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No global caches found in your home directory.'**
  String get cachesNoneFound;

  /// No description provided for @cachesSelected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get cachesSelected;

  /// No description provided for @cachesEmptySelected.
  ///
  /// In en, this message translates to:
  /// **'Empty selected'**
  String get cachesEmptySelected;

  /// No description provided for @cachesEmptying.
  ///
  /// In en, this message translates to:
  /// **'Emptying…'**
  String get cachesEmptying;

  /// No description provided for @cachesConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Empty these caches?'**
  String get cachesConfirmTitle;

  /// No description provided for @cachesConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'These are shared by every project on this machine, not just the one you last scanned. Emptying them frees {size} now and costs a re-download the next time any project needs them.'**
  String cachesConfirmBody(String size);

  /// No description provided for @cachesConfirmAccept.
  ///
  /// In en, this message translates to:
  /// **'Empty them'**
  String get cachesConfirmAccept;

  /// No description provided for @cachesUsesCommand.
  ///
  /// In en, this message translates to:
  /// **'Emptied with the toolchain’s own command rather than by deleting files.'**
  String get cachesUsesCommand;

  /// No description provided for @cachesUsesDelete.
  ///
  /// In en, this message translates to:
  /// **'No official command for this cache, so the directory is removed.'**
  String get cachesUsesDelete;

  /// No description provided for @cachesDeleteTag.
  ///
  /// In en, this message translates to:
  /// **'delete'**
  String get cachesDeleteTag;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Kruftle {version} is available ({size}).'**
  String updateAvailable(String version, String size);

  /// No description provided for @updateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading {version}… {percent}%'**
  String updateDownloading(String version, int percent);

  /// No description provided for @updateReady.
  ///
  /// In en, this message translates to:
  /// **'Kruftle {version} is verified. Installing it now…'**
  String updateReady(String version);

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'The update failed.'**
  String get updateFailed;

  /// No description provided for @updateAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateAction;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'Match the system'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'Match the system'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settingsReduceMotion;

  /// No description provided for @settingsReduceMotionHelp.
  ///
  /// In en, this message translates to:
  /// **'Replace the sweeping and pulsing animations with plain progress. Also honoured automatically when the operating system asks for reduced motion.'**
  String get settingsReduceMotionHelp;

  /// No description provided for @settingsSectionScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get settingsSectionScanning;

  /// No description provided for @settingsMaxDepth.
  ///
  /// In en, this message translates to:
  /// **'Maximum depth'**
  String get settingsMaxDepth;

  /// No description provided for @settingsMaxDepthHelp.
  ///
  /// In en, this message translates to:
  /// **'How far below the chosen folder to look. Deeper finds more nested projects and takes longer.'**
  String get settingsMaxDepthHelp;

  /// No description provided for @settingsLevels.
  ///
  /// In en, this message translates to:
  /// **'{count} levels'**
  String settingsLevels(int count);

  /// No description provided for @settingsHiddenDirectories.
  ///
  /// In en, this message translates to:
  /// **'Include hidden directories'**
  String get settingsHiddenDirectories;

  /// No description provided for @settingsHiddenDirectoriesHelp.
  ///
  /// In en, this message translates to:
  /// **'Folders beginning with a dot. Usually editor state and tool caches rather than projects.'**
  String get settingsHiddenDirectoriesHelp;

  /// No description provided for @settingsSectionCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get settingsSectionCleaning;

  /// No description provided for @settingsConcurrency.
  ///
  /// In en, this message translates to:
  /// **'Projects at once'**
  String get settingsConcurrency;

  /// No description provided for @settingsConcurrencyHelp.
  ///
  /// In en, this message translates to:
  /// **'Clean commands that run in parallel. More is faster until the disk becomes the bottleneck. {cores} cores available.'**
  String settingsConcurrencyHelp(int cores);

  /// No description provided for @settingsTimeout.
  ///
  /// In en, this message translates to:
  /// **'Step timeout'**
  String get settingsTimeout;

  /// No description provided for @settingsTimeoutHelp.
  ///
  /// In en, this message translates to:
  /// **'A clean command that runs longer than this is killed and reported, so one stuck build tool cannot hold up the whole run.'**
  String get settingsTimeoutHelp;

  /// No description provided for @settingsSeconds.
  ///
  /// In en, this message translates to:
  /// **'{count} seconds'**
  String settingsSeconds(int count);

  /// No description provided for @settingsMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String settingsMinutes(int count);

  /// No description provided for @settingsConfirmBeforeDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm before deleting'**
  String get settingsConfirmBeforeDelete;

  /// No description provided for @settingsConfirmBeforeDeleteHelp.
  ///
  /// In en, this message translates to:
  /// **'Show a summary dialog whenever a run will delete directories outright rather than only running clean commands.'**
  String get settingsConfirmBeforeDeleteHelp;

  /// No description provided for @settingsSectionPreselect.
  ///
  /// In en, this message translates to:
  /// **'Pre-select these deletion categories'**
  String get settingsSectionPreselect;

  /// No description provided for @settingsPreselectHelp.
  ///
  /// In en, this message translates to:
  /// **'A convenience only. Every run still shows them ticked and still asks before deleting anything.'**
  String get settingsPreselectHelp;

  /// No description provided for @settingsSectionLogging.
  ///
  /// In en, this message translates to:
  /// **'Logging'**
  String get settingsSectionLogging;

  /// No description provided for @settingsLogDetail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get settingsLogDetail;

  /// No description provided for @settingsLogDebug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get settingsLogDebug;

  /// No description provided for @settingsLogInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get settingsLogInfo;

  /// No description provided for @settingsLogWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get settingsLogWarning;

  /// No description provided for @settingsLogError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get settingsLogError;

  /// No description provided for @settingsLogRetention.
  ///
  /// In en, this message translates to:
  /// **'Log files kept'**
  String get settingsLogRetention;

  /// No description provided for @settingsLogRetentionHelp.
  ///
  /// In en, this message translates to:
  /// **'Older files are removed once the active log is rotated.'**
  String get settingsLogRetentionHelp;

  /// No description provided for @settingsNone.
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get settingsNone;

  /// No description provided for @settingsSectionUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get settingsSectionUpdates;

  /// No description provided for @settingsCheckUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates automatically'**
  String get settingsCheckUpdates;

  /// No description provided for @settingsCheckUpdatesHelp.
  ///
  /// In en, this message translates to:
  /// **'Kruftle asks GitHub Releases on launch and offers a verified download. It never installs without asking.'**
  String get settingsCheckUpdatesHelp;

  /// No description provided for @settingsSectionSizes.
  ///
  /// In en, this message translates to:
  /// **'Sizes'**
  String get settingsSectionSizes;

  /// No description provided for @settingsSizeMode.
  ///
  /// In en, this message translates to:
  /// **'How sizes are counted'**
  String get settingsSizeMode;

  /// No description provided for @settingsSizeModeOnDisk.
  ///
  /// In en, this message translates to:
  /// **'Space actually used on disk'**
  String get settingsSizeModeOnDisk;

  /// No description provided for @settingsSizeModeApparent.
  ///
  /// In en, this message translates to:
  /// **'Total length of the files'**
  String get settingsSizeModeApparent;

  /// No description provided for @settingsSizeModeHelp.
  ///
  /// In en, this message translates to:
  /// **'On-disk matches what the operating system reports and what you get back, including block rounding and filesystem compression. It needs a native call that is unavailable on Windows, which falls back to file lengths.'**
  String get settingsSizeModeHelp;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsShowTour.
  ///
  /// In en, this message translates to:
  /// **'Show the feature tour again'**
  String get settingsShowTour;

  /// No description provided for @settingsChangelog.
  ///
  /// In en, this message translates to:
  /// **'What\'s new in this version'**
  String get settingsChangelog;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsLicence.
  ///
  /// In en, this message translates to:
  /// **'Free software under the GNU General Public License v3.0 or later.'**
  String get settingsLicence;

  /// No description provided for @settingsMadeWith.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ in Kolkata, India'**
  String get settingsMadeWith;

  /// No description provided for @settingsSourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get settingsSourceCode;

  /// No description provided for @settingsWebsite.
  ///
  /// In en, this message translates to:
  /// **'Kruftle website'**
  String get settingsWebsite;

  /// No description provided for @tourWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Kruftle'**
  String get tourWelcomeTitle;

  /// No description provided for @tourWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Build artifacts pile up quietly. Kruftle finds every project on your disk, works out what built it, and asks that toolchain to clean up after itself.'**
  String get tourWelcomeBody;

  /// No description provided for @tourWelcomeStart.
  ///
  /// In en, this message translates to:
  /// **'Show me around'**
  String get tourWelcomeStart;

  /// No description provided for @tourWelcomeSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip the tour'**
  String get tourWelcomeSkip;

  /// No description provided for @tourScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Point it at a folder'**
  String get tourScanTitle;

  /// No description provided for @tourScanBody.
  ///
  /// In en, this message translates to:
  /// **'Choose your codebase root. Kruftle walks everything underneath, recognising more than forty languages and build tools from the files they leave behind — including projects nested inside other projects.'**
  String get tourScanBody;

  /// No description provided for @tourReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'See what it found before anything happens'**
  String get tourReviewTitle;

  /// No description provided for @tourReviewBody.
  ///
  /// In en, this message translates to:
  /// **'Every project, every artifact directory, and what each one costs you — measured, not guessed. Tick what you want cleaned. Nothing is touched until you say so.'**
  String get tourReviewBody;

  /// No description provided for @tourSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety is not optional'**
  String get tourSafetyTitle;

  /// No description provided for @tourSafetyBody.
  ///
  /// In en, this message translates to:
  /// **'Kruftle prefers each toolchain\'s own clean command over deleting files. Raw deletion is allow-listed by directory name, never follows a symlink, refuses to leave the folder you chose, and always asks first. Anything git tracks is left alone.'**
  String get tourSafetyBody;

  /// No description provided for @tourCachesTitle.
  ///
  /// In en, this message translates to:
  /// **'The caches in your home directory too'**
  String get tourCachesTitle;

  /// No description provided for @tourCachesBody.
  ///
  /// In en, this message translates to:
  /// **'Cargo\'s registry, Gradle\'s caches, the npm and pub caches — shared by every project and often the biggest win on the disk. They get their own screen and their own confirmation.'**
  String get tourCachesBody;

  /// No description provided for @tourScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Set it and forget it'**
  String get tourScheduleTitle;

  /// No description provided for @tourScheduleBody.
  ///
  /// In en, this message translates to:
  /// **'Have Kruftle clean daily, weekly or monthly. It can nudge you while it is open, or register with your operating system\'s own scheduler and do the run with Kruftle closed.'**
  String get tourScheduleBody;

  /// No description provided for @tourFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'That\'s the whole app'**
  String get tourFinishTitle;

  /// No description provided for @tourFinishBody.
  ///
  /// In en, this message translates to:
  /// **'Everything runs on your machine. Nothing is uploaded, and there is no account to make.'**
  String get tourFinishBody;

  /// No description provided for @tourFinishAction.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get tourFinishAction;

  /// No description provided for @scheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Scheduled cleanups'**
  String get scheduleTitle;

  /// No description provided for @scheduleEnable.
  ///
  /// In en, this message translates to:
  /// **'Remind me to clean up'**
  String get scheduleEnable;

  /// No description provided for @scheduleEnableHelp.
  ///
  /// In en, this message translates to:
  /// **'Kruftle checks whether a cleanup is due while it is running, and tells you at launch if one was missed. Turn on background runs below to have it happen without Kruftle open.'**
  String get scheduleEnableHelp;

  /// No description provided for @scheduleBackground.
  ///
  /// In en, this message translates to:
  /// **'Run even when Kruftle is closed'**
  String get scheduleBackground;

  /// No description provided for @scheduleBackgroundHelp.
  ///
  /// In en, this message translates to:
  /// **'Registers a job with your operating system’s own scheduler, so a cleanup runs at the chosen time whether or not Kruftle is open. It runs each toolchain’s clean command and deletes only the categories you pre-selected in Settings.'**
  String get scheduleBackgroundHelp;

  /// No description provided for @scheduleBackgroundActive.
  ///
  /// In en, this message translates to:
  /// **'Registered with the system scheduler.'**
  String get scheduleBackgroundActive;

  /// No description provided for @scheduleBackgroundFailed.
  ///
  /// In en, this message translates to:
  /// **'Your system refused to register the background job. The reminder still works while Kruftle is open.'**
  String get scheduleBackgroundFailed;

  /// No description provided for @scheduleFrequency.
  ///
  /// In en, this message translates to:
  /// **'How often'**
  String get scheduleFrequency;

  /// No description provided for @scheduleDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get scheduleDaily;

  /// No description provided for @scheduleWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get scheduleWeekly;

  /// No description provided for @scheduleMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get scheduleMonthly;

  /// No description provided for @scheduleTimeOfDay.
  ///
  /// In en, this message translates to:
  /// **'At'**
  String get scheduleTimeOfDay;

  /// No description provided for @scheduleDayOfWeek.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get scheduleDayOfWeek;

  /// No description provided for @scheduleDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'On day'**
  String get scheduleDayOfMonth;

  /// No description provided for @scheduleFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder to scan'**
  String get scheduleFolder;

  /// No description provided for @scheduleChooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose a folder…'**
  String get scheduleChooseFolder;

  /// No description provided for @scheduleNextRun.
  ///
  /// In en, this message translates to:
  /// **'Next reminder {when}.'**
  String scheduleNextRun(String when);

  /// No description provided for @scheduleNeverRun.
  ///
  /// In en, this message translates to:
  /// **'No cleanup has run yet.'**
  String get scheduleNeverRun;

  /// No description provided for @scheduleLastRun.
  ///
  /// In en, this message translates to:
  /// **'Last cleanup {when}.'**
  String scheduleLastRun(String when);

  /// No description provided for @scheduleDueTitle.
  ///
  /// In en, this message translates to:
  /// **'A cleanup is due'**
  String get scheduleDueTitle;

  /// No description provided for @scheduleDueBody.
  ///
  /// In en, this message translates to:
  /// **'It has been {days} days since the last one under {folder}.'**
  String scheduleDueBody(int days, String folder);

  /// No description provided for @scheduleDueAction.
  ///
  /// In en, this message translates to:
  /// **'Scan now'**
  String get scheduleDueAction;

  /// No description provided for @scheduleDueDismiss.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get scheduleDueDismiss;

  /// No description provided for @scheduleNotifyOnFinish.
  ///
  /// In en, this message translates to:
  /// **'Notify me when a cleanup finishes'**
  String get scheduleNotifyOnFinish;

  /// No description provided for @scheduleNotificationDueTitle.
  ///
  /// In en, this message translates to:
  /// **'Kruftle — cleanup due'**
  String get scheduleNotificationDueTitle;

  /// No description provided for @scheduleNotificationDueBody.
  ///
  /// In en, this message translates to:
  /// **'It is time to clear build artifacts out of {folder}.'**
  String scheduleNotificationDueBody(String folder);

  /// No description provided for @scheduleNotificationDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Kruftle — {size} reclaimed'**
  String scheduleNotificationDoneTitle(String size);

  /// No description provided for @scheduleNotificationDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Cleaned {projects} projects in {duration}.'**
  String scheduleNotificationDoneBody(int projects, String duration);

  /// No description provided for @profilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Cleanup profiles'**
  String get profilesTitle;

  /// No description provided for @profilesIntro.
  ///
  /// In en, this message translates to:
  /// **'A profile teaches Kruftle a project type it does not know yet: which file marks it, what command cleans it, and which directories it may remove. Profiles sit alongside the built-in stacks and obey exactly the same safety rules.'**
  String get profilesIntro;

  /// No description provided for @profilesNone.
  ///
  /// In en, this message translates to:
  /// **'No custom profiles yet.'**
  String get profilesNone;

  /// No description provided for @profilesNew.
  ///
  /// In en, this message translates to:
  /// **'New profile'**
  String get profilesNew;

  /// No description provided for @profilesImport.
  ///
  /// In en, this message translates to:
  /// **'Import…'**
  String get profilesImport;

  /// No description provided for @profilesExport.
  ///
  /// In en, this message translates to:
  /// **'Export…'**
  String get profilesExport;

  /// No description provided for @profilesName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profilesName;

  /// No description provided for @profilesNameHint.
  ///
  /// In en, this message translates to:
  /// **'Unreal Engine'**
  String get profilesNameHint;

  /// No description provided for @profilesMarkers.
  ///
  /// In en, this message translates to:
  /// **'Marker files'**
  String get profilesMarkers;

  /// No description provided for @profilesMarkersHint.
  ///
  /// In en, this message translates to:
  /// **'*.uproject'**
  String get profilesMarkersHint;

  /// No description provided for @profilesMarkersHelp.
  ///
  /// In en, this message translates to:
  /// **'A directory containing any of these is treated as this kind of project. One per line. A leading dot-star matches by extension.'**
  String get profilesMarkersHelp;

  /// No description provided for @profilesCommand.
  ///
  /// In en, this message translates to:
  /// **'Clean command'**
  String get profilesCommand;

  /// No description provided for @profilesCommandHint.
  ///
  /// In en, this message translates to:
  /// **'make clean'**
  String get profilesCommandHint;

  /// No description provided for @profilesCommandHelp.
  ///
  /// In en, this message translates to:
  /// **'Run with the project directory as its working directory. Leave empty to only delete the directories below.'**
  String get profilesCommandHelp;

  /// No description provided for @profilesArtifacts.
  ///
  /// In en, this message translates to:
  /// **'Directories it may remove'**
  String get profilesArtifacts;

  /// No description provided for @profilesArtifactsHint.
  ///
  /// In en, this message translates to:
  /// **'Binaries\nIntermediate'**
  String get profilesArtifactsHint;

  /// No description provided for @profilesArtifactsHelp.
  ///
  /// In en, this message translates to:
  /// **'One per line, relative to the project root. This is an allow-list: nothing outside it is ever deleted, and deletion still needs your per-run confirmation.'**
  String get profilesArtifactsHelp;

  /// No description provided for @profilesExcludes.
  ///
  /// In en, this message translates to:
  /// **'Never scan these paths'**
  String get profilesExcludes;

  /// No description provided for @profilesExcludesHint.
  ///
  /// In en, this message translates to:
  /// **'**/vendor/**'**
  String get profilesExcludesHint;

  /// No description provided for @profilesExcludesHelp.
  ///
  /// In en, this message translates to:
  /// **'Glob patterns. Matching directories are skipped entirely, by every profile and every built-in stack.'**
  String get profilesExcludesHelp;

  /// No description provided for @profilesEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get profilesEnabled;

  /// No description provided for @profilesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete the profile “{name}”?'**
  String profilesDeleteConfirm(String name);

  /// No description provided for @profilesErrorName.
  ///
  /// In en, this message translates to:
  /// **'Give the profile a name.'**
  String get profilesErrorName;

  /// No description provided for @profilesErrorMarkers.
  ///
  /// In en, this message translates to:
  /// **'A profile needs at least one marker file, or it would match every folder.'**
  String get profilesErrorMarkers;

  /// No description provided for @profilesErrorNothingToDo.
  ///
  /// In en, this message translates to:
  /// **'Give the profile a clean command, some directories to remove, or both.'**
  String get profilesErrorNothingToDo;

  /// No description provided for @profilesErrorAbsolutePath.
  ///
  /// In en, this message translates to:
  /// **'Directories must be relative to the project root: “{path}” is not.'**
  String profilesErrorAbsolutePath(String path);

  /// No description provided for @profilesErrorEscapes.
  ///
  /// In en, this message translates to:
  /// **'“{path}” points outside the project. That is never allowed.'**
  String profilesErrorEscapes(String path);

  /// No description provided for @profilesErrorDuplicate.
  ///
  /// In en, this message translates to:
  /// **'A profile called “{name}” already exists.'**
  String profilesErrorDuplicate(String name);

  /// No description provided for @profilesImportFailed.
  ///
  /// In en, this message translates to:
  /// **'That file is not a Kruftle profile export.'**
  String get profilesImportFailed;

  /// No description provided for @profilesImported.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 profile.} other{Imported {count} profiles.}}'**
  String profilesImported(int count);

  /// No description provided for @diskTitle.
  ///
  /// In en, this message translates to:
  /// **'Disk usage'**
  String get diskTitle;

  /// No description provided for @diskVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get diskVolume;

  /// No description provided for @diskUsed.
  ///
  /// In en, this message translates to:
  /// **'used'**
  String get diskUsed;

  /// No description provided for @diskFree.
  ///
  /// In en, this message translates to:
  /// **'free'**
  String get diskFree;

  /// No description provided for @diskReclaimable.
  ///
  /// In en, this message translates to:
  /// **'reclaimable'**
  String get diskReclaimable;

  /// No description provided for @diskOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{used} of {total} used'**
  String diskOfTotal(String used, String total);

  /// No description provided for @diskFreedThisRun.
  ///
  /// In en, this message translates to:
  /// **'{size} freed'**
  String diskFreedThisRun(String size);

  /// No description provided for @diskTreemapEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing measured yet.'**
  String get diskTreemapEmpty;

  /// No description provided for @changelogTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get changelogTitle;

  /// No description provided for @changelogVersionHeading.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String changelogVersionHeading(String version);

  /// No description provided for @changelogUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The changelog could not be read.'**
  String get changelogUnavailable;

  /// No description provided for @changelogAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get changelogAdded;

  /// No description provided for @changelogChanged.
  ///
  /// In en, this message translates to:
  /// **'Changed'**
  String get changelogChanged;

  /// No description provided for @changelogFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get changelogFixed;

  /// No description provided for @changelogWhatsNewBanner.
  ///
  /// In en, this message translates to:
  /// **'Kruftle has been updated to {version}.'**
  String changelogWhatsNewBanner(String version);

  /// No description provided for @changelogWhatsNewAction.
  ///
  /// In en, this message translates to:
  /// **'See what changed'**
  String get changelogWhatsNewAction;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyTitle;

  /// No description provided for @legalTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalTermsTitle;

  /// No description provided for @legalUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This document could not be loaded.'**
  String get legalUnavailable;

  /// No description provided for @legalOpenInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get legalOpenInBrowser;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy'**
  String get consentTitle;

  /// No description provided for @consentBody.
  ///
  /// In en, this message translates to:
  /// **'Kruftle runs each toolchain\'s own clean command, and that deletes build output from this machine. Read the Terms of Service and the Privacy Policy before you start — continuing means you accept both.'**
  String get consentBody;

  /// No description provided for @consentAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept and continue'**
  String get consentAccept;

  /// No description provided for @consentDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline and quit'**
  String get consentDecline;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'ja',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return LAr();
    case 'de':
      return LDe();
    case 'en':
      return LEn();
    case 'es':
      return LEs();
    case 'fr':
      return LFr();
    case 'hi':
      return LHi();
    case 'ja':
      return LJa();
    case 'pt':
      return LPt();
    case 'ru':
      return LRu();
    case 'zh':
      return LZh();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
