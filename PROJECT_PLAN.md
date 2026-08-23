# Kruftle — Project Plan

> **Kruftle** reclaims disk space by finding every project under a directory,
> identifying its language/build tool, and running that toolchain's *own* clean
> command. Free, open source (GPL-3.0), Flutter desktop, macOS + Windows + Linux.

---

## 1. Fixed decisions

These were decided with the project owner and are **not** open for
re-litigation by a future session. Changing one is a deliberate act, not a
refactor.

| Decision | Value | Rationale |
|---|---|---|
| Name | **Kruftle** | From "cruft". Verified no Google/GitHub collision. |
| Package / bundle id | `com.dizitart.kruftle` | |
| Repo | `github.com/dizitart/kruftle` | Verified available. |
| License | **GPL-3.0-or-later** | Owner's choice. Every source file carries an SPDX header. |
| UI framework | Flutter (stable 3.44+), Material 3, dark-first | |
| State management | Riverpod (`flutter_riverpod` + `riverpod_generator`) | Testable without a widget tree; scan/clean state is long-lived and cancellable. |
| Auto-update | **Custom GitHub Releases updater** | Poll Releases API → verify SHA-256 from `checksums.txt` → download → hand off to OS installer → exit. Identical on 3 OSs, no Sparkle/appcast infra, no signing prerequisite. |
| Code signing | **None (unsigned / ad-hoc)** | macOS ad-hoc `.dmg` + documented quarantine removal; Windows Inno Setup `.exe` through SmartScreen; Linux AppImage + `.deb`. CI is structured so signing can be added later purely via secrets. |
| Aggressive cleaning | node_modules, global SDK caches, Python venv/`__pycache__` are all **supported but OFF by default**, opt-in per run | Owner explicitly enabled these. Default run remains "official clean commands only". |

### Design principle that governs everything

> **Prefer the toolchain's own clean command. Raw file deletion is the
> fallback of last resort, is always allow-listed by exact directory name,
> and always requires explicit user confirmation.**

The predecessor of this app is `/Volumes/External/codebase/cleanup/cleanup_build_artifacts.sh`,
which is the owner's hand-written bash script. Its detection matrix is the
seed for `StackRegistry`. Read it for intent.

---

## 2. Architecture

```
lib/
  main.dart                 # thin: runApp + ProviderScope + window setup
  src/
    core/                   # PURE DART. No flutter imports. 100% unit-testable.
      models/
        stack.dart          # StackId, StackDefinition, ToolStatus
        project.dart        # DetectedProject, ArtifactDir
        scan.dart           # ScanRequest, ScanProgress, ScanResult
        clean.dart          # CleanPlan, CleanStep, CleanOutcome, CleanReport
      registry/
        stack_registry.dart # THE extension point — see §3
        stacks/*.dart       # one file per stack family
      scan/
        project_scanner.dart# tree walk + detection
        sizer.dart          # parallel directory sizing (isolates)
      clean/
        cleaner.dart        # orchestrates a CleanPlan
        process_runner.dart # thin wrapper over Process.run (injectable for tests)
        safety.dart         # ALL the guard rails — see §4
      log/
        activity_log.dart   # JSONL structured log + export
      settings/
        settings.dart       # model + persistence (shared_preferences)
      update/
        updater.dart        # GitHub Releases check + download + verify + launch
    ui/
      app.dart
      theme/
      wizard/               # step 1..5 screens
      settings/
      widgets/
test/                       # mirrors lib/src/
```

**Rule:** `lib/src/core/**` must never `import 'package:flutter/...'`. There is
a test (`test/core/no_flutter_imports_test.dart`) that enforces this. This is
what makes the engine testable at speed and keeps a future CLI possible.

---

## 3. The extension point (how to add a language)

Adding a stack must mean **adding one file and one registry line, nothing else.**

