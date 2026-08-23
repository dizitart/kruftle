// SPDX-License-Identifier: GPL-3.0-or-later

import '../../models/stack.dart';

/// A Flutter project is a pub package that depends on the Flutter SDK. The
/// generated platform folders are the cheapest reliable signal that does not
/// require parsing YAML.
bool _isFlutterProject(DirListing listing) =>
    listing.hasFile('pubspec.yaml') &&
    (listing.hasDirectory('android') ||
        listing.hasDirectory('ios') ||
        listing.hasDirectory('macos') ||
        listing.hasDirectory('windows') ||
        listing.hasDirectory('linux') ||
        listing.hasDirectory('web'));

const flutterStack = StackDefinition(
  id: StackId.flutter,
  displayName: 'Flutter',
  markers: {'pubspec.yaml'},
  matches: _isFlutterProject,
  tool: ToolProbe(binary: 'flutter', installUrl: 'https://docs.flutter.dev/get-started/install'),
  cleanCommand: CleanCommand('flutter', ['clean']),
  artifacts: [
    ArtifactPath('build'),
    ArtifactPath('.dart_tool', risk: CleanRisk.cache),
  ],
  priority: 30,
);

/// Plain Dart: a pub package that is not a Flutter app.
bool _isDartProject(DirListing listing) =>
    listing.hasFile('pubspec.yaml') && !_isFlutterProject(listing);

const dartStack = StackDefinition(
  id: StackId.dart,
  displayName: 'Dart',
  markers: {'pubspec.yaml'},
  matches: _isDartProject,
  tool: ToolProbe(binary: 'dart', installUrl: 'https://dart.dev/get-dart'),
  // `dart` has no clean subcommand; .dart_tool is the documented output.
  artifacts: [
    ArtifactPath('.dart_tool', risk: CleanRisk.cache),
    ArtifactPath('build'),
  ],
  priority: 20,
);
