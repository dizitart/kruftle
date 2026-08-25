// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/clean/cleaner.dart';
import 'core/log/activity_log.dart';
import 'core/models/clean.dart';
import 'core/models/project.dart';
import 'core/profiles/profile.dart';
import 'core/registry/stack_registry.dart';
import 'core/scan/project_scanner.dart';
import 'core/scan/sizer.dart';
import 'core/schedule/notifier.dart';
import 'core/schedule/schedule.dart';
import 'core/settings/settings.dart';
import 'core/single_instance.dart';

/// The whole app when the operating system's scheduler started it.
///
/// Not in `core/` because it reads the same stored preferences the UI writes,
/// and those arrive through Flutter plugins; not in `ui/` because it draws
/// nothing. It is the second front door to the same engine.
///
/// **No window.** `runApp` is never called, and Windows and Linux only show
/// their window once Flutter renders a frame, so on those two there is nothing
/// to suppress. macOS builds its window from a nib before Dart starts, which is
/// why `AppDelegate.swift` and `MainFlutterWindow.swift` check for the same
/// flag and keep it off screen.
///
/// **It does only what the user already agreed to.** The plan is built with
/// `Settings.rememberedRisks` — the categories pre-selected in Settings, empty
/// on a fresh install — so an unattended run does the toolchains' own clean
/// commands and deletes nothing the user has not opted into. Safety rail 7
/// survives having nobody at the keyboard.
///
/// Every path returns rather than throwing: this process has no user interface
/// to report a failure through, so everything lands in the activity log the
/// next open window will show.
Future<void> runBackgroundCleanup({
  DesktopNotifier notifier = const SystemNotifier(),
}) async {
  final support = await getApplicationSupportDirectory();
  final preferences = await SharedPreferences.getInstance();
  // Written by the UI at some point in the past; a fresh install has neither,
  // in which case both decode to their defaults and the guard below stops.
  final settings = Settings.decode(preferences.getString(Settings.storageKey));
  final schedule = CleanupSchedule.decode(
    preferences.getString(CleanupSchedule.storageKey),
  );

  final log = ActivityLog(
    directory: p.join(support.path, 'logs'),
    minimumLevel: settings.logLevel,
    keepRotations: settings.logRetentionFiles,
  );

  // A window is open, and it may well be cleaning right now. The scheduled
  // run is the one that gives way: the person at the keyboard is watching.
  // Not released — the process exits the moment this returns.
  if (InstanceLock.tryAcquire(support.path) == null) {
    log.warning('Background run declined: Kruftle is already open');
    return;
  }

  final root = schedule.root;
  // The job outliving the setting that created it is the case worth guarding:
  // an uninstall that failed, or a plist copied to a new machine. Refusing to
  // clean is always the safe answer.
  if (!schedule.isConfigured || !schedule.runInBackground || root == null) {
    log.warning('Background run declined: the schedule is no longer set', {
      'enabled': schedule.enabled,
      'runInBackground': schedule.runInBackground,
      'root': root,
    });
    return;
  }
  if (!Directory(root).existsSync()) {
    log.error('Background run declined: the folder is gone', {'root': root});
    return;
  }

  log.info('Background cleanup started', {
    'root': root,
    'risks': settings.rememberedRisks.map((r) => r.name).toList(),
  });

  final profiles = ProfileSet.decodeOrEmpty(
    preferences.getString(ProfileSet.storageKey),
  );
  final scanner = ProjectScanner(
    registry: StackRegistry.withCustom(profiles.stacks),
  );

  final projects = <DetectedProject>[];
  await for (final event in scanner.scan(
    ScanRequest(
      root: root,
      maxDepth: settings.maxScanDepth,
      followHiddenDirectories: settings.scanHiddenDirectories,
      excludeGlobs: profiles.excludeGlobs,
    ),
  )) {
    if (event case ProjectFound(:final project)) projects.add(project);
    if (event case ScanFailed(:final violation)) {
      log.error('Background scan refused', {'reason': violation.message});
      return;
    }
  }

  if (projects.isEmpty) {
    log.info('Background cleanup finished: nothing to clean', {'root': root});
    return;
  }

  final plan = await const CleanPlanner().plan(
    scanRoot: root,
    projects: projects,
    toolStatus: await scanner.toolAvailability(),
    allowedRisks: settings.rememberedRisks,
  );

  final report =
      await Cleaner(
            concurrency: settings.cleanConcurrency,
            stepTimeout: settings.stepTimeout,
            sizer: Sizer(mode: settings.sizeMode),
          )
          .run(plan)
          .where((e) => e is RunFinished)
          .cast<RunFinished>()
          .map((e) => e.report)
          .first;

  for (final outcome in report.outcomes) {
    log.log(
      switch (outcome.status) {
        StepStatus.failed || StepStatus.timedOut => LogLevel.error,
        StepStatus.refused => LogLevel.warning,
        _ => LogLevel.info,
      },
      'Background step ${outcome.status.name}',
      {
        'project': outcome.step.projectPath,
        'action': outcome.step.description,
        if (outcome.message?.isNotEmpty ?? false) 'detail': outcome.message,
      },
    );
  }

  log.info('Background cleanup finished', {
    'root': root,
    'freedBytes': report.bytesFreed,
    'projects': report.projectsTouched,
    'failed': report.problems.length,
    'seconds': report.duration.inSeconds,
  });

  // Resets the interval, so the next time a window opens it does not also
  // announce that a cleanup is overdue.
  await preferences.setString(
    CleanupSchedule.storageKey,
    schedule.copyWith(lastRun: DateTime.now()).encode(),
  );

  if (schedule.notifyOnFinish) {
    await notifier.notify(
      title: 'Kruftle',
      body:
          '${formatBytes(report.bytesFreed)} · '
          '${report.projectsTouched} projects',
    );
  }
}
