// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import '../disk/native_disk.dart';
import '../models/clean.dart';
import '../models/project.dart';
import '../models/stack.dart';
import '../scan/sizer.dart';
import '../scan/toolchain.dart';
import 'git_guard.dart';
import 'process_runner.dart';
import 'safety.dart';

/// Turns a user's selection into an ordered list of steps.
class CleanPlanner {
  const CleanPlanner({this.gitGuard = const GitGuard()});

  final GitGuard gitGuard;

  /// Builds the plan for [projects].
  ///
  /// The rules, in order of preference:
  /// 1. If the stack has a clean command and its tool is installed, run it.
  ///    This is always safest — the tool knows which files are its own.
  /// 2. Otherwise fall back to deleting the stack's allow-listed build output,
  ///    but only if the user opted into [allowedRisks].
  /// 3. Dependency and cache directories are added whenever opted into, with
  ///    or without a command, because no official clean removes them.
  Future<CleanPlan> plan({
    required String scanRoot,
    required List<DetectedProject> projects,
    required Map<String, ToolStatus> toolStatus,
    AllowedRisks allowedRisks = const {},
  }) async {
    final steps = <CleanStep>[];
    final tracked = <String>{};

    for (final project in projects) {
      final trackedHere = await gitGuard.trackedAmong(
        project.path,
        project.allArtifacts.map((a) => a.relative).toSet(),
      );

      for (final stack in project.stacks) {
        final toolReady = toolStatus[stack.toolBinary] == ToolStatus.available;
        final hasCommand = stack.command != null && toolReady;

        if (hasCommand) {
          steps.add(
            CleanStep.command(
              projectPath: project.path,
              stackId: stack.stackId,
              stackName: stack.displayName,
              command: stack.command!,
              covers: stack.artifacts
                  .where((a) => a.risk == CleanRisk.buildOutput)
                  .toList(),
            ),
          );
        }

        for (final artifact in stack.artifacts) {
          if (trackedHere.contains(artifact.relative)) {
            tracked.add(artifact.absolutePath);
            continue; // rail 6: never plan to delete committed content
          }
          if (!allowedRisks.contains(artifact.risk)) continue;
          // Build output is the command's job when there is a command to run.
          if (hasCommand && artifact.risk == CleanRisk.buildOutput) continue;

          steps.add(
            CleanStep.delete(
              projectPath: project.path,
              stackId: stack.stackId,
              stackName: stack.displayName,
              artifact: artifact,
            ),
          );
        }
      }
    }

    return CleanPlan(
      scanRoot: scanRoot,
      steps: steps,
      allowedRisks: allowedRisks,
      gitTracked: tracked,
    );
  }
}

/// Progress emitted while a plan runs.
sealed class CleanEvent {
  const CleanEvent();
}

class StepStarted extends CleanEvent {
  const StepStarted(this.step, this.completed, this.total);

  final CleanStep step;
  final int completed;
  final int total;
}

class StepFinished extends CleanEvent {
  const StepFinished(this.outcome);

  final StepOutcome outcome;
}

class RunFinished extends CleanEvent {
  const RunFinished(this.report);

  final CleanReport report;
}

/// Executes a [CleanPlan].
class Cleaner {
  Cleaner({
    ProcessRunner? runner,
    Sizer? sizer,
    NativeDisk? disk,
    this.concurrency = 4,
    this.stepTimeout = const Duration(minutes: 5),
  }) : _runner = runner ?? SystemProcessRunner(),
       _sizer = sizer ?? Sizer(),
       _disk = disk ?? NativeDisk.shared;

  final ProcessRunner _runner;
  final Sizer _sizer;
  final NativeDisk _disk;

  /// How many projects are cleaned at once. Steps *within* a project stay
  /// sequential: two build tools writing the same directory is how you corrupt
  /// a lock file.
  final int concurrency;

  final Duration stepTimeout;

  var _cancelled = false;

  /// Stop as soon as possible. In-flight processes are killed; steps that have
  /// not started are recorded as cancelled; the partial report is still
  /// returned, because a user who aborts still deserves to know what happened.
  Future<void> cancel() async {
    _cancelled = true;
    await _runner.killAll();
  }

  /// Measures what [plan] would free without changing anything.
  ///
  /// This is a real measurement of the directories the plan targets, not a
  /// guess — but it remains an *estimate* of the outcome, because a clean
  /// command decides for itself what to remove.
  Future<CleanPlan> dryRun(CleanPlan plan) async {
    final targets = plan.touchedArtifacts;
    final sizes = await _sizer.measureAll(targets.keys.toList());

    return CleanPlan(
      scanRoot: plan.scanRoot,
      allowedRisks: plan.allowedRisks,
      gitTracked: plan.gitTracked,
      steps: [for (final step in plan.steps) _resize(step, sizes)],
    );
  }

