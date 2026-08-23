// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/clean/cleaner.dart';
import 'package:kruftle/src/core/clean/process_runner.dart';
import 'package:kruftle/src/core/models/clean.dart';
import 'package:kruftle/src/core/models/project.dart';
import 'package:kruftle/src/core/models/stack.dart';
import 'package:kruftle/src/core/scan/toolchain.dart';
import 'package:path/path.dart' as p;

/// Records every invocation instead of spawning anything, so tests can assert
/// on the exact argv and working directory.
class FakeRunner implements ProcessRunner {
  FakeRunner({this.outcome, this.onRun});

  final ProcessOutcome? outcome;
  final ProcessOutcome Function(CleanCommand, String)? onRun;

  final invocations = <({CleanCommand command, String cwd})>[];
  var killed = false;

  @override
  Future<ProcessOutcome> run(
    CleanCommand command, {
    required String workingDirectory,
    required Duration timeout,
  }) async {
    invocations.add((command: command, cwd: workingDirectory));
    return onRun?.call(command, workingDirectory) ??
        outcome ??
        const ProcessOutcome(exitCode: 0, stdout: '', stderr: '');
  }

  @override
  Future<void> killAll() async => killed = true;
}

void main() {
  late Directory tmp;
  late String root;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('kruftle_clean');
    root = p.join(tmp.path, 'codebase');
    Directory(root).createSync(recursive: true);
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  /// Builds a project on disk and the matching model.
  DetectedProject makeProject(
    String name, {
    StackId stackId = StackId.rust,
    CleanCommand? command = const CleanCommand('cargo', ['clean']),
    List<(String, CleanRisk)> artifacts = const [
      ('target', CleanRisk.buildOutput),
    ],
    int bytesEach = 4096,
  }) {
    final projectPath = p.join(root, name);
    Directory(projectPath).createSync(recursive: true);

    final hits = <ArtifactHit>[];
    for (final (relative, risk) in artifacts) {
      final full = p.join(projectPath, relative);
      Directory(full).createSync(recursive: true);
      File(
        p.join(full, 'blob.bin'),
      ).writeAsBytesSync(List.filled(bytesEach, 0));
      hits.add(ArtifactHit(absolutePath: full, relative: relative, risk: risk));
    }

    return DetectedProject(
      path: projectPath,
      depth: 1,
      stacks: [
        StackMatch(
          stackId: stackId,
          displayName: stackId.name,
          command: command,
          artifacts: hits,
          toolBinary: 'cargo',
          installUrl: null,
        ),
      ],
    );
  }

  const available = {StackId.rust: ToolStatus.available};
  const missing = {StackId.rust: ToolStatus.missing};

  Future<CleanPlan> planFor(
    List<DetectedProject> projects, {
    Map<StackId, ToolStatus> tools = available,
    AllowedRisks risks = const {},
  }) => const CleanPlanner().plan(
    scanRoot: root,
    projects: projects,
    toolStatus: tools,
    allowedRisks: risks,
  );

  Future<CleanReport> execute(CleanPlan plan, {ProcessRunner? runner}) async {
    final events = await Cleaner(
      runner: runner ?? FakeRunner(),
    ).run(plan).toList();
    return events.whereType<RunFinished>().single.report;
  }

  group('planning', () {
    test('prefers the official command when the tool is installed', () async {
      final plan = await planFor([makeProject('app')]);

      expect(plan.steps, hasLength(1));
      expect(plan.steps.single.kind, StepKind.command);
      expect(plan.steps.single.command, const CleanCommand('cargo', ['clean']));
    });

    test(
      'plans nothing when the tool is missing and nothing is opted in',
      () async {
        // Rail 7: a missing SDK must never silently become a raw delete.
        final plan = await planFor([makeProject('app')], tools: missing);
        expect(plan.steps, isEmpty);
      },
    );

    test(
      'falls back to deletion when the tool is missing and opted in',
      () async {
        final plan = await planFor(
          [makeProject('app')],
          tools: missing,
          risks: {CleanRisk.buildOutput},
        );

        expect(plan.steps.single.kind, StepKind.delete);
        expect(plan.steps.single.artifact!.relative, 'target');
      },
    );

    test(
      'does not also delete build output the command already removes',
      () async {
        final plan = await planFor(
          [makeProject('app')],
          risks: {CleanRisk.buildOutput},
        );

        expect(plan.steps.map((s) => s.kind), [StepKind.command]);
      },
    );

    test('deletes dependency directories alongside the command, since no '
        'clean command removes them', () async {
      final project = makeProject(
        'web',
        artifacts: const [
          ('target', CleanRisk.buildOutput),
          ('node_modules', CleanRisk.dependencies),
        ],
      );

      final withoutOptIn = await planFor([project]);
      expect(withoutOptIn.steps.map((s) => s.kind), [StepKind.command]);

      final withOptIn = await planFor(
        [project],
        risks: {CleanRisk.dependencies},
      );
      expect(withOptIn.steps.map((s) => s.kind), [
        StepKind.command,
        StepKind.delete,
      ]);
      expect(withOptIn.steps.last.artifact!.relative, 'node_modules');
    });

    test('opting into one category does not enable another', () async {
      final project = makeProject(
        'web',
        command: null,
        artifacts: const [
          ('node_modules', CleanRisk.dependencies),
          ('.turbo', CleanRisk.cache),
        ],
      );

      final plan = await planFor([project], risks: {CleanRisk.cache});
      expect(plan.steps.single.artifact!.relative, '.turbo');
    });

    test('estimates each artifact once even when two steps cover it', () async {
      final plan = await planFor(
        [makeProject('app', bytesEach: 1000)],
        risks: {CleanRisk.buildOutput},
      );
      final measured = await Cleaner(runner: FakeRunner()).dryRun(plan);

      expect(measured.touchedArtifacts, hasLength(1));
      expect(measured.estimatedBytes, 1000);
    });
  });

  group('rail 6 — git-tracked artifacts', () {
    test('excludes a tracked artifact directory from the plan', () async {
      final project = makeProject(
        'vendored',
        command: null,
        artifacts: const [('target', CleanRisk.buildOutput)],
      );

      await Process.run('git', ['init', '-q', project.path]);
      await Process.run('git', ['-C', project.path, 'add', '-f', 'target']);

      final plan = await planFor(
        [project],
        tools: missing,
        risks: {CleanRisk.buildOutput},
      );

      expect(plan.steps, isEmpty, reason: 'deleting it would destroy commits');
      expect(
        plan.gitTracked,
        contains(project.allArtifacts.single.absolutePath),
      );
    });

    test(
      'an untracked artifact directory in a git repo is still cleanable',
      () async {
        final project = makeProject('normal', command: null);
        await Process.run('git', ['init', '-q', project.path]);
        File(p.join(project.path, '.gitignore')).writeAsStringSync('target/\n');

        final plan = await planFor(
          [project],
          tools: missing,
          risks: {CleanRisk.buildOutput},
        );

        expect(plan.steps, hasLength(1));
        expect(plan.gitTracked, isEmpty);
      },
    );
  });

  group('dry run', () {
    test('measures without changing anything', () async {
      final project = makeProject('app', bytesEach: 8192);
      final plan = await planFor(
        [project],
        tools: missing,
        risks: {CleanRisk.buildOutput},
      );

      final measured = await Cleaner(runner: FakeRunner()).dryRun(plan);

      expect(measured.estimatedBytes, 8192);
      expect(
        Directory(project.allArtifacts.single.absolutePath).existsSync(),
        isTrue,
        reason: 'a dry run must not delete',
      );
    });
  });

  group('execution', () {
    test('runs the command in the project directory', () async {
      final project = makeProject('app');
      final runner = FakeRunner();
      await execute(await planFor([project]), runner: runner);

      expect(runner.invocations, hasLength(1));
      expect(
        runner.invocations.single.command,
        const CleanCommand('cargo', ['clean']),
      );
      expect(runner.invocations.single.cwd, project.path);
    });

    test('really deletes an allow-listed directory', () async {
      final project = makeProject('app', command: null);
      final target = project.allArtifacts.single.absolutePath;

      final report = await execute(
        await planFor(
          [project],
          tools: missing,
          risks: {CleanRisk.buildOutput},
        ),
      );

      expect(Directory(target).existsSync(), isFalse);
      expect(report.count(StepStatus.success), 1);
      expect(report.bytesFreed, 4096);
    });

    test('reports freed bytes measured, not the estimate', () async {
      // The fake runner does nothing, so a command step frees nothing — and
      // the report must say so rather than claiming the estimate.
      final project = makeProject('app', bytesEach: 2048);
      final report = await execute(await planFor([project]));

      expect(report.estimatedBytes, 2048);
      expect(report.bytesFreed, 0);
    });

    test('a failing command is recorded with its stderr and does not stop '
        'the run', () async {
      final projects = [makeProject('a'), makeProject('b')];
      final runner = FakeRunner(
        onRun: (command, cwd) => cwd.endsWith('a')
            ? const ProcessOutcome(
                exitCode: 101,
                stdout: '',
                stderr: 'error: could not remove',
              )
            : const ProcessOutcome(exitCode: 0, stdout: '', stderr: ''),
      );

      final report = await execute(await planFor(projects), runner: runner);

      expect(report.count(StepStatus.failed), 1);
      expect(report.count(StepStatus.success), 1);
      expect(report.problems.single.message, 'error: could not remove');
    });

    test('a timed-out command is killed and reported, not hidden', () async {
      final runner = FakeRunner(
        onRun: (_, _) => const ProcessOutcome(
          exitCode: -1,
          stdout: '',
          stderr: '',
          timedOut: true,
        ),
      );
      final report = await execute(
        await planFor([makeProject('app')]),
        runner: runner,
      );

      expect(report.count(StepStatus.timedOut), 1);
      expect(report.problems.single.message, contains('Killed after'));
    });

    test('a missing executable becomes a failure, not a crash', () async {
      final project = makeProject('app');
      final plan = await planFor([project]);
      final report = await Cleaner(runner: SystemProcessRunner())
          .run(
            CleanPlan(
              scanRoot: root,
              allowedRisks: const {},
              steps: [
                CleanStep.command(
                  projectPath: project.path,
                  stackId: StackId.rust,
                  stackName: 'Rust',
                  command: const CleanCommand('kruftle-no-such-binary'),
                  covers: const [],
                ),
              ],
            ),
          )
          .toList()
          .then((e) => e.whereType<RunFinished>().single.report);

      expect(plan.steps, isNotEmpty);
      expect(report.count(StepStatus.failed), 1);
    });

    test('a target that vanished mid-run is skipped, not failed', () async {
      final project = makeProject('app', command: null);
      final plan = await planFor(
        [project],
        tools: missing,
        risks: {CleanRisk.buildOutput},
      );

      Directory(
        project.allArtifacts.single.absolutePath,
      ).deleteSync(recursive: true);

      final report = await execute(plan);
      expect(report.count(StepStatus.skipped), 1);
    });

    test('re-checks the safety rails at the moment of deletion', () async {
      final project = makeProject('app', command: null);
      final target = project.allArtifacts.single.absolutePath;
      final plan = await planFor(
        [project],
        tools: missing,
        risks: {CleanRisk.buildOutput},
      );

      // Between planning and running, the directory is swapped for a link to
      // somewhere outside the tree. The rail must catch it.
      Directory(target).deleteSync(recursive: true);
      final elsewhere = Directory(p.join(tmp.path, 'precious'))..createSync();
      File(p.join(elsewhere.path, 'irreplaceable.txt')).writeAsStringSync('!');
      Link(target).createSync(elsewhere.path);

      final report = await execute(plan);

      expect(report.count(StepStatus.refused), 1);
      expect(
        File(p.join(elsewhere.path, 'irreplaceable.txt')).existsSync(),
        isTrue,
      );
    });

    test('cleans several projects concurrently', () async {
      final projects = [for (var i = 0; i < 8; i++) makeProject('p$i')];
      final runner = FakeRunner();
      final report = await execute(await planFor(projects), runner: runner);

      expect(runner.invocations, hasLength(8));
      expect(report.projectsTouched, 8);
    });

    test('steps within one project stay in order', () async {
      final project = makeProject(
        'web',
        artifacts: const [
          ('target', CleanRisk.buildOutput),
          ('node_modules', CleanRisk.dependencies),
        ],
      );
      final plan = await planFor([project], risks: {CleanRisk.dependencies});

      final events = await Cleaner(runner: FakeRunner()).run(plan).toList();
      final order = events.whereType<StepFinished>().map(
        (e) => e.outcome.step.kind,
      );

      expect(order, [StepKind.command, StepKind.delete]);
    });

    test('emits progress for every step', () async {
      final events = await Cleaner(
        runner: FakeRunner(),
      ).run(await planFor([makeProject('a'), makeProject('b')])).toList();

      expect(events.whereType<StepStarted>(), hasLength(2));
      expect(events.whereType<StepFinished>(), hasLength(2));
      expect(events.last, isA<RunFinished>());
    });

    test(
      'an empty plan produces an empty report rather than an error',
      () async {
        final report = await execute(await planFor([]));
        expect(report.outcomes, isEmpty);
        expect(report.bytesFreed, 0);
      },
    );
  });

  group('cancellation', () {
    test('kills in-flight processes and reports what was skipped', () async {
      final projects = [for (var i = 0; i < 20; i++) makeProject('p$i')];
      final plan = await planFor(projects);

      final cleaner = Cleaner(runner: FakeRunner(), concurrency: 1);
      final events = <CleanEvent>[];

      await for (final event in cleaner.run(plan)) {
        events.add(event);
        if (events.whereType<StepFinished>().length == 3) {
          await cleaner.cancel();
        }
      }

      final report = events.whereType<RunFinished>().single.report;
      expect(report.cancelled, isTrue);
      expect(report.count(StepStatus.cancelled), greaterThan(0));
      expect(
        report.outcomes,
        hasLength(20),
        reason: 'every step is accounted for, cancelled ones included',
      );
    });
  });
}
