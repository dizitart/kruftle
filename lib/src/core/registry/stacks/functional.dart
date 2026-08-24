// SPDX-License-Identifier: GPL-3.0-or-later

import '../../models/stack.dart';

/// Haskell, the ML family, the BEAM and the Lisps.
///
/// These build into deep, densely populated output trees — a Haskell
/// `.stack-work` or a Scala `target` routinely outweighs the source it came
/// from by two orders of magnitude — so they are worth having even though the
/// toolchains themselves are less common.

const haskellStack = StackDefinition(
  id: StackId.haskell,
  displayName: 'Haskell',
  markers: {'stack.yaml', 'cabal.project'},
  tool: ToolProbe(binary: 'stack', installUrl: 'https://haskellstack.org/'),
  matches: _isStackProject,
  cleanCommand: CleanCommand('stack', ['clean']),
  artifacts: [ArtifactPath('.stack-work'), ArtifactPath('dist-newstyle')],
  priority: 25,
);

/// Cabal without Stack. Separate from [haskellStack] because the two use
/// different commands and a project can genuinely have only one of them.
const cabalStack = StackDefinition(
  id: StackId.cabal,
  displayName: 'Cabal',
  markers: {'.cabal'},
  matches: _isCabalProject,
  tool: ToolProbe(
    binary: 'cabal',
    installUrl: 'https://www.haskell.org/cabal/',
  ),
  cleanCommand: CleanCommand('cabal', ['clean']),
  artifacts: [ArtifactPath('dist'), ArtifactPath('dist-newstyle')],
  priority: 20,
);

/// A `.cabal` file is named after the package, so it is matched by extension.
bool _isCabalProject(DirListing listing) =>
    listing.files.any((f) => f.endsWith('.cabal')) &&
    !listing.hasFile('stack.yaml');

bool _isStackProject(DirListing listing) =>
    listing.hasFile('stack.yaml') || listing.hasFile('cabal.project');

const sbtStack = StackDefinition(
  id: StackId.sbt,
  displayName: 'sbt',
  markers: {'build.sbt'},
  tool: ToolProbe(binary: 'sbt', installUrl: 'https://www.scala-sbt.org/'),
  cleanCommand: CleanCommand('sbt', ['clean']),
  artifacts: [
    ArtifactPath('target'),
    ArtifactPath('project/target'),
    ArtifactPath('project/project'),
  ],
  priority: 30,
);

const clojureStack = StackDefinition(
  id: StackId.clojure,
  displayName: 'Clojure',
  markers: {'project.clj', 'deps.edn', 'build.boot'},
  // Leiningen if it is a Leiningen project, otherwise nothing to run: the
  // tools.deps CLI has no clean at all, and `target/` is the whole story.
  resolveCleanCommand: _clojureClean,
  tool: ToolProbe(binary: 'lein', installUrl: 'https://leiningen.org/'),
  artifacts: [
    ArtifactPath('target'),
    ArtifactPath('.cpcache', risk: CleanRisk.cache),
  ],
  priority: 20,
);

CleanCommand? _clojureClean(DirListing listing) =>
    listing.hasFile('project.clj')
    ? const CleanCommand('lein', ['clean'])
    : null;

const erlangStack = StackDefinition(
  id: StackId.erlang,
  displayName: 'Erlang',
  markers: {'rebar.config'},
  tool: ToolProbe(binary: 'rebar3', installUrl: 'https://rebar3.org/'),
  cleanCommand: CleanCommand('rebar3', ['clean']),
  artifacts: [
    ArtifactPath('_build'),
    ArtifactPath('deps', risk: CleanRisk.dependencies),
  ],
  priority: 20,
);

const ocamlStack = StackDefinition(
  id: StackId.ocaml,
  displayName: 'OCaml',
  markers: {'dune-project'},
  tool: ToolProbe(binary: 'dune', installUrl: 'https://dune.build/install'),
  cleanCommand: CleanCommand('dune', ['clean']),
  artifacts: [ArtifactPath('_build')],
  priority: 20,
);

const gleamStack = StackDefinition(
  id: StackId.gleam,
  displayName: 'Gleam',
  markers: {'gleam.toml'},
  tool: ToolProbe(
    binary: 'gleam',
    installUrl: 'https://gleam.run/getting-started/',
  ),
  cleanCommand: CleanCommand('gleam', ['clean']),
  artifacts: [ArtifactPath('build')],
  priority: 25,
);
