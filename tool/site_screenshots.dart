// SPDX-License-Identifier: GPL-3.0-or-later
//
// Renders the real app screens to PNG for kruftle.dizitart.com.
//
// Not a test and not run by CI — it lives outside `test/` for that reason.
// It pumps the production widget tree with seeded state and rasterises it, so
// what lands in the site's `public/screenshots/` is the actual UI rather than
// a mockup. Run it with:
//
//     flutter test tool/site_screenshots.dart
//
// Fonts are loaded from the Flutter SDK's own cache because a widget test
// otherwise draws every glyph as a box.
//
// It drives the app the way the widget tests do, but the analyser only grants
// `test/` those privileges, so the seams are ignored here by hand rather than
// by moving the file into `test/` and having CI run it on every push.
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: invalid_use_of_protected_member

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/core/clean/safety.dart';
import 'package:kruftle/src/core/disk/native_disk.dart';
import 'package:kruftle/src/core/models/clean.dart';
import 'package:kruftle/src/core/models/project.dart';
import 'package:kruftle/src/core/models/stack.dart';
import 'package:kruftle/src/core/scan/toolchain.dart';
import 'package:kruftle/src/core/settings/settings.dart';
import 'package:kruftle/src/ui/app.dart';
import 'package:kruftle/src/ui/state/app_state.dart';
import 'package:kruftle/src/ui/state/wizard_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

const outputDirectory = 'tool/screenshots';
const pixelRatio = 2.0;

final _boundaryKey = GlobalKey();

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'] ?? _flutterRootFromDart();
  final material = '$root/bin/cache/artifacts/material_fonts';

  Future<void> register(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final file in files) {
      final handle = File(file);
      if (!handle.existsSync()) continue;
      loader.addFont(
        Future.value(ByteData.sublistView(handle.readAsBytesSync())),
      );
    }
    await loader.load();
  }

  await register('Roboto', [
    '$material/Roboto-Regular.ttf',
    '$material/Roboto-Medium.ttf',
    '$material/Roboto-Bold.ttf',
  ]);
  await register('MaterialIcons', ['$material/MaterialIcons-Regular.otf']);
  // A `TextStyle` with no family — the treemap paints its labels with one —
  // falls through to the binding's own test font, which draws every glyph as a
  // box. Registering Roboto under those names replaces it.
  for (final family in const ['Ahem', 'FlutterTest', '']) {
    await register(family, [
      '$material/Roboto-Regular.ttf',
      '$material/Roboto-Medium.ttf',
      '$material/Roboto-Bold.ttf',
    ]);
  }
  // The theme asks for the platform's mono face by name; give those names the
  // real SF Mono, or paths and sizes render as boxes.
  for (final family in const ['SF Mono', 'Menlo', 'Monaco', 'monospace']) {
    await register(family, ['/System/Library/Fonts/SFNSMono.ttf']);
  }
}

String _flutterRootFromDart() {
  var directory = File(Platform.resolvedExecutable).parent;
  while (directory.path != directory.parent.path) {
    if (Directory('${directory.path}/bin/cache/artifacts').existsSync()) {
      return directory.path;
    }
    directory = directory.parent;
  }
  throw StateError('Could not locate FLUTTER_ROOT');
}

Future<void> _shoot(WidgetTester tester, String name) async {
  final boundary =
      _boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File('$outputDirectory/$name.png')
    ..createSync(recursive: true)
    ..writeAsBytesSync(png!.buffer.asUint8List());
  // ignore: avoid_print
  print('wrote ${file.path} (${file.lengthSync() ~/ 1024} KiB)');
}

