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
| Motion | Hand-written `CustomPainter` animations, **no Rive/Lottie** | The animations wanted here — sweeps, counters, progress — are geometry over time. A runtime plus an asset pipeline plus a licence audit to draw an arc is the trade this project exists to avoid. Revisit only if real `.riv` art shows up. |
| Localisation | `gen-l10n` + ARB, ten locales | Flutter's own tooling. No `intl`-adjacent third party, no runtime string loader. |
| Charts | `CustomPainter` | Two visualisations (a gauge and a treemap). A charting library is more code than both of them together. |
| Native disk figures | `dart:ffi` direct to `statvfs` / `GetDiskFreeSpaceExW` | Three lines of binding per platform against a stable C ABI, versus a plugin with three native build files. Falls back to the Dart estimate whenever a symbol is missing. |
| Scheduling | In-process while the app runs, **plus** an opt-in job in the OS's own scheduler | Superseded the v0.2.0 ceiling in M25. The job is written and removed by the app itself, not by the packager, so it stays in step with the settings that created it and an uninstall that never ran the app cannot leave one behind. No resident daemon: launchd, Task Scheduler and systemd user timers already start with the session and survive reboots. |

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

Tier 1 (shipped in v0.1.0):
Rust/Cargo · Flutter · Dart · Maven · Gradle · Node (npm/yarn/pnpm/bun) ·
Python (setuptools/poetry/uv) · Go · CMake · Make · .NET · Swift/SPM · Xcode ·
Android/Gradle · Zig · Elixir/Mix · Ruby/Bundler

Tier 2 (v0.2.0, same mechanism — see M15):
Bazel · Meson/Ninja · Autotools · Conan · vcpkg · PlatformIO · Haskell (Stack
and Cabal) · Scala/sbt · Clojure (Leiningen and tools.deps) · Nim · Crystal ·
Deno · PHP/Composer · Terraform · Unity · Julia · R · Perl · Erlang/rebar3 ·
OCaml/Dune · D/Dub · Gleam · Fortran/fpm · Ada/Alire

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

## 5b. v0.2.0 milestones

Everything in §5 shipped as v0.1.0. The following is the v0.2.0 body of work,
requested by the owner in one batch. The ordering is not arbitrary: the
foundations (native disk, localisation) land before the screens that consume
them, so no screen has to be written twice.

Same rule as before — each milestone ends with `dart format`, `dart analyze
--fatal-infos` and `flutter test` all green, tests written before or with the
code.

### M12 — Native disk measurement
- [ ] `core/disk/native_disk.dart` — `dart:ffi` bindings, no plugin dependency
  - POSIX `statvfs` (macOS/Linux) and `GetDiskFreeSpaceExW` (Windows) for exact
    free / total / used bytes on the volume holding a path
  - POSIX `lstat` → `st_blocks × 512` for **allocated** (on-disk) size, which is
    what `du` reports and what the user actually gets back
- [ ] `Sizer` gains an allocated-size mode; apparent size stays the fallback and
  the only mode on Windows
- **Verify:** free space cross-checked against `df`; allocated size
  cross-checked against `du -sk` on a fixture tree; every FFI path degrades to
  the Dart fallback rather than throwing when a symbol is missing.

### M13 — Localisation
- [ ] `flutter_localizations` + `gen-l10n`, ARB files under `lib/l10n/`
- [ ] Ten locales — the most-spoken ones only: **en, es, zh, hi, ar, pt, fr,
      de, ja, ru**. Arabic exercises RTL, which Flutter gives us for free but
      which the layouts must not fight.
- [ ] Every user-facing string in `lib/src/ui/**` moves to the ARB; a test
      fails the build if a `Text('literal')` sneaks back in
- [ ] Language picker in Settings, defaulting to the system locale
- **Verify:** every locale parses and has the same key set as `en`; a widget
  test pumps the app in `ar` and asserts RTL; the no-literal-strings guard test.

### M14 — Light / dark / system theme
- [ ] `Settings.themeMode`, honoured by `MaterialApp`, chooser in Settings
- [ ] The light palette audited on every screen — it exists today but has never
      been looked at
- **Verify:** persistence round-trip; a widget test per mode.

### M15 — Tier-2 stacks
- [ ] The Tier-2 matrix in §3, one file per family, one registry line each
- **Verify:** the existing table-driven registry test extended — every stack
  detected from its markers, and every stack's artifact list non-overlapping
  with its own markers.

### M16 — Motion
The app currently changes state without saying so. A scan of a large tree runs
for seconds; a clean runs for minutes. Motion is what makes that legible.

- [ ] `ui/anim/` — a small set of `CustomPainter` + `AnimationController`
      pieces: a radar sweep for scanning, a sweeping "cleaning" band, an
      animated byte counter, a completion burst, shimmer for pending sizes
- [ ] **No animation dependency.** Rive would mean a runtime, an asset pipeline
      and a licence audit to draw a sweeping arc that `CustomPainter` draws in
      forty lines at the display's native refresh rate. Reconsider only if a
      designer delivers real `.riv` art.
- [ ] Every animation respects `MediaQuery.disableAnimations` and a
      `Settings.reduceMotion` switch
- **Verify:** widget tests pump each animation through a frame budget and
  assert it is still ticking and that it stops when reduced motion is on.

### M17 — Disk usage visualisation
- [ ] Before/after volume gauge on the report, fed by M12's free-space call
- [ ] A treemap of the largest artifact directories on the review step, so the
      user sees *where* the space is before deciding
- [ ] Both drawn with `CustomPainter`; no charting dependency
- **Verify:** treemap layout is a pure function — tests assert the rectangles
  tile the bounds exactly and that area is proportional to bytes.

