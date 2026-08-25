// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:collection/collection.dart';

/// Identifiers for every language / build-tool family Kruftle understands.
///
/// Adding a value here is step one of adding language support; see
/// `lib/src/core/registry/stack_registry.dart` for the other two steps.
enum StackId {
  rust,
  flutter,
  dart,
  maven,
  gradle,
  node,
  python,
  go,
  cmake,
  make,
  dotnet,
  swift,
  xcode,
  zig,
  elixir,
  ruby,

  // Tier 2, added in v0.2.0. Same mechanism, same data class — see
  // PROJECT_PLAN.md §3.
  bazel,
  meson,
  ninja,
  autotools,
  conan,
  vcpkg,
  platformio,
  haskell,
  cabal,
  sbt,
  clojure,
  erlang,
  ocaml,
  gleam,
  nim,
  crystal,
  dlang,
  fortran,
  ada,
  deno,
  composer,
  terraform,
  unity,
  julia,
  rlang,
  perl,

  /// Every user-defined profile. Profiles are told apart by display name, not
  /// by id — see `core/profiles/profile.dart`. Nothing downstream keys off
  /// the id, so one shared value is enough.
  custom,
}

/// What kind of data an artifact path holds, which decides how dangerous it is
/// to remove and therefore whether the user must opt in for that run.
enum CleanRisk {
  /// Pure compiler/build output. Always regenerable by rebuilding. Cleaned by
  /// default when the user selects the project.
  buildOutput,

  /// Downloaded third-party dependencies (`node_modules`, `.venv`). Fully
  /// reproducible from a lockfile or manifest, but re-fetching costs network
  /// and time, so removal requires an explicit per-run opt-in.
  dependencies,

  /// Incremental / tooling caches (`.mypy_cache`, `.turbo`). Regenerated on
  /// demand; removal costs only a slower next build. Opt-in.
  cache,
}

/// A binary Kruftle looks for on `PATH` to decide whether the *official* clean
/// command for a stack can be run on this machine.
class ToolProbe {
  const ToolProbe({
    required this.binary,
    this.versionArgs = const ['--version'],
    this.installUrl,
  });

  /// Executable name, without extension. Windows resolution appends the
  /// entries of `PATHEXT` itself.
  final String binary;

  /// Arguments that make the binary print its version, used to confirm it is
  /// really the tool we think it is and to record it in the activity log.
  final List<String> versionArgs;

  /// Shown to the user when the tool is missing, so they can install it
  /// instead of falling back to raw deletion.
  final String? installUrl;
}

/// A concrete process invocation, run with the project root as its working
/// directory.
class CleanCommand {
  const CleanCommand(this.executable, [this.args = const []]);

  final String executable;
  final List<String> args;

  @override
  String toString() => [executable, ...args].join(' ');

  @override
  bool operator ==(Object other) =>
      other is CleanCommand &&
      other.executable == executable &&
      const ListEquality<String>().equals(other.args, args);

  @override
  int get hashCode => Object.hash(executable, Object.hashAll(args));
}

/// A well-known directory or file produced by a build, relative to the project
/// root.
///
/// Two jobs: it is what the scanner measures to estimate reclaimable space,
/// and it is the *allow-list* for raw deletion when the official tool is
/// missing. Nothing outside this list is ever deleted directly.
class ArtifactPath {
  const ArtifactPath(this.relative, {this.risk = CleanRisk.buildOutput});

  /// Relative to the project root. May contain separators (`.next/cache`).
  /// Never a glob — see safety rail 4.
  final String relative;

  final CleanRisk risk;

  @override
  bool operator ==(Object other) =>
      other is ArtifactPath && other.relative == relative && other.risk == risk;

  @override
  int get hashCode => Object.hash(relative, risk);

  @override
  String toString() => relative;
}

/// The names of the entries directly inside a candidate directory.
///
/// Detection and command resolution both need to know "what is in this
/// folder", so we list it once and pass the result around as plain data. That
/// keeps every detector and resolver a pure function, which is what makes the
/// registry testable without touching a disk.
class DirListing {
  const DirListing({
    this.path = '',
    this.files = const {},
    this.directories = const {},
  });

  /// Absolute path of the directory, so a resolver that has to look *inside* a
  /// file — does this `package.json` declare a `clean` script? — can.
  final String path;

  final Set<String> files;
  final Set<String> directories;

  bool hasFile(String name) => files.contains(name);

  bool hasDirectory(String name) => directories.contains(name);

  bool has(String name) => hasFile(name) || hasDirectory(name);

  bool hasAnyFile(Iterable<String> names) => names.any(hasFile);
}

/// Chooses the actual clean command for a project whose invocation depends on
/// what is in the directory — `./gradlew` versus a global `gradle`, or npm
/// versus pnpm. Returns null when this project has no runnable official clean.
typedef CleanResolver = CleanCommand? Function(DirListing listing);

/// Decides whether a directory is a project of this kind.
///
/// Defaults to "any marker file is present", which covers most stacks; a stack
/// with a subtler rule (Flutter vs plain Dart both use `pubspec.yaml`) supplies
/// its own.
typedef StackMatcher = bool Function(DirListing listing);

/// Everything Kruftle knows about one language / build-tool family.
///
/// This is deliberately a data class with two optional function hooks rather
/// than a base class with a subclass per language: every stack in the matrix is
/// expressible this way, and a one-implementation-per-language hierarchy is
/// pure ceremony.
class StackDefinition {
  const StackDefinition({
    required this.id,
    required this.displayName,
    required this.markers,
    required this.artifacts,
    this.tool,
    this.cleanCommand,
    this.resolveCleanCommand,
    this.matches,
    this.priority = 0,
  });

  final StackId id;
  final String displayName;

  /// Files (or directories) whose presence marks a directory as this kind of
  /// project.
  final Set<String> markers;

  /// The tool that must exist on `PATH` for [cleanCommand] to be runnable.
  /// Null means this stack has no official clean command at all and can only
  /// ever be cleaned by allow-listed deletion.
  final ToolProbe? tool;

  /// The official clean, for stacks whose invocation never varies.
  final CleanCommand? cleanCommand;

  /// Used instead of [cleanCommand] when the invocation depends on the
  /// project's contents.
  final CleanResolver? resolveCleanCommand;

  /// Custom detection rule; defaults to "any marker present".
  final StackMatcher? matches;

  /// Well-known build output, dependency and cache locations.
  final List<ArtifactPath> artifacts;

  /// Higher wins when two stacks in the same directory would otherwise be
  /// reported in arbitrary order. Purely presentational.
  final int priority;

  bool detect(DirListing listing) =>
      matches?.call(listing) ?? listing.markers(markers);

  /// The command to run for this project, or null if there is none to run.
  CleanCommand? commandFor(DirListing listing) =>
      resolveCleanCommand?.call(listing) ?? cleanCommand;

  Iterable<ArtifactPath> artifactsAtRisk(Set<CleanRisk> allowed) =>
      artifacts.where((a) => allowed.contains(a.risk));
}

extension on DirListing {
  bool markers(Set<String> names) => names.any(has);
}
