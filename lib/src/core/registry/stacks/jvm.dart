// SPDX-License-Identifier: GPL-3.0-or-later

import '../../models/stack.dart';

/// Prefer the project's own wrapper over a global install: the wrapper pins the
/// version the project was built with, and it is what CI uses.
CleanCommand? _resolveMaven(DirListing listing) {
  if (listing.hasFile('mvnw')) return const CleanCommand('./mvnw', ['clean']);
  if (listing.hasFile('mvnw.cmd')) return const CleanCommand('mvnw.cmd', ['clean']);
  return const CleanCommand('mvn', ['clean']);
}

const mavenStack = StackDefinition(
  id: StackId.maven,
  displayName: 'Maven',
  markers: {'pom.xml'},
  tool: ToolProbe(binary: 'mvn', installUrl: 'https://maven.apache.org/install.html'),
  resolveCleanCommand: _resolveMaven,
  artifacts: [ArtifactPath('target')],
  priority: 20,
);

CleanCommand? _resolveGradle(DirListing listing) {
  if (listing.hasFile('gradlew')) return const CleanCommand('./gradlew', ['clean']);
  if (listing.hasFile('gradlew.bat')) return const CleanCommand('gradlew.bat', ['clean']);
  return const CleanCommand('gradle', ['clean']);
}

const gradleStack = StackDefinition(
  id: StackId.gradle,
  displayName: 'Gradle',
  markers: {'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts'},
  tool: ToolProbe(binary: 'gradle', installUrl: 'https://gradle.org/install/'),
  resolveCleanCommand: _resolveGradle,
  artifacts: [
    ArtifactPath('build'),
    ArtifactPath('.gradle', risk: CleanRisk.cache),
  ],
  priority: 20,
);
