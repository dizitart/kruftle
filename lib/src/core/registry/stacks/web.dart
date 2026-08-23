// SPDX-License-Identifier: GPL-3.0-or-later

import '../../models/stack.dart';

/// The lockfile names the package manager the project actually uses. Running a
/// different one would rewrite the lockfile, so we never guess wrong on
/// purpose: no lockfile means npm, which is the ecosystem default.
CleanCommand? _resolveNode(DirListing listing) {
  final manager = switch (listing) {
    _ when listing.hasFile('bun.lockb') || listing.hasFile('bun.lock') => 'bun',
    _ when listing.hasFile('pnpm-lock.yaml') => 'pnpm',
    _ when listing.hasFile('yarn.lock') => 'yarn',
    _ => 'npm',
  };
  // There is no standard clean for Node. Many projects define one; running it
  // is safe because it is the project's own script. When absent, the real win
  // is deleting node_modules, which is an opt-in artifact below.
  return CleanCommand(manager, ['run', 'clean']);
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