Future<void> _pump(
  WidgetTester tester,
  WizardState Function(WizardState) seed, {
  AppThemeMode theme = AppThemeMode.dark,
  Size canvas = const Size(1280, 900),
}) async {
  const settings = Settings(
    hasAcceptedLegal: true,
    hasSeenTour: true,
    checkForUpdates: false,
  );
  SharedPreferences.setMockInitialValues({
    Settings.storageKey: settings.copyWith(themeMode: theme).encode(),
  });
  final preferences = await SharedPreferences.getInstance();

  tester.view.physicalSize = canvas * pixelRatio;
  tester.view.devicePixelRatio = pixelRatio;
  tester.view.platformDispatcher.textScaleFactorTestValue = 1.0;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      appSupportDirectoryProvider.overrideWithValue(
        Directory.systemTemp.createTempSync('kruftle-shots').path,
      ),
      appVersionProvider.overrideWithValue('0.2.2'),
    ],
  );
  addTearDown(container.dispose);

  container.read(wizardProvider);
  final controller = container.read(wizardProvider.notifier);
  controller.state = seed(controller.state);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: RepaintBoundary(key: _boundaryKey, child: const KruftleApp()),
    ),
  );
  // Several frames rather than one: the step list slides its rows in, and a
  // single pump catches them mid-flight as ghosts against the left edge.
  await tester.pump();
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

// ---------------------------------------------------------------------------
// Seed data. Shapes and sizes a real developer machine actually produces.
// ---------------------------------------------------------------------------

const _gib = 1024 * 1024 * 1024;
const _mib = 1024 * 1024;

DetectedProject _project(
  String path, {
  required StackId id,
  required String stack,
  required String tool,
  required CleanCommand command,
  required List<(String, int, CleanRisk)> artifacts,
  int depth = 1,
}) => DetectedProject(
  path: path,
  depth: depth,
  stacks: [
    StackMatch(
      stackId: id,
      displayName: stack,
      command: command,
      artifacts: [
        for (final (relative, bytes, risk) in artifacts)
          ArtifactHit(
            absolutePath: '$path/$relative',
            relative: relative,
            risk: risk,
            sizeBytes: bytes,
          ),
      ],
      toolBinary: tool,
      installUrl: null,
    ),
  ],
);

final _projects = <DetectedProject>[
  _project(
    '/Users/dev/code/atlas-engine',
    id: StackId.rust,
    stack: 'Rust',
    tool: 'cargo',
    command: const CleanCommand('cargo', ['clean']),
    artifacts: [('target', 9 * _gib + 220 * _mib, CleanRisk.buildOutput)],
  ),
  _project(
    '/Users/dev/code/harbour-app',
    id: StackId.flutter,
    stack: 'Flutter',
    tool: 'flutter',
    command: const CleanCommand('flutter', ['clean']),
    artifacts: [
      ('build', 3 * _gib + 640 * _mib, CleanRisk.buildOutput),
      ('.dart_tool', 412 * _mib, CleanRisk.cache),
    ],
  ),
  _project(
    '/Users/dev/code/harbour-app/rust',
    id: StackId.rust,
    stack: 'Rust',
    tool: 'cargo',
    command: const CleanCommand('cargo', ['clean']),
    depth: 2,
    artifacts: [('target', 2 * _gib + 780 * _mib, CleanRisk.buildOutput)],
  ),
  _project(
    '/Users/dev/code/console-web',
    id: StackId.node,
    stack: 'Node.js',
    tool: 'node',
    command: const CleanCommand('npm', ['run', 'clean']),
    artifacts: [
      ('node_modules', 1 * _gib + 180 * _mib, CleanRisk.dependencies),
      ('.next/cache', 704 * _mib, CleanRisk.cache),
    ],
  ),
  _project(
    '/Users/dev/code/ledger-service',
    id: StackId.maven,
    stack: 'Maven',
    tool: 'mvn',
    command: const CleanCommand('mvn', ['clean']),
    artifacts: [('target', 1 * _gib + 96 * _mib, CleanRisk.buildOutput)],
  ),
  _project(
    '/Users/dev/code/telemetry-agent',
    id: StackId.go,
    stack: 'Go',
    tool: 'go',
    command: const CleanCommand('go', ['clean', '-cache', '-testcache']),
    artifacts: [('bin', 884 * _mib, CleanRisk.buildOutput)],
  ),
  _project(
    '/Users/dev/code/mobile-sdk',
    id: StackId.gradle,
    stack: 'Gradle',
    tool: 'gradle',
    command: const CleanCommand('./gradlew', ['clean']),
    artifacts: [
      ('build', 742 * _mib, CleanRisk.buildOutput),
      ('.gradle', 318 * _mib, CleanRisk.cache),
    ],
  ),
  _project(
    '/Users/dev/code/analytics-notebook',
    id: StackId.python,
    stack: 'Python',
    tool: 'python3',
    command: const CleanCommand('python3', ['setup.py', 'clean', '--all']),
    artifacts: [
      ('.venv', 612 * _mib, CleanRisk.dependencies),
      ('__pycache__', 41 * _mib, CleanRisk.cache),
    ],
  ),
];