```dart
const StackDefinition rust = StackDefinition(
  id: StackId.rust,
  displayName: 'Rust',
  // Any of these files in a dir marks it as this kind of project.
  markers: {'Cargo.toml'},
  // Binary probed on PATH to decide if the official clean is available.
  tool: ToolProbe(binary: 'cargo', versionArgs: ['--version']),
  // The official clean. Run with cwd = project root.
  cleanCommand: CleanCommand(executable: 'cargo', args: ['clean']),
  // Well-known dirs, relative to project root. Used for (a) size estimation
  // and (b) the raw-delete fallback when `tool` is absent.
  artifactDirs: {'target'},
);
```

Stacks needing logic (Gradle's `./gradlew` vs `gradle`, npm/yarn/pnpm/bun
selection) supply an optional `resolve` callback that inspects the project
directory and returns a concrete `CleanCommand`. **Do not** create a subclass
per language — the data class plus an optional hook covers every case in the
matrix, and one-implementation interfaces are how this codebase rots.

### Target stack matrix

Tier 1 (must ship in v1.0):
Rust/Cargo · Flutter · Dart · Maven · Gradle · Node (npm/yarn/pnpm/bun) ·
Python (setuptools/poetry/uv) · Go · CMake · Make · .NET · Swift/SPM · Xcode ·
Android/Gradle · Zig · Elixir/Mix · Ruby/Bundler

Tier 2 (post-1.0, same mechanism): Haskell/Stack · Scala/sbt · Clojure ·
Bazel · Nim · Crystal · Unity · Composer · Deno · Terraform `.terraform`

---

## 4. Safety rails (non-negotiable, all in `core/clean/safety.dart`)

Every one of these has a dedicated test. A future session must not weaken any
of them without the owner saying so.

1. **Containment** — a resolved delete/clean path must be *inside* the user's
   chosen scan root. Verified after `resolveSymbolicLinks`, not before.
