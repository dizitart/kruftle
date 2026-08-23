// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:path/path.dart' as p;

import 'stack.dart';

/// An artifact directory that was declared by a stack *and* actually exists on
/// disk.
class ArtifactHit {
  const ArtifactHit({
    required this.absolutePath,
    required this.relative,
    required this.risk,
    this.sizeBytes,
  });

  final String absolutePath;
  final String relative;
  final CleanRisk risk;

  /// Filled in by the sizer. Null means "not measured yet", which the UI shows
  /// as a spinner rather than as zero.
  final int? sizeBytes;

  ArtifactHit withSize(int bytes) => ArtifactHit(
        absolutePath: absolutePath,
        relative: relative,
        risk: risk,
        sizeBytes: bytes,
      );
}

/// One stack found in one project directory, with everything needed to clean
/// it resolved up front.
class StackMatch {
  const StackMatch({
    required this.stackId,
    required this.displayName,
    required this.command,
    required this.artifacts,
    required this.toolBinary,
    required this.installUrl,
  });

  final StackId stackId;
  final String displayName;

  /// The official clean invocation, already resolved (wrapper vs global,
  /// npm vs pnpm). Null when this stack has no clean command to offer.
  final CleanCommand? command;

  /// Artifact directories that exist right now.
  final List<ArtifactHit> artifacts;

  /// Binary that must be on PATH for [command] to run. Null when the stack
  /// declares no tool.
  final String? toolBinary;

  final String? installUrl;

  int get knownSizeBytes => artifacts.fold(
        0,
        (sum, a) => sum + (a.sizeBytes ?? 0),
      );

  StackMatch withArtifacts(List<ArtifactHit> updated) => StackMatch(
        stackId: stackId,
        displayName: displayName,
        command: command,
        artifacts: updated,
        toolBinary: toolBinary,
        installUrl: installUrl,
      );
}

/// A directory the scanner identified as a project.
class DetectedProject {
  const DetectedProject({
    required this.path,
    required this.stacks,
    required this.depth,
  });

  /// Absolute, normalised path to the project root.
  final String path;

  /// Every stack detected here, highest priority first. More than one is
  /// normal: a Flutter app is also a Gradle build.
  final List<StackMatch> stacks;

  /// Distance from the scan root, used for indentation in the results table.
  final int depth;

  String get name => p.basename(path);

  /// Sum of every measured artifact directory. This is the *estimate* shown
  /// before a run — the official clean tools decide for themselves what to
  /// remove, so the figure reported afterwards is measured separately.
  int get estimatedBytes =>
      stacks.fold(0, (sum, s) => sum + s.knownSizeBytes);

  List<ArtifactHit> get allArtifacts =>
      [for (final s in stacks) ...s.artifacts];

  bool get hasArtifacts => stacks.any((s) => s.artifacts.isNotEmpty);

  DetectedProject withStacks(List<StackMatch> updated) =>
      DetectedProject(path: path, stacks: updated, depth: depth);
}