  Stream<CleanEvent> run(CleanPlan plan) async* {
    _cancelled = false;
    final stopwatch = Stopwatch()..start();

    final targets = plan.touchedArtifacts.keys.toList();
    final before = await _sizer.measureAll(targets);
    final estimated = before.values.fold(0, (a, b) => a + b);

    // The volume's own figure, either side of the run. Cheap — one syscall —
    // and it is the number the user will go and check in Finder afterwards.
    final volumeBefore = _disk.spaceFor(plan.scanRoot);

    // Group by project so each project's steps stay ordered, while different
    // projects proceed in parallel.
    final byProject = <String, List<CleanStep>>{};
    for (final step in plan.steps) {
      byProject.putIfAbsent(step.projectPath, () => []).add(step);
    }

    final outcomes = <StepOutcome>[];
    final queue = byProject.values.toList();
    final events = StreamController<CleanEvent>();
    var completed = 0;

    Future<void> worker() async {
      while (queue.isNotEmpty) {
        final group = queue.removeAt(0);
        for (final step in group) {
          if (_cancelled) {
            outcomes.add(
              StepOutcome(
                step: step,
                status: StepStatus.cancelled,
                duration: Duration.zero,
              ),
            );
            continue;
          }
          events.add(StepStarted(step, completed, plan.steps.length));
          final outcome = await _execute(step, plan.scanRoot);
          outcomes.add(outcome);
          completed++;
          events.add(StepFinished(outcome));
        }
      }
    }

    unawaited(
      Future.wait([
        for (
          var i = 0;
          i < concurrency.clamp(1, queue.length.clamp(1, 32));
          i++
        )
          worker(),
      ]).then((_) => events.close()),
    );

    yield* events.stream;

    final after = await _sizer.measureAll(targets);
    final freed = targets.fold(
      0,
      (sum, path) => sum + ((before[path] ?? 0) - (after[path] ?? 0)),
    );

    stopwatch.stop();
    yield RunFinished(
      CleanReport(
        outcomes: outcomes,
        bytesFreed: freed < 0 ? 0 : freed,
        estimatedBytes: estimated,
        duration: stopwatch.elapsed,
        cancelled: _cancelled,
        volumeBefore: volumeBefore,
        volumeAfter: _disk.spaceFor(plan.scanRoot),
      ),
    );
  }

  Future<StepOutcome> _execute(CleanStep step, String scanRoot) async {
    final stopwatch = Stopwatch()..start();

    StepOutcome done(StepStatus status, {String? message, SafetyViolation? v}) {
      stopwatch.stop();
      return StepOutcome(
        step: step,
        status: status,
        duration: stopwatch.elapsed,
        message: message,
        violation: v,
      );
    }

    switch (step.kind) {
      case StepKind.command:
        final result = await _runner.run(
          step.command!,
          workingDirectory: step.projectPath,
          timeout: stepTimeout,
        );
        if (result.timedOut) {
          return done(
            StepStatus.timedOut,
            message: 'Killed after ${stepTimeout.inSeconds}s.',
          );
        }
        return result.succeeded
            ? done(StepStatus.success, message: result.stdout.trim())
            : done(
                StepStatus.failed,
                // Maven prints its errors to stdout, so stderr-only reporting
                // showed the user a bare "exited 1" and no reason.
                message: switch ((result.stderr.trim(), result.stdout.trim())) {
                  (final err, _) when err.isNotEmpty => err,
                  (_, final out) when out.isNotEmpty => out,
                  _ => 'exited ${result.exitCode}',
                },
              );

      case StepKind.delete:
        final target = step.artifact!.absolutePath;

        // Re-check every rail at the moment of deletion, not just at plan
        // time: minutes may have passed and the tree may have changed under
        // us. This is the last gate before anything is destroyed.
        final violation = checkDeleteTarget(
          scanRoot: scanRoot,
          projectRoot: step.projectPath,
          target: target,
          allowedRelatives: {step.artifact!.relative},
        );
        if (violation == SafetyViolation.notADirectory) {
          return done(StepStatus.skipped, message: 'Already gone.');
        }
        if (violation != null) {
          return done(
            StepStatus.refused,
            message: violation.message,
            v: violation,
          );
        }

        try {
          await Directory(target).delete(recursive: true);
          return done(StepStatus.success);
        } on FileSystemException catch (e) {
          return done(StepStatus.failed, message: e.message);
        }
    }
  }

  CleanStep _resize(CleanStep step, Map<String, int> sizes) {
    ArtifactHit sized(ArtifactHit a) => a.withSize(sizes[a.absolutePath] ?? 0);

    return switch (step.kind) {
      StepKind.command => CleanStep.command(
        projectPath: step.projectPath,
        stackId: step.stackId,
        stackName: step.stackName,
        command: step.command!,
        covers: step.covers.map(sized).toList(),
      ),
      StepKind.delete => CleanStep.delete(
        projectPath: step.projectPath,
        stackId: step.stackId,
        stackName: step.stackName,
        artifact: sized(step.artifact!),
      ),
    };
  }
}
