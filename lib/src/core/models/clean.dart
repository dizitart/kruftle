// SPDX-License-Identifier: GPL-3.0-or-later

import '../clean/safety.dart';
import 'project.dart';
import 'stack.dart';

/// How a single unit of cleanup is carried out.
enum StepKind {
  /// Run the toolchain's own clean command. Always preferred.
  command,

  /// Delete an allow-listed artifact directory outright. Only when there is no
  /// runnable command, or for dependency and cache directories that no clean
  /// command removes. Always behind an explicit opt-in.
  delete,
}

/// One thing Kruftle will do, in one project.
class CleanStep {
  const CleanStep.command({
    required this.projectPath,
    required this.stackId,
    required this.stackName,
    required CleanCommand this.command,
    required this.covers,
  })  : kind = StepKind.command,
        artifact = null;

  const CleanStep.delete({
    required this.projectPath,
    required this.stackId,
    required this.stackName,
    required ArtifactHit this.artifact,
  })  : kind = StepKind.delete,
        command = null,
        covers = const [];

  final StepKind kind;
  final String projectPath;
  final StackId stackId;
  final String stackName;

  final CleanCommand? command;
  final ArtifactHit? artifact;

  /// Artifact directories this command is expected to remove. Used for size
  /// estimation only — the tool decides for itself what it actually deletes.
  final List<ArtifactHit> covers;

  /// Every artifact path this step touches, for de-duplicated estimation.
  List<ArtifactHit> get touched => switch (kind) {
        StepKind.command => covers,
        StepKind.delete => [artifact!],
      };

  String get description => switch (kind) {
        StepKind.command => '$command',
        StepKind.delete => 'delete ${artifact!.relative}/',
      };
}

/// How a step ended.
enum StepStatus {
  /// The command exited zero, or the directory is gone.
  success,

  /// The command exited non-zero, or deletion threw.
  failed,

  /// Nothing to do — the target had already disappeared, usually because an
  /// earlier step in the same project removed it.
  skipped,

  /// A safety rail rejected the target. Never retried, never overridden.
  refused,

  /// Exceeded the step timeout and was killed.
  timedOut,

  /// The user cancelled before this step started.
  cancelled,
}

class StepOutcome {
  const StepOutcome({
    required this.step,
    required this.status,
    required this.duration,
    this.message,
    this.violation,
  });

  final CleanStep step;
  final StepStatus status;
  final Duration duration;

  /// Command stderr, or the reason a deletion failed. Shown verbatim in the
  /// report: a developer wants the actual error, not a paraphrase.
  final String? message;

  final SafetyViolation? violation;

  bool get isProblem =>
      status == StepStatus.failed || status == StepStatus.timedOut;
}

/// Which categories of directory the user has allowed for this run.
///
/// Empty by default. Nothing is ever deleted outright without the user ticking
/// a box for that category, for that run (safety rail 7).
typedef AllowedRisks = Set<CleanRisk>;

/// The complete set of steps for one run, plus what it is expected to free.
class CleanPlan {
  const CleanPlan({
    required this.scanRoot,
    required this.steps,
    required this.allowedRisks,
    this.gitTracked = const {},
  });

  final String scanRoot;
  final List<CleanStep> steps;
  final AllowedRisks allowedRisks;

  /// Absolute artifact paths that git tracks. Excluded from the default
  /// selection because deleting them destroys committed content (rail 6).
  final Set<String> gitTracked;

  bool get isEmpty => steps.isEmpty;

  List<String> get projectPaths =>
      {for (final s in steps) s.projectPath}.toList();

  /// Distinct artifact directories any step will touch.
  ///
  /// De-duplicated on purpose: `flutter clean` removes `build/` and a separate
  /// opt-in delete step may also target it, and counting those bytes twice
  /// would promise the user space that does not exist.
  Map<String, ArtifactHit> get touchedArtifacts => {
        for (final step in steps)
          for (final artifact in step.touched)
            artifact.absolutePath: artifact,
      };

  int get estimatedBytes => touchedArtifacts.values
      .fold(0, (sum, a) => sum + (a.sizeBytes ?? 0));
}

/// What actually happened.
class CleanReport {
  const CleanReport({
    required this.outcomes,
    required this.bytesFreed,
    required this.estimatedBytes,
    required this.duration,
    required this.cancelled,
  });

  final List<StepOutcome> outcomes;

  /// Measured, not predicted: the artifact directories are sized before and
  /// after the run and the difference is what we report.
  final int bytesFreed;

  final int estimatedBytes;
  final Duration duration;
  final bool cancelled;

  Iterable<StepOutcome> get problems => outcomes.where((o) => o.isProblem);

  int count(StepStatus status) =>
      outcomes.where((o) => o.status == status).length;

  int get projectsTouched => {
        for (final o in outcomes)
          if (o.status == StepStatus.success) o.step.projectPath,
      }.length;
}
