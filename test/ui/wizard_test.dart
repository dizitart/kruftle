// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/models/clean.dart';
import 'package:kruftle/src/core/models/project.dart';
import 'package:kruftle/src/core/models/stack.dart';
import 'package:kruftle/src/core/scan/toolchain.dart';
import 'package:kruftle/src/ui/state/app_state.dart';
import 'package:kruftle/src/ui/state/wizard_controller.dart';
import 'package:kruftle/src/ui/theme.dart';
import 'package:kruftle/src/ui/widgets/common.dart';
import 'package:kruftle/src/ui/wizard/wizard_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Puts the wizard on screen with [state] already applied, so each step can be
/// asserted on without driving a real scan.
Future<void> pumpWizard(
  WidgetTester tester,
  WizardState Function(WizardState) seed, {
  Size size = const Size(1200, 820),
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();

  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      appSupportDirectoryProvider.overrideWithValue('/tmp/kruftle-test'),
    ],
  );
  addTearDown(container.dispose);

  // Realise the notifier, then push the seeded state into it.
  container.read(wizardProvider);
  final controller = container.read(wizardProvider.notifier);
  controller.state = seed(controller.state);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: KruftleTheme.dark(),
        home: const Scaffold(body: WizardShell()),
      ),
    ),
  );
  await tester.pump();
}

DetectedProject project(
  String path, {
  StackId stackId = StackId.rust,
  String stackName = 'Rust',
  int bytes = 1024 * 1024,
  String artifact = 'target',
}) => DetectedProject(
  path: path,
  depth: 1,
  stacks: [
    StackMatch(
      stackId: stackId,
      displayName: stackName,
      command: const CleanCommand('cargo', ['clean']),
      artifacts: [
        ArtifactHit(
          absolutePath: '$path/$artifact',
          relative: artifact,
          risk: CleanRisk.buildOutput,
          sizeBytes: bytes,
        ),
      ],
      toolBinary: 'cargo',
      installUrl: null,
    ),
  ],
);

