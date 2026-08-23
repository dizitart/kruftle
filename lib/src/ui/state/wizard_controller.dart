// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clean/cleaner.dart';
import '../../core/clean/safety.dart';
import '../../core/log/activity_log.dart';
import '../../core/models/clean.dart';
import '../../core/models/project.dart';
import '../../core/models/stack.dart';
import '../../core/scan/project_scanner.dart';
import '../../core/scan/sizer.dart';
import '../../core/scan/toolchain.dart';
import 'app_state.dart';

enum WizardStep { source, scanning, review, running, report }

/// Everything on screen, in one immutable value.
class WizardState {
  const WizardState({
    this.step = WizardStep.source,
    this.root,
    this.projects = const [],
    this.selected = const {},
    this.risks = const {},
    this.tools = const {},
    this.currentPath,
    this.directoriesScanned = 0,
    this.sizingProgress,
    this.plan,
    this.stepsDone = 0,
    this.stepsTotal = 0,
    this.runningStep,
    this.finishedSteps = const [],
    this.report,
    this.error,
  });

  final WizardStep step;
  final String? root;

  final List<DetectedProject> projects;

  /// Project paths the user has ticked.
  final Set<String> selected;

  /// Raw-deletion categories opted into for this run (safety rail 7).
  final Set<CleanRisk> risks;

  final Map<StackId, ToolStatus> tools;

  // Scan progress.
  final String? currentPath;
  final int directoriesScanned;

  /// 0..1 while artifact directories are being measured, null when not sizing.
  final double? sizingProgress;

  /// Present once a dry run has measured the plan.
  final CleanPlan? plan;

  // Run progress.
  final int stepsDone;
  final int stepsTotal;
  final CleanStep? runningStep;
  final List<StepOutcome> finishedSteps;

  final CleanReport? report;
  final String? error;

  List<DetectedProject> get selectedProjects =>
      projects.where((p) => selected.contains(p.path)).toList();

  int get selectedBytes =>
      selectedProjects.fold(0, (sum, p) => sum + p.estimatedBytes);

  int get totalBytes => projects.fold(0, (sum, p) => sum + p.estimatedBytes);

  /// True when a selected project's toolchain is missing, so the UI can explain
  /// why opting into deletion might be worth it.
  bool get hasMissingToolchains => selectedProjects.any(
    (project) => project.stacks.any(
      (s) => s.command != null && tools[s.stackId] == ToolStatus.missing,
    ),
  );

  double get runProgress =>
      stepsTotal == 0 ? 0 : (stepsDone / stepsTotal).clamp(0, 1);

  WizardState copyWith({
    WizardStep? step,
    String? root,
    List<DetectedProject>? projects,
    Set<String>? selected,
    Set<CleanRisk>? risks,
    Map<StackId, ToolStatus>? tools,
    String? currentPath,
    int? directoriesScanned,
    double? sizingProgress,
    CleanPlan? plan,
    int? stepsDone,
    int? stepsTotal,
    CleanStep? runningStep,
    List<StepOutcome>? finishedSteps,
    CleanReport? report,
    String? error,
    bool clearError = false,
    bool clearPlan = false,
    bool clearSizing = false,
  }) => WizardState(
    step: step ?? this.step,
    root: root ?? this.root,
    projects: projects ?? this.projects,
    selected: selected ?? this.selected,
    risks: risks ?? this.risks,
    tools: tools ?? this.tools,
    currentPath: currentPath ?? this.currentPath,
    directoriesScanned: directoriesScanned ?? this.directoriesScanned,
    sizingProgress: clearSizing ? null : sizingProgress ?? this.sizingProgress,
    plan: clearPlan ? null : plan ?? this.plan,
    stepsDone: stepsDone ?? this.stepsDone,
    stepsTotal: stepsTotal ?? this.stepsTotal,
    runningStep: runningStep ?? this.runningStep,
    finishedSteps: finishedSteps ?? this.finishedSteps,
    report: report ?? this.report,
    error: clearError ? null : error ?? this.error,
  );
}

/// Drives the whole wizard. One controller rather than one per step, because
/// the steps are phases of a single operation and splitting them would mean
/// threading the same scan result through four objects.
class WizardController extends Notifier<WizardState> {
  StreamSubscription<ScanEvent>? _scanSubscription;
  StreamSubscription<CleanEvent>? _runSubscription;
  Cleaner? _cleaner;

  ActivityLog get _log => ref.read(activityLogProvider);

  @override
  WizardState build() {
    ref.onDispose(() {
      unawaited(_scanSubscription?.cancel());
      unawaited(_runSubscription?.cancel());
    });
    return WizardState(risks: ref.read(settingsProvider).rememberedRisks);
  }

  // ---------------------------------------------------------------- scanning

