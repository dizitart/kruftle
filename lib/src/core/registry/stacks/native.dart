// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:path/path.dart' as p;

import '../../models/stack.dart';

/// The names GNU make itself looks for, in its own order of preference.
const _makefileNames = ['GNUmakefile', 'makefile', 'Makefile'];

/// `make <target>` only when a Makefile here actually declares that target.
///
/// A Makefile is free to define no `clean` at all, and an Autotools tree loses
/// its Makefile to the first `distclean` — so running it blind fails with
/// ``No rule to make target `clean'`` and reports as a broken clean when
/// nothing is broken.
CleanCommand? makeTargetCommand(DirListing listing, String target) {
  if (listing.path.isEmpty) return null;
  for (final name in _makefileNames) {
    if (!listing.hasFile(name)) continue;
    try {
      final body = File(p.join(listing.path, name)).readAsStringSync();
      if (RegExp('^$target\\s*:', multiLine: true).hasMatch(body)) {
        return CleanCommand('make', [target]);
      }
    } on FileSystemException {
      // Unreadable Makefile: no command, fall back to allow-listed deletion.
    }
    return null; // make reads the first one it finds and no other.
  }
  return null;
}

const cmakeStack = StackDefinition(
  id: StackId.cmake,
  displayName: 'CMake',
  markers: {'CMakeLists.txt'},
  tool: ToolProbe(binary: 'cmake', installUrl: 'https://cmake.org/download/'),
  // Only meaningful once a build tree exists; the scanner skips stacks whose
  // artifacts are all absent, so this never runs on a pristine checkout.
  cleanCommand: CleanCommand('cmake', [
    '--build',
    'build',
    '--target',
    'clean',
  ]),
  artifacts: [
    ArtifactPath('build'),
    ArtifactPath('cmake-build-debug'),
    ArtifactPath('cmake-build-release'),
  ],
  priority: 5,
);

CleanCommand? _makeClean(DirListing listing) =>
    makeTargetCommand(listing, 'clean');

const makeStack = StackDefinition(
  id: StackId.make,
  displayName: 'Make',
  markers: {'Makefile', 'makefile', 'GNUmakefile'},
  tool: ToolProbe(binary: 'make', versionArgs: ['--version']),
  resolveCleanCommand: _makeClean,
  // Makefiles put output anywhere; we never guess. `make clean` or nothing.
  artifacts: [],
  priority: 1,
);

const dotnetStack = StackDefinition(
  id: StackId.dotnet,
  displayName: '.NET',
  markers: {'.csproj', '.fsproj', '.vbproj', '.sln'},
  matches: _isDotnetProject,
  tool: ToolProbe(
    binary: 'dotnet',
    installUrl: 'https://dotnet.microsoft.com/download',
  ),
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
  tool: ToolProbe(
    binary: 'swift',
    versionArgs: ['--version'],
    installUrl: 'https://swift.org/install/',
  ),
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
  artifacts: [
    ArtifactPath('build'),
    ArtifactPath('DerivedData', risk: CleanRisk.cache),
  ],
  priority: 15,
);

bool _isXcodeProject(DirListing listing) => listing.directories.any(
  (d) => d.endsWith('.xcodeproj') || d.endsWith('.xcworkspace'),
);
