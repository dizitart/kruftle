// SPDX-License-Identifier: GPL-3.0-or-later

import '../../models/stack.dart';
import 'native.dart';

/// The C and C++ world beyond CMake and Make.
///
/// These share a habit worth knowing about: most of them build into a
/// directory the user names, not one the tool fixes. Where that is true the
/// stack declares no artifact paths at all and relies purely on its own clean
/// command, because guessing a build directory name is how a tool deletes
/// somebody's source.

const bazelStack = StackDefinition(
  id: StackId.bazel,
  displayName: 'Bazel',
  markers: {'WORKSPACE', 'WORKSPACE.bazel', 'MODULE.bazel'},
  tool: ToolProbe(binary: 'bazel', versionArgs: ['--version']),
  cleanCommand: CleanCommand('bazel', ['clean']),
  // `bazel-out` and friends are symlinks into an output base under
  // `~/.cache/bazel`. Deleting the link frees nothing and breaks the
  // workspace, so only the official clean is ever offered here.
  artifacts: [],
  priority: 25,
);

const mesonStack = StackDefinition(
  id: StackId.meson,
  displayName: 'Meson',
  markers: {'meson.build'},
  tool: ToolProbe(binary: 'meson', installUrl: 'https://mesonbuild.com/'),
  artifacts: [
    ArtifactPath('build'),
    ArtifactPath('builddir'),
    ArtifactPath('_build'),
  ],
  priority: 10,
);

const ninjaStack = StackDefinition(
  id: StackId.ninja,
  displayName: 'Ninja',
  markers: {'build.ninja'},
  tool: ToolProbe(binary: 'ninja', versionArgs: ['--version']),
  cleanCommand: CleanCommand('ninja', ['-t', 'clean']),
  artifacts: [ArtifactPath('.ninja_deps'), ArtifactPath('.ninja_log')],
  priority: 5,
);

CleanCommand? _autotoolsClean(DirListing listing) =>
    makeTargetCommand(listing, 'distclean');

const autotoolsStack = StackDefinition(
  id: StackId.autotools,
  displayName: 'Autotools',
  // `configure` alone is ambiguous; `configure.ac` or `Makefile.am` is not.
  markers: {'configure.ac', 'configure.in', 'Makefile.am'},
  tool: ToolProbe(binary: 'make'),
  // Deliberately `distclean`, not `clean`: it also removes the generated
  // Makefile and config.status, which is what actually costs the disk space.
  // Only once `configure` has generated that Makefile, though — an unbuilt or
  // already-distcleaned tree has no target to run.
  resolveCleanCommand: _autotoolsClean,
  artifacts: [ArtifactPath('autom4te.cache', risk: CleanRisk.cache)],
  priority: 8,
);

const conanStack = StackDefinition(
  id: StackId.conan,
  displayName: 'Conan',
  markers: {'conanfile.txt', 'conanfile.py'},
  tool: ToolProbe(binary: 'conan', installUrl: 'https://conan.io/downloads'),
  artifacts: [
    ArtifactPath('build'),
    // The per-project package cache, not the global one in `~/.conan2` —
    // that belongs to the global caches screen and its own confirmation.
    ArtifactPath('.conan', risk: CleanRisk.dependencies),
  ],
  priority: 12,
);

const vcpkgStack = StackDefinition(
  id: StackId.vcpkg,
  displayName: 'vcpkg',
  markers: {'vcpkg.json'},
  tool: ToolProbe(binary: 'vcpkg', installUrl: 'https://vcpkg.io/'),
  artifacts: [
    ArtifactPath('vcpkg_installed', risk: CleanRisk.dependencies),
    ArtifactPath('buildtrees', risk: CleanRisk.cache),
  ],
  priority: 12,
);

const platformioStack = StackDefinition(
  id: StackId.platformio,
  displayName: 'PlatformIO',
  markers: {'platformio.ini'},
  tool: ToolProbe(binary: 'pio', installUrl: 'https://platformio.org/install'),
  cleanCommand: CleanCommand('pio', ['run', '--target', 'clean']),
  artifacts: [
    ArtifactPath('.pio'),
    ArtifactPath('.pioenvs'),
    ArtifactPath('.piolibdeps', risk: CleanRisk.dependencies),
  ],
  priority: 20,
);