  Future<void> startScan(String root) async {
    final settings = ref.read(settingsProvider);
    _log.info('Scan started', {'root': root});

    state = state.copyWith(
      step: WizardStep.scanning,
      root: root,
      projects: const [],
      selected: const {},
      directoriesScanned: 0,
      clearError: true,
      clearPlan: true,
    );

    await ref.read(settingsProvider.notifier).rememberRoot(root);

    final scanner = ProjectScanner();
    final found = <DetectedProject>[];
    final completed = Completer<void>();

    _scanSubscription = scanner
        .scan(
          ScanRequest(
            root: root,
            maxDepth: settings.maxScanDepth,
            followHiddenDirectories: settings.scanHiddenDirectories,
          ),
        )
        .listen(
          (event) {
            switch (event) {
              case ScanningDirectory(:final path):
                state = state.copyWith(
                  currentPath: path,
                  directoriesScanned: state.directoriesScanned + 1,
                );
              case ProjectFound(:final project):
                found.add(project);
                state = state.copyWith(projects: List.of(found));
              case ScanFailed(:final violation):
                _fail(violation.message);
            }
          },
          onDone: completed.complete,
          onError: (Object e) {
            _fail('$e');
            completed.complete();
          },
          cancelOnError: true,
        );

    await completed.future;
    if (state.step != WizardStep.scanning) return; // cancelled or failed

    final tools = await scanner.toolAvailability();

    _log.info('Scan finished', {
      'root': root,
      'projects': found.length,
      'directories': state.directoriesScanned,
    });

    // Straight to the review screen. Measuring is far slower than walking — a
    // single Rust `target/` can hold a quarter of a million files — and there
    // is no reason to make the user stare at a progress bar before they can
    // start choosing. Sizes stream in behind them.
    state = state.copyWith(
      step: WizardStep.review,
      projects: found,
      tools: tools,
      selected: found.map((p) => p.path).toSet(),
      sizingProgress: 0,
    );

    unawaited(_measureInBackground(found, root));
  }

  /// Measures artifact directories after the review screen is already up,
  /// folding each result into the visible list.
  ///
  /// Updates are flushed on a timer rather than per directory: rebuilding every
  /// project on each of several hundred measurements would spend more time in
  /// the widget tree than on the disk.
  Future<void> _measureInBackground(
    List<DetectedProject> projects,
    String root,
  ) async {
    final paths = [
      for (final project in projects)
        for (final artifact in project.allArtifacts) artifact.absolutePath,
    ];
    if (paths.isEmpty) {
      state = state.copyWith(clearSizing: true);
      return;
    }

    final sizes = <String, int>{};
    var done = 0;
    var dirty = false;

    void flush() {
      if (!dirty) return;
      dirty = false;
      // A restart or a new scan makes this result stale; drop it rather than
      // writing sizes over a different tree's projects.
      if (state.root != root || state.step == WizardStep.source) return;
      state = state.copyWith(
        projects: _applySizes(projects, sizes),
        sizingProgress: done / paths.length,
      );
    }

    final ticker = Timer.periodic(
      const Duration(milliseconds: 400),
      (_) => flush(),
    );

    await Sizer().measureAll(
      paths,
      onMeasured: (path, bytes) {
        sizes[path] = bytes;
        done++;
        dirty = true;
      },
    );

    ticker.cancel();
    if (state.root != root || state.step == WizardStep.source) return;

    final measured = _applySizes(projects, sizes);
    _log.info('Measurement finished', {
      'root': root,
      'directories': paths.length,
      'bytes': measured.fold<int>(0, (s, p) => s + p.estimatedBytes),
    });

    state = state.copyWith(projects: measured, clearSizing: true);
  }

  List<DetectedProject> _applySizes(
    List<DetectedProject> projects,
    Map<String, int> sizes,
  ) => [
    for (final project in projects)
      project.withStacks([
        for (final stack in project.stacks)
          stack.withArtifacts([
            for (final artifact in stack.artifacts)
              if (sizes.containsKey(artifact.absolutePath))
                artifact.withSize(sizes[artifact.absolutePath]!)
              else
                artifact,
          ]),
      ]),
  ];

