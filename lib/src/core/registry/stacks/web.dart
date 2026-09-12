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

/// Turborepo and Nx are almost always layered on top of an existing Node
/// project (see [nodeStack] above), so this stack's only real job is
/// offering their *official* cache-reset commands -- something neither
/// `npm run clean` nor the generic Node artifact list (which already
/// raw-deletes `.turbo`, opt-in) can express. `nodeStack`'s single
/// `resolveCleanCommand` slot is already spoken for by the package-manager
/// clean-script logic, so this is a separate stack rather than folded in.
CleanCommand? _resolveMonorepoCache(DirListing listing) {
  // A repo can genuinely carry both files (a project mid-migration between
  // tools, or Nx orchestrating a Turborepo-configured app); Turborepo's own
  // daemon reset is the narrower, faster one, so it wins when both exist.
  if (listing.hasFile('turbo.json')) {
    return const CleanCommand('npx', ['turbo', 'daemon', 'clean']);
  }
  if (listing.hasFile('nx.json')) {
    return const CleanCommand('npx', ['nx', 'reset']);
  }
  return null;
}

const monorepoCacheStack = StackDefinition(
  id: StackId.monorepoCache,
  displayName: 'Turborepo / Nx',
  markers: {'turbo.json', 'nx.json'},
  tool: ToolProbe(binary: 'npx', installUrl: 'https://nodejs.org/'),
  resolveCleanCommand: _resolveMonorepoCache,
  // `.turbo` is deliberately not listed here: `nodeStack` already owns it
  // (workspace packages get one without a `turbo.json` of their own), and a
  // path listed by two matching stacks is measured and deleted twice.
  artifacts: [ArtifactPath('.nx/cache', risk: CleanRisk.cache)],
  priority: 11,
);