2. **Forbidden roots** — refuse to scan or clean `/`, `$HOME`, `/Users`,
   `/System`, `/Library`, `C:\`, `C:\Windows`, `C:\Users`, `/etc`, `/usr`,
   `/var`, `/bin`, volume mount points, and any path with depth < 2.
3. **No symlink traversal** — the scanner never descends a symlinked dir; the
   cleaner never deletes *through* a symlink (it deletes the link, never the
   target — and by default doesn't touch links at all).
4. **Allow-list only** — raw deletion is permitted *only* for directory names
   present in the matched `StackDefinition.artifactDirs`. Never a glob, never
   a user-supplied pattern, never a file.
5. **Project-root anchored** — an artifact dir must be an immediate, expected
   child of a directory that was positively detected as that stack.
6. **Git-tracked guard** — if an artifact dir is tracked by git
   (`git ls-files --error-unmatch <dir>` succeeds), it is flagged and
   **excluded from the default selection**, because deleting it destroys
   committed content.
7. **Confirmation gate** — raw deletion (SDK-missing fallback, node_modules,
   venv, global caches) always requires an explicit per-category user opt-in
   *for that run*. Never remembered as a silent default.
8. **Timeouts** — every spawned clean process gets a timeout (default 300 s,
   configurable) and is killed on expiry; the step is recorded as failed, and
   the run continues.
9. **Cancellation** — the user can abort mid-run. In-flight processes are
   killed, no new steps start, and the partial result is still reported.
10. **Single instance per root** — a lock prevents two concurrent Kruftle runs
    over the same root.

---

## 5. Milestones

Each milestone ends **green**: `flutter analyze` clean and `flutter test` all
passing. TDD throughout — the test lands before or with the implementation.

### M0 — Foundations
- [x] `flutter create`, 3 desktop platforms, org `com.dizitart`
- [ ] GPL-3.0 `LICENSE`, SPDX headers, `analysis_options.yaml` (strict)
- [ ] Deps: riverpod, path, shared_preferences, http, crypto, package_info_plus, file (mem fs for tests)
- [ ] `test/core/no_flutter_imports_test.dart` guard
- **Verify:** `flutter analyze` = 0 issues, `flutter test` green.

### M1 — Detection core
- [ ] Models: `StackDefinition`, `ToolProbe`, `CleanCommand`, `DetectedProject`
- [ ] `StackRegistry` + all Tier-1 stack definitions
- [ ] `ToolchainProbe` — PATH lookup + version, cached per run
- **Verify:** table-driven tests over a synthetic fixture tree; every Tier-1 stack detected from its markers; toolchain probe mocked.

### M2 — Scanner
- [ ] `ProjectScanner` — bounded-depth walk, stop descending at a detected root, skip hidden/`node_modules`/`.git`, no symlink following
- [ ] Multi-stack projects (a dir that is both Flutter *and* Gradle) report **all** matches
- [ ] Progress stream + cancellation
- **Verify:** fixture tree with nested/edge cases; symlink loop test; cancellation test.

### M3 — Sizing & dry run
- [ ] `Sizer` — parallel `Isolate` pool computing artifact-dir byte totals
- [ ] `CleanPlan` produces a per-project and total **estimated** reclaim
- **Verify:** known-size fixture; concurrency does not change the total.

### M4 — Cleanup engine
- [ ] `ProcessRunner` interface + real impl + fake for tests
- [ ] `Cleaner` — bounded-concurrency execution, per-step outcome, timeout, cancel
- [ ] All 10 safety rails in `safety.dart`
- **Verify:** one test per safety rail (each must *fail closed*); fake runner asserts exact argv; timeout & cancel tests.

### M5 — Logging
- [ ] JSONL `ActivityLog` to app-support dir, rotation, levels
- [ ] Export to a user-chosen file
- **Verify:** round-trip parse; rotation at threshold.

### M6 — Settings
- [ ] Model + persistence: default roots, scan depth, concurrency, timeout, log level & retention, opt-in categories, update channel
- **Verify:** defaults, persistence round-trip, migration of unknown keys.

### M7 — Wizard UI
Steps: **1 Choose root → 2 Scan results → 3 Select → 4 Preview (dry run, skippable) → 5 Run → 6 Report**
- [ ] Keyboard-first: arrows, space to toggle, `a` select-all, `n` none, `/` filter, `Enter` advance
- [ ] Results table: project, stacks, tool availability badge, estimated size, git-tracked warning
- [ ] Live progress, per-project status, cancel button
- [ ] Report: freed vs estimated, failures with the actual stderr, "export log"
- **Verify:** widget tests per step; a golden for the results table.

### M8 — Global caches module
- [ ] Separate screen, its own confirmation, per-cache sizes (`~/.gradle/caches`, `~/.cargo/registry`, `~/.pub-cache`, `~/.m2/repository`, `~/.npm`, `~/.gradle/wrapper`, Go module cache via `go clean -modcache`)
- **Verify:** path resolution per OS; nothing runs without explicit confirm.

### M9 — Auto-updater
- [ ] Version check against Releases API, respect `settings.updateChannel`
- [ ] Download + SHA-256 verify against release `checksums.txt` (**refuse on mismatch**)
- [ ] Platform hand-off: macOS open `.dmg`; Windows run installer `/SILENT`; Linux replace AppImage in place
- **Verify:** fake HTTP client; checksum-mismatch test must refuse; no-update / network-failure paths.

### M10 — Branding & assets
- [ ] Icon (SVG source → `.icns`, `.ico`, PNG set), in-app logo, `README` screenshots

### M11 — Packaging & CI
- [ ] GitHub Actions: analyze + test on push/PR (3 OSs)
- [ ] Release workflow on `v*` tag → `.dmg`, Inno Setup `.exe`, AppImage + `.deb`, plus `checksums.txt`
- [ ] `CONTRIBUTING.md`, `SECURITY.md`, issue templates
- [ ] Push to `dizitart/kruftle`, first tagged release

---

## 6. Definition of done

- `flutter analyze` reports zero issues.
- `flutter test` fully green, core engine meaningfully covered.
- App builds and runs on all three desktop OSs.
- A release tag produces installers for all three OSs plus checksums.
- An installed older build updates itself to a newer release.
- Adding a new language = one new file in `registry/stacks/` + one registry line.