  Future<void> cancelScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    _log.warning('Scan cancelled by user');
    state = state.copyWith(step: WizardStep.source);
  }

  // --------------------------------------------------------------- selection

  void toggle(String path) {
    final selected = Set<String>.of(state.selected);
    selected.contains(path) ? selected.remove(path) : selected.add(path);
    state = state.copyWith(selected: selected, clearPlan: true);
  }

  void selectAll() => state = state.copyWith(
    selected: state.projects.map((p) => p.path).toSet(),
    clearPlan: true,
  );

  void selectNone() =>
      state = state.copyWith(selected: const {}, clearPlan: true);

  /// Ticks exactly the projects passed, used by the filter's "select matching".
  void selectOnly(Iterable<String> paths) =>
      state = state.copyWith(selected: paths.toSet(), clearPlan: true);

  void setRisk(CleanRisk risk, bool enabled) {
    final risks = Set<CleanRisk>.of(state.risks);
    enabled ? risks.add(risk) : risks.remove(risk);
    state = state.copyWith(risks: risks, clearPlan: true);
  }

  // ------------------------------------------------------------------ running

  Future<CleanPlan> _buildPlan() => const CleanPlanner().plan(
    scanRoot: state.root!,
    projects: state.selectedProjects,
    toolStatus: state.tools,
    allowedRisks: state.risks,
  );

  /// Measures what a run would free, changing nothing.
  Future<void> dryRun() async {
    final settings = ref.read(settingsProvider);
    state = state.copyWith(sizingProgress: 0, clearPlan: true);

    final cleaner = Cleaner(
      concurrency: settings.cleanConcurrency,
      stepTimeout: settings.stepTimeout,
    );
    final measured = await cleaner.dryRun(await _buildPlan());

    _log.info('Dry run', {
      'projects': measured.projectPaths.length,
      'steps': measured.steps.length,
      'estimatedBytes': measured.estimatedBytes,
    });

    state = state.copyWith(plan: measured, clearSizing: true);
  }

  Future<void> execute() async {
    final settings = ref.read(settingsProvider);
    final plan = state.plan ?? await _buildPlan();

    _log.info('Cleanup started', {
      'root': state.root,
      'steps': plan.steps.length,
      'risks': state.risks.map((r) => r.name).toList(),
    });

    state = state.copyWith(
      step: WizardStep.running,
      stepsDone: 0,
      stepsTotal: plan.steps.length,
      finishedSteps: const [],
      clearError: true,
    );

    final cleaner = _cleaner = Cleaner(
      concurrency: settings.cleanConcurrency,
      stepTimeout: settings.stepTimeout,
    );

    final outcomes = <StepOutcome>[];
    final completed = Completer<void>();

    _runSubscription = cleaner
        .run(plan)
        .listen(
          (event) {
            switch (event) {
              case StepStarted(:final step):
                state = state.copyWith(runningStep: step);
              case StepFinished(:final outcome):
                outcomes.add(outcome);
                _logOutcome(outcome);
                state = state.copyWith(
                  stepsDone: outcomes.length,
                  finishedSteps: List.of(outcomes),
                );
              case RunFinished(:final report):
                _log.info('Cleanup finished', {
                  'freedBytes': report.bytesFreed,
                  'estimatedBytes': report.estimatedBytes,
                  'failed': report.problems.length,
                  'cancelled': report.cancelled,
                  'seconds': report.duration.inSeconds,
                });
                state = state.copyWith(step: WizardStep.report, report: report);
            }
          },
          onDone: completed.complete,
          onError: (Object e) {
            _fail('$e');
            completed.complete();
          },
        );

    await completed.future;
    _cleaner = null;
  }

  void _logOutcome(StepOutcome outcome) {
    final data = {
      'project': outcome.step.projectPath,
      'stack': outcome.step.stackName,
      'action': outcome.step.description,
      'status': outcome.status.name,
      'ms': outcome.duration.inMilliseconds,
      if (outcome.message != null && outcome.message!.isNotEmpty)
        'detail': outcome.message,
    };
    switch (outcome.status) {
      case StepStatus.failed:
      case StepStatus.timedOut:
        _log.error('Step failed', data);
      case StepStatus.refused:
        _log.warning('Step refused by a safety rail', data);
      case StepStatus.success:
      case StepStatus.skipped:
      case StepStatus.cancelled:
        _log.info('Step ${outcome.status.name}', data);
    }
  }

  Future<void> cancelRun() async {
    await _cleaner?.cancel();
    _log.warning('Cleanup cancelled by user');
  }

  // ------------------------------------------------------------------- other

  void backToReview() =>
      state = state.copyWith(step: WizardStep.review, clearError: true);

  /// Back to the beginning, keeping nothing but the user's remembered
  /// preferences. The previous root is dropped so the source screen shows the
  /// chooser rather than silently re-offering what was just scanned.
  void restart() =>
      state = WizardState(risks: ref.read(settingsProvider).rememberedRisks);

  void _fail(String message) {
    _log.error('Wizard error', {'message': message});
    state = state.copyWith(step: WizardStep.source, error: message);
  }
}

final wizardProvider = NotifierProvider<WizardController, WizardState>(
  WizardController.new,
);

/// Convenience for the safety banner on the review step.
String describeViolation(SafetyViolation violation) => violation.message;
