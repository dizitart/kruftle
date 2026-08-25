// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../models/stack.dart';

/// The lockfile names the package manager the project actually uses. Running a
/// different one would rewrite the lockfile, so we never guess wrong on
/// purpose: no lockfile means npm, which is the ecosystem default.
CleanCommand? _resolveNode(DirListing listing) {
  // There is no standard clean for Node. Many projects define one; running it
  // is safe because it is the project's own script. When absent, `npm run
  // clean` fails with `Missing script: "clean"` and the real win is deleting
  // node_modules, which is an opt-in artifact below.
  if (!_declaresCleanScript(listing)) return null;

  final manager = switch (listing) {
    _ when listing.hasFile('bun.lockb') || listing.hasFile('bun.lock') => 'bun',
    _ when listing.hasFile('pnpm-lock.yaml') => 'pnpm',
    _ when listing.hasFile('yarn.lock') => 'yarn',
    _ => 'npm',
  };
  return CleanCommand(manager, ['run', 'clean']);
}

bool _declaresCleanScript(DirListing listing) {
  if (listing.path.isEmpty) return false;
  try {
    final manifest = jsonDecode(
      File(p.join(listing.path, 'package.json')).readAsStringSync(),
    );
    return manifest is Map && manifest['scripts'] is Map
        ? (manifest['scripts'] as Map).containsKey('clean')
        : false;
  } on Object {
    // Unreadable or malformed package.json: no command, fall back to deletion.
    return false;
  }
}

const nodeStack = StackDefinition(
  id: StackId.node,
  displayName: 'Node.js',
  markers: {'package.json'},
  tool: ToolProbe(binary: 'node', installUrl: 'https://nodejs.org/'),
  resolveCleanCommand: _resolveNode,
  artifacts: [
    ArtifactPath('node_modules', risk: CleanRisk.dependencies),
    ArtifactPath('.next/cache', risk: CleanRisk.cache),
    ArtifactPath('.nuxt', risk: CleanRisk.cache),
    ArtifactPath('.turbo', risk: CleanRisk.cache),
    ArtifactPath('.parcel-cache', risk: CleanRisk.cache),
    ArtifactPath('.svelte-kit', risk: CleanRisk.cache),
    ArtifactPath('.angular', risk: CleanRisk.cache),
  ],
  priority: 10,
);
