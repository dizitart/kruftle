// SPDX-License-Identifier: GPL-3.0-or-later

import '../../models/stack.dart';

/// The younger systems languages, plus the scientific and scripting stacks
/// that leave build output behind.

const nimStack = StackDefinition(
  id: StackId.nim,
  displayName: 'Nim',
  markers: {'.nimble', 'nim.cfg', 'config.nims'},
  matches: _isNimProject,
  tool: ToolProbe(
    binary: 'nimble',
    installUrl: 'https://nim-lang.org/install.html',
  ),
  artifacts: [
    ArtifactPath('nimcache', risk: CleanRisk.cache),
    ArtifactPath('.nimble', risk: CleanRisk.dependencies),
  ],
  priority: 20,
);

/// `.nimble` is named after the package, so it is matched by extension.
bool _isNimProject(DirListing listing) =>
    listing.files.any((f) => f.endsWith('.nimble')) ||
    listing.hasFile('nim.cfg') ||
    listing.hasFile('config.nims');

const crystalStack = StackDefinition(
  id: StackId.crystal,
  displayName: 'Crystal',
  markers: {'shard.yml'},
  tool: ToolProbe(
    binary: 'shards',
    installUrl: 'https://crystal-lang.org/install/',
  ),
  artifacts: [
    ArtifactPath('bin'),
    ArtifactPath('lib', risk: CleanRisk.dependencies),
    ArtifactPath('.shards', risk: CleanRisk.cache),
  ],
  priority: 20,
);

const dlangStack = StackDefinition(
  id: StackId.dlang,
  displayName: 'D',
  markers: {'dub.json', 'dub.sdl'},
  tool: ToolProbe(binary: 'dub', installUrl: 'https://dub.pm/'),
  cleanCommand: CleanCommand('dub', ['clean']),
  artifacts: [ArtifactPath('.dub', risk: CleanRisk.cache)],
  priority: 20,
);

const fortranStack = StackDefinition(
  id: StackId.fortran,
  displayName: 'Fortran',
  markers: {'fpm.toml'},
  tool: ToolProbe(binary: 'fpm', installUrl: 'https://fpm.fortran-lang.org/'),
  cleanCommand: CleanCommand('fpm', ['clean', '--all']),
  artifacts: [ArtifactPath('build')],
  priority: 20,
);

const adaStack = StackDefinition(
  id: StackId.ada,
  displayName: 'Ada',
  markers: {'alire.toml'},
  tool: ToolProbe(binary: 'alr', installUrl: 'https://alire.ada.dev/'),
  cleanCommand: CleanCommand('alr', ['clean']),
  artifacts: [
    ArtifactPath('obj'),
    ArtifactPath('alire', risk: CleanRisk.dependencies),
  ],
  priority: 20,
);

const denoStack = StackDefinition(
  id: StackId.deno,
  displayName: 'Deno',
  markers: {'deno.json', 'deno.jsonc'},
  tool: ToolProbe(binary: 'deno', installUrl: 'https://deno.land/'),
  // Deno's per-project output is only what the user configures; the real
  // weight lives in the global cache, which has its own screen.
  artifacts: [ArtifactPath('.deno', risk: CleanRisk.cache)],
  priority: 25,
);

const composerStack = StackDefinition(
  id: StackId.composer,
  displayName: 'PHP / Composer',
  markers: {'composer.json'},
  tool: ToolProbe(binary: 'composer', installUrl: 'https://getcomposer.org/'),
  artifacts: [ArtifactPath('vendor', risk: CleanRisk.dependencies)],
  priority: 20,
);

const terraformStack = StackDefinition(
  id: StackId.terraform,
  displayName: 'Terraform',
  markers: {'.terraform.lock.hcl', 'main.tf'},
  tool: ToolProbe(
    binary: 'terraform',
    installUrl: 'https://terraform.io/downloads',
  ),
  // Providers are large binaries re-fetched by `terraform init`, which makes
  // them dependencies rather than build output — the opt-in gate applies.
  artifacts: [ArtifactPath('.terraform', risk: CleanRisk.dependencies)],
  priority: 15,
);

const unityStack = StackDefinition(
  id: StackId.unity,
  displayName: 'Unity',
  markers: {'ProjectSettings', 'Assets'},
  matches: _isUnityProject,
  // Unity has no headless clean worth invoking; these directories are
  // regenerated on the next editor launch, at the cost of a reimport.
  artifacts: [
    ArtifactPath('Library', risk: CleanRisk.cache),
    ArtifactPath('Temp', risk: CleanRisk.cache),
    ArtifactPath('Obj'),
    ArtifactPath('Build'),
    ArtifactPath('Logs', risk: CleanRisk.cache),
  ],
  priority: 30,
);

/// Both directories, not either: `Assets` alone is far too common a folder
/// name to claim a directory on.
bool _isUnityProject(DirListing listing) =>
    listing.hasDirectory('ProjectSettings') && listing.hasDirectory('Assets');

const juliaStack = StackDefinition(
  id: StackId.julia,
  displayName: 'Julia',
  markers: {'Project.toml', 'JuliaProject.toml'},
  matches: _isJuliaProject,
  tool: ToolProbe(
    binary: 'julia',
    installUrl: 'https://julialang.org/downloads/',
  ),
  artifacts: [ArtifactPath('docs/build')],
  priority: 15,
);

/// `Project.toml` is Julia's, but a bare one next to `Cargo.toml` would be
/// something else entirely; requiring the manifest or the Julia-specific name
/// keeps the false positives out.
bool _isJuliaProject(DirListing listing) =>
    listing.hasFile('JuliaProject.toml') ||
    (listing.hasFile('Project.toml') && listing.hasFile('Manifest.toml'));

const rlangStack = StackDefinition(
  id: StackId.rlang,
  displayName: 'R',
  markers: {'DESCRIPTION', 'renv.lock'},
  matches: _isRProject,
  tool: ToolProbe(binary: 'R', versionArgs: ['--version']),
  artifacts: [
    ArtifactPath('renv/library', risk: CleanRisk.dependencies),
    ArtifactPath('.Rproj.user', risk: CleanRisk.cache),
  ],
  priority: 15,
);

/// `DESCRIPTION` is generic enough that it needs corroboration.
bool _isRProject(DirListing listing) =>
    listing.hasFile('renv.lock') ||
    (listing.hasFile('DESCRIPTION') && listing.hasFile('NAMESPACE')) ||
    listing.files.any((f) => f.endsWith('.Rproj'));

const perlStack = StackDefinition(
  id: StackId.perl,
  displayName: 'Perl',
  markers: {'Makefile.PL', 'Build.PL', 'cpanfile'},
  tool: ToolProbe(binary: 'perl', versionArgs: ['--version']),
  artifacts: [
    ArtifactPath('blib'),
    ArtifactPath('_build'),
    ArtifactPath('local', risk: CleanRisk.dependencies),
  ],
  priority: 15,
);