const _tools = <String, ToolStatus>{
  'cargo': ToolStatus.available,
  'flutter': ToolStatus.available,
  'node': ToolStatus.available,
  'mvn': ToolStatus.available,
  'go': ToolStatus.available,
  'gradle': ToolStatus.available,
  'python3': ToolStatus.available,
};

CleanStep _step(DetectedProject project) => CleanStep.command(
  projectPath: project.path,
  stackId: project.stacks.first.stackId,
  stackName: project.stacks.first.displayName,
  command: project.stacks.first.command!,
  covers: project.stacks.first.artifacts,
);

void main() {
  setUpAll(_loadFonts);

  testWidgets('review', (tester) async {
    await _pump(
      tester,
      (s) => s.copyWith(
        step: WizardStep.review,
        root: '/Users/dev/code',
        projects: _projects,
        tools: _tools,
        selected: _projects.map((p) => p.path).toSet(),
      ),
    );
    await _shoot(tester, 'review-dark');
  });

  testWidgets('review light', (tester) async {
    await _pump(
      tester,
      (s) => s.copyWith(
        step: WizardStep.review,
        root: '/Users/dev/code',
        projects: _projects,
        tools: _tools,
        selected: _projects.map((p) => p.path).toSet(),
      ),
      theme: AppThemeMode.light,
    );
    await _shoot(tester, 'review-light');
  });

  testWidgets('scanning', (tester) async {
    await _pump(
      tester,
      (s) => s.copyWith(
        step: WizardStep.scanning,
        root: '/Users/dev/code',
        projects: _projects.take(6).toList(),
        directoriesScanned: 14208,
        currentPath: '/Users/dev/code/harbour-app/rust/target/debug',
        sizingProgress: 0.62,
      ),
      canvas: const Size(1280, 660),
    );
    await _shoot(tester, 'scanning-dark');
  });

  testWidgets('report', (tester) async {
    final outcomes = [
      for (final project in _projects)
        StepOutcome(
          step: _step(project),
          status: StepStatus.success,
          duration: const Duration(milliseconds: 2400),
        ),
    ];
    await _pump(
      tester,
      (s) => s.copyWith(
        step: WizardStep.report,
        root: '/Users/dev/code',
        projects: _projects,
        tools: _tools,
        selected: _projects.map((p) => p.path).toSet(),
        report: CleanReport(
          outcomes: outcomes,
          bytesFreed: 18 * _gib + 460 * _mib,
          estimatedBytes: 19 * _gib + 120 * _mib,
          duration: const Duration(minutes: 1, seconds: 48),
          cancelled: false,
          volumeBefore: const DiskSpace(
            totalBytes: 1000 * 1000 * 1000 * 1000,
            freeBytes: 96 * 1000 * 1000 * 1000,
            availableBytes: 96 * 1000 * 1000 * 1000,
          ),
          volumeAfter: const DiskSpace(
            totalBytes: 1000 * 1000 * 1000 * 1000,
            freeBytes: 116 * 1000 * 1000 * 1000,
            availableBytes: 116 * 1000 * 1000 * 1000,
          ),
        ),
      ),
      canvas: const Size(1280, 620),
    );
    await _shoot(tester, 'report-dark');
  });
}

// Referenced so the safety import is not flagged unused when seeds change.
// ignore: unused_element
const _violation = SafetyViolation.symlink;