void main() {
  testWidgets('the first step asks for a folder', (tester) async {
    await pumpWizard(tester, (s) => s);

    expect(find.text('Which directory should Kruftle look through?'), findsOne);
    expect(find.text('Choose a folder'), findsOne);
  });

  testWidgets('the scan step reports progress rather than a bare spinner', (
    tester,
  ) async {
    await pumpWizard(
      tester,
      (s) => s.copyWith(
        step: WizardStep.scanning,
        root: '/work',
        projects: [project('/work/a'), project('/work/b')],
        directoriesScanned: 812,
        currentPath: '/work/a/src',
      ),
    );

    expect(find.text('2'), findsOne); // projects found
    expect(find.text('812'), findsOne); // directories walked
    expect(find.text('Stop scanning'), findsOne);
  });

  group('review step', () {
    Future<void> pumpReview(
      WidgetTester tester, {
      List<DetectedProject>? projects,
      Set<String>? selected,
      Map<StackId, ToolStatus> tools = const {
        StackId.rust: ToolStatus.available,
      },
      double? sizing,
    }) {
      final found =
          projects ??
          [
            project('/work/alpha', bytes: 4 * 1024 * 1024),
            project('/work/beta', bytes: 2 * 1024 * 1024),
          ];
      return pumpWizard(
        tester,
        (s) => s.copyWith(
          step: WizardStep.review,
          root: '/work',
          projects: found,
          tools: tools,
          selected: selected ?? found.map((p) => p.path).toSet(),
          sizingProgress: sizing,
        ),
      );
    }

    testWidgets('lists every project with its size', (tester) async {
      await pumpReview(tester);

      expect(find.text('alpha'), findsOne);
      expect(find.text('beta'), findsOne);
      expect(find.text('4.0 MiB'), findsOne);
      expect(find.text('2.0 MiB'), findsOne);
    });

    testWidgets('shows the scanned folder and a way back out', (tester) async {
      await pumpReview(tester);

      expect(find.text('work'), findsOne);
      expect(find.text('2 projects'), findsOne);
      expect(find.text('Change folder'), findsOne);
    });

    testWidgets('the total reflects only what is selected', (tester) async {
      await pumpReview(tester, selected: {'/work/alpha'});

      expect(find.text('4.0 MiB'), findsWidgets);
      expect(find.text('in 1 selected project'), findsOne);
    });

    testWidgets('every deletion category starts switched off', (tester) async {
      await pumpReview(tester);

      final toggles = tester
          .widgetList<RiskToggle>(find.byType(RiskToggle))
          .toList();

      // Safety rail 7: every raw-deletion category is off until the user
      // ticks it, for that run.
      expect(toggles.map((t) => t.risk).toSet(), CleanRisk.values.toSet());
      expect(toggles.every((t) => t.value == false), isTrue);
    });

    testWidgets('warns when a selected project has no toolchain installed', (
      tester,
    ) async {
      await pumpReview(tester, tools: const {StackId.rust: ToolStatus.missing});

      expect(
        find.textContaining('Some selected projects have no SDK installed'),
        findsOne,
      );
    });

    testWidgets('says so while sizes are still being measured', (tester) async {
      await pumpReview(tester, sizing: 0.4);
      expect(find.text('still measuring — 40%'), findsOne);
    });

    testWidgets('both actions are offered, and the dry run is optional', (
      tester,
    ) async {
      await pumpReview(tester);

      expect(find.text('Dry run'), findsOne);
      expect(find.text('Clean now'), findsOne);
      expect(
        find.text('A dry run changes nothing. You can skip it.'),
        findsOne,
      );
    });

    testWidgets('nothing selected disables both actions', (tester) async {
      await pumpReview(tester, selected: const {});

      final clean = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Clean now'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(clean.onPressed, isNull);
    });
  });

  group('report step', () {
    StepOutcome failure(String project, String message) => StepOutcome(
      step: CleanStep.command(
        projectPath: project,
        stackId: StackId.node,
        stackName: 'Node.js',
        command: const CleanCommand('npm', ['run', 'clean']),
        covers: const [],
      ),
      status: StepStatus.failed,
      duration: const Duration(milliseconds: 120),
      message: message,
    );

    testWidgets('leads with what was actually reclaimed', (tester) async {
      await pumpWizard(
        tester,
        (s) => s.copyWith(
          step: WizardStep.report,
          root: '/work',
          report: CleanReport(
            outcomes: [
              StepOutcome(
                step: CleanStep.command(
                  projectPath: '/work/alpha',
                  stackId: StackId.rust,
                  stackName: 'Rust',
                  command: const CleanCommand('cargo', ['clean']),
                  covers: const [],
                ),
                status: StepStatus.success,
                duration: const Duration(milliseconds: 90),
              ),
            ],
            bytesFreed: 3 * 1024 * 1024,
            estimatedBytes: 3 * 1024 * 1024,
            duration: const Duration(seconds: 2),
            cancelled: false,
          ),
        ),
      );

      expect(find.text('Done'), findsOne);
      expect(find.text('3.0 MiB'), findsOne);
      expect(find.text('reclaimed'), findsOne);
    });

    testWidgets('shows a failure verbatim instead of paraphrasing it', (
      tester,
    ) async {
      const stderr = 'npm error Missing script: "clean"';
      await pumpWizard(
        tester,
        (s) => s.copyWith(
          step: WizardStep.report,
          root: '/work',
          report: CleanReport(
            outcomes: [failure('/work/webapp', stderr)],
            bytesFreed: 0,
            estimatedBytes: 0,
            duration: const Duration(seconds: 1),
            cancelled: false,
          ),
        ),
      );

      expect(find.text('What went wrong'.toUpperCase()), findsOne);
      expect(find.text(stderr), findsOne);
    });

    testWidgets('a cancelled run still reports what it managed', (
      tester,
    ) async {
      await pumpWizard(
        tester,
        (s) => s.copyWith(
          step: WizardStep.report,
          root: '/work',
          report: const CleanReport(
            outcomes: [],
            bytesFreed: 1024,
            estimatedBytes: 4096,
            duration: Duration(seconds: 1),
            cancelled: true,
          ),
        ),
      );

      expect(find.text('Stopped'), findsOne);
      expect(find.text('1.0 KiB'), findsOne);
    });
  });
}