### M18 — Custom cleanup profiles
- [ ] `core/profiles/` — a user-defined stack: display name, marker files, an
      optional command, artifact directory names, include/exclude path globs
- [ ] Merged into `StackRegistry` at runtime, so a custom profile is
      indistinguishable from a built-in one downstream
- [ ] Exclude globs also filter the scanner
- [ ] Editor screen with import/export as JSON
- **Verify:** a profile's command runs with the exact argv given; **every
  safety rail still applies to custom profiles** — one test per rail proving a
  profile cannot be used to escape containment, delete outside its own
  allow-list, or skip the confirmation gate.

### M19 — Scheduled cleanups
- [ ] `core/schedule/` — daily / weekly / monthly, a time of day, a saved root,
      and `nextRunAfter(DateTime)` as a pure function
- [ ] Desktop notification when a cleanup is due, and when one finishes
- [ ] **Ceiling, stated up front:** the schedule fires while Kruftle is
      running, and a missed run is offered at next launch. Waking a closed app
      needs a launchd plist / Task Scheduler entry / systemd timer per OS —
      three installers' worth of work for a developer tool the user opens on
      purpose. Not in v0.2.0. *(Lifted in M25.)*
- **Verify:** `nextRunAfter` table-driven over month ends, DST and leap years;
  a due schedule fires exactly once; notifications are behind an injectable
  interface so tests do not need a notification centre.

### M20 — Welcome & feature tour
- [ ] First-run welcome, a short tour of the five things the app does, skippable
- [ ] Replayable from Settings, so it is not a one-shot the user can never see
      again
- **Verify:** shown when the first-run flag is unset, never again after; every
  tour page reachable and the skip button always present.

### M21 — Changelog
- [ ] `assets/changelog.json`, a `Changelog` model, an in-app page
- [ ] "What's new" surfaced once after an update, driven by the last-seen
      version in settings
- **Verify:** the asset parses and is ordered newest-first; a test fails if the
  top entry does not match `pubspec.yaml`'s version.

### M22 — Privacy Policy & Terms
- [ ] Both adapted from `dizitart/dizitart_com/content/legal`, rewritten for
      what Kruftle actually does — a desktop app that deletes local files, has
      no accounts, and talks to exactly one network endpoint (the GitHub
      Releases API, only when update checks are on)
- [ ] Shipped as assets and rendered in-app, plus in the repo
- **Verify:** a test asserts both documents ship, are non-empty, and that the
  claims a test can check are true — e.g. the only outbound host in the source
  tree is the one the policy names.

### M23 — Processor architectures
- [ ] macOS: universal (x86_64 + arm64) — already shipping, keep it
- [ ] Windows: x64 **and** arm64
- [ ] Linux: x86_64 **and** arm64, AppImage and `.deb` for both
- [ ] The updater picks the asset for the running architecture, not just the OS
- **Verify:** asset-selection tests per (os, arch) pair, including the case
  where only the other architecture's asset exists — which must offer nothing
  rather than the wrong binary.

### M24 — Release & self-update
- [ ] Ship v0.2.0 and verify an installed v0.1.0 updates itself to it — the
      one thing v0.1.0 could not prove, for want of a second release
- **Verify:** by hand, on a real installed build.

## 5c. v0.3.0 milestones

### M25 — Background cleanups on all three desktops
- [ ] `core/schedule/background_service.dart` — writes and removes a launchd
      LaunchAgent, a systemd **user** timer, or a Task Scheduler entry, from
      the same `CleanupSchedule` the in-app reminder uses
- [ ] A headless second entrypoint: `--background-clean` /
      `KRUFTLE_BACKGROUND=1` runs the scan-plan-clean-notify sequence and
      exits without `runApp`. macOS additionally needs its nib window ordered
      out, because it exists before Dart starts
- [ ] The schedule screen owns the switch, and re-registers on **every** save,
      not only when the switch is touched — a job left on last week's day is
      worse than no job
- [ ] **No resident daemon.** All three platforms already ship a scheduler that
      starts with the session; a process that idles for a week to do ten
      minutes of work is the trade this project exists to avoid
- [ ] **Rail 7 holds with nobody watching:** an unattended run may only delete
      the categories already pre-selected in Settings, which is empty on a
      fresh install. It cannot widen its own permission
- **Verify:** the generated plist, unit and `schtasks` argv asserted as text —
  they fail silently and invisibly when wrong; the controller's install and
  uninstall behind an injectable service so no test touches `launchctl`; a run
  driven by hand on a real installed build.

### M26 — Interface polish
- [ ] The app mark redrawn; the previous one kept as `kruftle-legacy.svg`, and
      every raster regenerated from the one SVG by `tool/make_icons.sh`
- [ ] Version, licence and provenance move out of the About card into a
      colophon below it
- [ ] One styled dropdown, used at every call site, with a menu radius that
      matches the cards
- [ ] Log levels read as prose in all ten locales rather than as enum constants
- [ ] The title bar's buttons sit against the right edge
- [ ] The global cache list sorts by size, both ways
- **Verify:** the colophon's position asserted rather than its existence; the
  ordering extracted as a pure function and table-tested; the rest by eye,
  against the running app.

## 6. Definition of done

- `flutter analyze` reports zero issues.
- `flutter test` fully green, core engine meaningfully covered.
- App builds and runs on all three desktop OSs.
- A release tag produces installers for all three OSs plus checksums.
- An installed older build updates itself to a newer release.
- Adding a new language = one new file in `registry/stacks/` + one registry line.
