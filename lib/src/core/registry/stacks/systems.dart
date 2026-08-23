// SPDX-License-Identifier: GPL-3.0-or-later

import '../../models/stack.dart';

const rustStack = StackDefinition(
  id: StackId.rust,
  displayName: 'Rust',
  markers: {'Cargo.toml'},
  tool: ToolProbe(binary: 'cargo', installUrl: 'https://rustup.rs'),
  cleanCommand: CleanCommand('cargo', ['clean']),
  artifacts: [ArtifactPath('target')],
  priority: 10,
);

const goStack = StackDefinition(
  id: StackId.go,
  displayName: 'Go',
  markers: {'go.mod'},
  tool: ToolProbe(binary: 'go', versionArgs: ['version'], installUrl: 'https://go.dev/dl/'),
  // -cache is the build cache, -testcache the test results cache. Module cache
  // (-modcache) is global, not per project, so it lives in the global-caches
  // screen instead.
  cleanCommand: CleanCommand('go', ['clean', '-cache', '-testcache']),
  artifacts: [ArtifactPath('bin', risk: CleanRisk.buildOutput)],
  priority: 10,
);

const zigStack = StackDefinition(
  id: StackId.zig,
  displayName: 'Zig',
  markers: {'build.zig'},
  tool: ToolProbe(binary: 'zig', versionArgs: ['version'], installUrl: 'https://ziglang.org/download/'),
  // Zig has no `clean` subcommand; its output dirs are stable and documented.
  artifacts: [
    ArtifactPath('zig-out'),
    ArtifactPath('zig-cache', risk: CleanRisk.cache),
    ArtifactPath('.zig-cache', risk: CleanRisk.cache),
  ],
  priority: 10,
);
