// SPDX-License-Identifier: GPL-3.0-or-later

import '../../models/stack.dart';

const cmakeStack = StackDefinition(
  id: StackId.cmake,
  displayName: 'CMake',
  markers: {'CMakeLists.txt'},
  tool: ToolProbe(binary: 'cmake', installUrl: 'https://cmake.org/download/'),
  // Only meaningful once a build tree exists; the scanner skips stacks whose
  // artifacts are all absent, so this never runs on a pristine checkout.
  cleanCommand: CleanCommand('cmake', ['--build', 'build', '--target', 'clean']),
  artifacts: [ArtifactPath('build'), ArtifactPath('cmake-build-debug'), ArtifactPath('cmake-build-release')],
  priority: 5,
);

const makeStack = StackDefinition(
  id: StackId.make,
  displayName: 'Make',
  markers: {'Makefile', 'makefile', 'GNUmakefile'},
  tool: ToolProbe(binary: 'make', versionArgs: ['--version']),
  cleanCommand: CleanCommand('make', ['clean']),
  // Makefiles put output anywhere; we never guess. `make clean` or nothing.
  artifacts: [],
  priority: 1,
);

const dotnetStack = StackDefinition(
  id: StackId.dotnet,
  displayName: '.NET',
  markers: {'.csproj', '.fsproj', '.vbproj', '.sln'},
  matches: _isDotnetProject,
  tool: ToolProbe(binary: 'dotnet', installUrl: 'https://dotnet.microsoft.com/download'),
  cleanCommand: CleanCommand('dotnet', ['clean']),
  artifacts: [ArtifactPath('bin'), ArtifactPath('obj')],
  priority: 20,
);

/// .NET project files are named after the project, so we match by extension.
bool _isDotnetProject(DirListing listing) => listing.files.any(
      (f) =>
          f.endsWith('.csproj') ||
          f.endsWith('.fsproj') ||
          f.endsWith('.vbproj') ||
          f.endsWith('.sln'),
    );

const swiftStack = StackDefinition(
  id: StackId.swift,
  displayName: 'Swift Package',
  markers: {'Package.swift'},
  tool: ToolProbe(binary: 'swift', versionArgs: ['--version'], installUrl: 'https://swift.org/install/'),
  cleanCommand: CleanCommand('swift', ['package', 'clean']),
  artifacts: [ArtifactPath('.build')],
  priority: 20,
);

const xcodeStack = StackDefinition(
  id: StackId.xcode,
  displayName: 'Xcode',
  markers: {'.xcodeproj', '.xcworkspace'},
  matches: _isXcodeProject,
  tool: ToolProbe(binary: 'xcodebuild', versionArgs: ['-version']),
  cleanCommand: CleanCommand('xcodebuild', ['clean']),
  artifacts: [ArtifactPath('build'), ArtifactPath('DerivedData', risk: CleanRisk.cache)],
  priority: 15,
);

bool _isXcodeProject(DirListing listing) => listing.directories.any(
      (d) => d.endsWith('.xcodeproj') || d.endsWith('.xcworkspace'),
    );
