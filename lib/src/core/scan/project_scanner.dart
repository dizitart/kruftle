// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:path/path.dart' as p;

import '../clean/safety.dart';
import '../models/project.dart';
import '../models/stack.dart';
import '../registry/stack_registry.dart';
import 'toolchain.dart';

/// What the user asked us to scan.
class ScanRequest {
  const ScanRequest({
    required this.root,
    this.maxDepth = 12,
    this.followHiddenDirectories = false,
  });

  final String root;

  /// Guard against pathological trees. Depth is counted from [root].
  final int maxDepth;

  /// Hidden directories are skipped by default: they hold VCS metadata, editor
  /// state and tool caches, not projects the user is working on.
  final bool followHiddenDirectories;
}

/// Progress emitted while walking, so the UI can show something honest during
/// a scan that may take a minute on a large tree.
sealed class ScanEvent {
  const ScanEvent();
}

class ScanningDirectory extends ScanEvent {
  const ScanningDirectory(this.path, this.projectsFound);

  final String path;
  final int projectsFound;
}

class ProjectFound extends ScanEvent {
  const ProjectFound(this.project);

  final DetectedProject project;
}

class ScanFailed extends ScanEvent {
  const ScanFailed(this.violation);

  final SafetyViolation violation;
}

/// Walks a directory tree and reports every project it recognises.
///
/// Cancellation is simply cancelling the returned stream's subscription: the
/// generator suspends at its next `yield` and the walk stops. There is no
/// separate cancellation token to keep in sync.
class ProjectScanner {
  ProjectScanner({
    StackRegistry? registry,
    ToolchainProbe? toolchain,
  })  : _registry = registry ?? const StackRegistry(),
        _toolchain = toolchain ?? ToolchainProbe();

  final StackRegistry _registry;
  final ToolchainProbe _toolchain;

  /// Directory names never descended into, whatever else is true of them.
  ///
  /// `node_modules` is here because it contains tens of thousands of
  /// `package.json` files, every one of which would otherwise be reported as a
  /// separate Node project.
  static const _neverDescend = {
    '.git',
    '.hg',
    '.svn',
    'node_modules',
    '.venv',
    'venv',
    '__pycache__',
  };

  Stream<ScanEvent> scan(ScanRequest request) async* {
    final violation = checkScanRoot(request.root);
    if (violation != null) {
      yield ScanFailed(violation);
      return;
    }

    var found = 0;
    final queue = <(Directory, int)>[(Directory(request.root), 0)];

    while (queue.isNotEmpty) {
      final (directory, depth) = queue.removeAt(0);
      if (depth > request.maxDepth) continue;

      yield ScanningDirectory(directory.path, found);

      final listing = await _list(directory);
      if (listing == null) continue; // unreadable: permissions, or raced away

      final matched = _registry.detect(listing);
      if (matched.isNotEmpty) {
        final project = await _describe(directory, matched, listing, depth);
        if (project.hasArtifacts) {
          found++;
          yield ProjectFound(project);
        }
      }

      // Keep descending even inside a detected project: monorepos nest, and a
      // Flutter app's `rust/` crate or `android/` module has its own build
      // output that the parent's clean command will not touch. We just never
      // descend into the artifact directories themselves.
      final skip = {
        ..._neverDescend,
        for (final stack in matched)
          for (final artifact in stack.artifacts)
            p.split(artifact.relative).first,
      };

      for (final name in listing.directories) {
        if (skip.contains(name)) continue;
        if (!request.followHiddenDirectories && name.startsWith('.')) continue;

        final child = p.join(directory.path, name);
        // Rail 3: never descend a symlink. Link cycles are how a tree walk
        // turns into an infinite loop.
        if (Link(child).existsSync()) continue;

        queue.add((Directory(child), depth + 1));
      }
    }
  }

  /// One listing per directory, reused for detection, command resolution and
  /// artifact discovery.
  Future<DirListing?> _list(Directory directory) async {
    final files = <String>{};
    final directories = <String>{};
    try {
      await for (final entity in directory.list(followLinks: false)) {
        final name = p.basename(entity.path);
        if (entity is Directory) {
          directories.add(name);
        } else {
          files.add(name);
        }
      }
    } on FileSystemException {
      return null;
    }
    return DirListing(files: files, directories: directories);
  }

  Future<DetectedProject> _describe(
    Directory directory,
    List<StackDefinition> matched,
    DirListing listing,
    int depth,
  ) async {
    final stacks = <StackMatch>[];
    for (final definition in matched) {
      stacks.add(
        StackMatch(
          stackId: definition.id,
          displayName: definition.displayName,
          command: definition.commandFor(listing),
          artifacts: _existingArtifacts(directory.path, definition),
          toolBinary: definition.tool?.binary,
          installUrl: definition.tool?.installUrl,
        ),
      );
    }
    return DetectedProject(path: directory.path, stacks: stacks, depth: depth);
  }

  /// Only artifacts that are actually on disk. A pristine checkout has nothing
  /// to clean, and reporting it as a cleanup candidate is noise.
  List<ArtifactHit> _existingArtifacts(
    String projectPath,
    StackDefinition definition,
  ) {
    final hits = <ArtifactHit>[];
    for (final artifact in definition.artifacts) {
      final full = p.join(projectPath, artifact.relative);
      if (!Directory(full).existsSync()) continue;
      if (Link(full).existsSync()) continue; // rail 3
      hits.add(
        ArtifactHit(
          absolutePath: full,
          relative: artifact.relative,
          risk: artifact.risk,
        ),
      );
    }
    return hits;
  }

  /// Whether each stack's tool is installed. Asked once per scan, after the
  /// walk, because probing a login shell is slow and the answer does not vary
  /// per project.
  Future<Map<StackId, ToolStatus>> toolAvailability() async {
    final statuses = <StackId, ToolStatus>{};
    for (final stack in _registry.stacks) {
      statuses[stack.id] = await _toolchain.status(stack.tool?.binary);
    }
    return statuses;
  }
}
