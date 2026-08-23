// SPDX-License-Identifier: GPL-3.0-or-later

import '../../models/stack.dart';

const pythonStack = StackDefinition(
  id: StackId.python,
  displayName: 'Python',
  markers: {'setup.py', 'pyproject.toml', 'requirements.txt', 'Pipfile'},
  tool: ToolProbe(
    binary: 'python3',
    installUrl: 'https://www.python.org/downloads/',
  ),
  // Only setuptools offers a clean, and only when setup.py exists. Everything
  // else in Python land is convention, handled by the artifact list.
  resolveCleanCommand: _resolvePython,
  artifacts: [
    ArtifactPath('build'),
    ArtifactPath('dist'),
    ArtifactPath('.venv', risk: CleanRisk.dependencies),
    ArtifactPath('venv', risk: CleanRisk.dependencies),
    ArtifactPath('__pycache__', risk: CleanRisk.cache),
    ArtifactPath('.pytest_cache', risk: CleanRisk.cache),
    ArtifactPath('.mypy_cache', risk: CleanRisk.cache),
    ArtifactPath('.ruff_cache', risk: CleanRisk.cache),
    ArtifactPath('.tox', risk: CleanRisk.cache),
  ],
  priority: 10,
);

CleanCommand? _resolvePython(DirListing listing) => listing.hasFile('setup.py')
    ? const CleanCommand('python3', ['setup.py', 'clean', '--all'])
    : null;

const rubyStack = StackDefinition(
  id: StackId.ruby,
  displayName: 'Ruby',
  markers: {'Gemfile', 'Rakefile', '.gemspec'},
  tool: ToolProbe(binary: 'bundle', installUrl: 'https://bundler.io/'),
  artifacts: [
    ArtifactPath('pkg'),
    ArtifactPath('tmp', risk: CleanRisk.cache),
    ArtifactPath('vendor/bundle', risk: CleanRisk.dependencies),
  ],
  priority: 10,
);

const elixirStack = StackDefinition(
  id: StackId.elixir,
  displayName: 'Elixir',
  markers: {'mix.exs'},
  tool: ToolProbe(
    binary: 'mix',
    installUrl: 'https://elixir-lang.org/install.html',
  ),
  cleanCommand: CleanCommand('mix', ['clean']),
  artifacts: [
    ArtifactPath('_build'),
    ArtifactPath('deps', risk: CleanRisk.dependencies),
  ],
  priority: 10,
);
