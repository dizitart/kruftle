# Good first issues — stacks to add

Eight issues to open on the tracker, one per missing stack. Each is genuinely
small: one file in `lib/src/core/registry/stacks/` and one line in
`stack_registry.dart`. Each also opens a door to a community worth talking to.

Label every one `enhancement`, `stack-support`, `good first issue`.

Before opening, sanity-check the marker file and clean command — these are
drafted from public documentation, not from a running install of each tool.

---

### 1. Godot 4

**Title:** Add Godot 4 support (`project.godot`)

Godot projects accumulate an import cache and export output that can run to
several gigabytes on a mid-sized game, and none of it is precious.

- **Marker:** `project.godot`
- **Artifact dirs:** `.godot/`, `.import/` (Godot 3), `build/`, `export/`
- **Clean command:** none official — Godot regenerates `.godot/` on next open,
  so this is an allow-listed raw delete
- **Note for the implementer:** this is a good example of a stack whose
  fallback path is the *only* path. Worth checking how the registry expresses
  "no clean command, allow-listed dirs only".

---

### 2. Unreal Engine

**Title:** Add Unreal Engine support (`*.uproject`)

Unreal is probably the single largest disk offender on this list — an
`Intermediate/` plus `DerivedDataCache/` regularly passes 50 GB.

- **Marker:** any `*.uproject` file in the directory
- **Artifact dirs:** `Binaries/`, `Intermediate/`, `Saved/`, `DerivedDataCache/`
- **Clean command:** none portable; raw delete of the allow-listed dirs
- **Note:** `Saved/` holds crash logs and *sometimes* user config, so it
  probably belongs at `CleanRisk.cache` rather than `buildOutput`. Worth a
  discussion on the issue before the PR.

---

### 3. CocoaPods

**Title:** Add CocoaPods support (`Podfile`)

- **Marker:** `Podfile`
- **Artifact dirs:** `Pods/`
- **Clean command:** `pod cache clean --all` cleans the global cache, but the
  per-project `Pods/` directory is restored by `pod install`
- **Note:** `Pods/` is downloaded dependencies, so `CleanRisk.dependencies` —
  off by default, opt-in per run.

---

### 4. Turborepo and Nx

**Title:** Add Turborepo / Nx cache support (`turbo.json`, `nx.json`)

Monorepo build caches grow without bound and nobody ever clears them.

- **Markers:** `turbo.json` / `nx.json`
- **Artifact dirs:** `.turbo/`, `.nx/cache/`
- **Clean commands:** `npx turbo daemon clean` / `npx nx reset`
- **Note:** both sit alongside a `package.json`, so this is a good test of how
  the registry handles two stacks matching the same directory.

---

### 5. Elm

**Title:** Add Elm support (`elm.json`)

- **Marker:** `elm.json`
- **Artifact dirs:** `elm-stuff/`
- **Clean command:** none official; `elm-stuff/` is fully regenerable
- **Note:** small, self-contained, and a genuinely nice first PR.

---

### 6. PureScript

**Title:** Add PureScript support (`spago.yaml`)

- **Markers:** `spago.yaml`, `spago.dhall` (older projects)
- **Artifact dirs:** `output/`, `.spago/`
- **Clean command:** none official
- **Note:** `output/` is a dangerously generic directory name — this stack is a
  good argument for the marker-file requirement, and worth saying so in the PR.

---

### 7. LaTeX

**Title:** Add LaTeX support (`latexmk`)

Every thesis directory is full of `.aux`, `.fls`, `.fdb_latexmk` and a `build/`
that nobody has ever deliberately kept.

- **Marker:** a `*.tex` file plus `latexmkrc`, or a `Makefile` with a `latexmk`
  rule
- **Artifact dirs:** `build/`, `out/`
- **Clean command:** `latexmk -C`
- **Note:** detection is the interesting part here — a bare `*.tex` is too
  loose a marker to be safe. Worth discussing on the issue first.

---

### 8. Jupyter and ML experiment output

**Title:** Add support for notebook and ML experiment artifacts

- **Markers:** `*.ipynb`, `mlruns/`, `wandb/settings`
- **Artifact dirs:** `.ipynb_checkpoints/`, `mlruns/`, `wandb/`,
  `lightning_logs/`, `outputs/` (Hydra)
- **Clean command:** none
- **Note:** these are *results*, not build output — several are things a
  researcher would be upset to lose. This one probably needs a risk category
  of its own, and should be off by default and clearly labelled. Discuss
  before implementing.

---

## Issue body template

```
**Language or build tool:** <name>

**What file marks a project of this kind?** <marker>

**The official clean command:** <command, or "none — allow-listed raw delete">

**Where does it put build output?** <dirs>

---

Adding a stack is one file in `lib/src/core/registry/stacks/` plus one line in
`stack_registry.dart` — see CONTRIBUTING.md. Happy to walk anyone through
their first one; comment here and I'll help.
```
