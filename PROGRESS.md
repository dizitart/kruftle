# Kruftle — Progress & Hand-off

> **Living document.** Update it at the end of every working session, before
> you stop. A future session reads this file plus `PROJECT_PLAN.md` and must be
> able to continue with no other context.

**How to resume:** read `PROJECT_PLAN.md` (the fixed decisions and
architecture), then this file (where we actually are), then run the green
check in §3 to confirm the tree is in the state this document claims.

---

## 1. Status

| | |
|---|---|
| **Current milestone** | M23 done — v0.2.0 ready to publish |
| **Last updated** | 2026-08-24 |
| **Build green?** | Yes — 502 tests, analyzer clean, formatter clean |
| **Repo** | https://github.com/dizitart/kruftle (public, GPL-3.0) |
| **CI** | Green — analyze/test plus release builds on all three OSs |
| **Released** | [v0.1.0](https://github.com/dizitart/kruftle/releases/tag/v0.1.0) — .dmg, .exe, .AppImage, .deb, checksums.txt |

---

## 2. Milestone board

Legend: `[ ]` not started · `[~]` in progress · `[x]` done & green

- [x] **M0** Foundations — license, strict lint, deps, pure-core guard test
- [x] **M1** Detection core — 16 Tier-1 stacks, registry, toolchain probe
- [x] **M2** Scanner — nested projects, symlink safety, cancellation
- [x] **M3** Sizing & dry run — isolate pool, streamed into the UI
- [x] **M4** Cleanup engine — planner, runner, all 10 safety rails
- [x] **M5** Logging — JSONL, rotation, export
- [x] **M6** Settings — persisted, migration-tolerant
- [x] **M7** Wizard UI — 5 steps, verified end to end on a real disk
- [x] **M8** Global caches — registry, narrow guard, own screen
- [x] **M9** Auto-updater — GitHub Releases, SHA-256 verified
- [x] **M10** Branding — icon, platform assets, product metadata
- [x] **M11** Packaging & CI — v0.1.0 published, all four assets verified

**v0.2.0** (see `PROJECT_PLAN.md` §5b)

- [x] **M12** Native disk measurement — FFI `statfs`/`lstat`, byte-exact against `du`
- [x] **M13** Localisation — 10 locales, ARB parity and no-literal guards
- [x] **M14** Light / dark / system theme — chooser, contrast tests
- [x] **M15** Tier-2 stacks — 26 more, 42 in total
- [x] **M16** Motion — radar sweep, cleaning band, counters, shimmer
- [x] **M17** Disk usage visualisation — squarified treemap, before/after gauge
- [x] **M18** Custom cleanup profiles — same rails as a built-in stack
- [x] **M19** Scheduled cleanups — daily/weekly/monthly, desktop notification
- [x] **M20** Welcome & feature tour — first run, replayable from Settings
- [x] **M21** Changelog — shipped as an asset, "what's new" after an update
- [x] **M22** Privacy Policy & Terms — in-app, with a test that keeps them true
- [x] **M23** Processor architectures — arm64 for Windows and Linux
- [ ] **M24** Release & self-update — **needs the owner: it publishes**

### What is left

1. **The last mile of self-update.** Everything up to the hand-off is verified
   against the live API — `tool/check_update.dart 0.0.1 --download` finds the
   right asset per platform, downloads it and passes SHA-256. What has *not*
   been exercised is `Updater.install`: opening the .dmg, running the .exe
   silently, replacing the AppImage in place. That needs an installed older
   build and a second release. Publish `v0.1.1` and try it from an installed
   `v0.1.0`.
2. **Visual check of the global caches screen** — its logic has 18 tests, but
   the screen itself has never been looked at (the session that built it ended
   with the machine locked). Run the app, click the globe icon in the title bar.
3. **Windows and Linux run-throughs** — only macOS has been driven by hand.
   Worth checking: PATH probing without a login shell on Windows, and the
   `\\?\` long-path case noted in §6.
4. ~~Tier-2 stacks~~ — done in M15.

---

## 3. Green check

Run this first, every session. It is the definition of "the tree is healthy".

```bash
cd /Volumes/External/codebase/kruftle && dart format --output=none --set-exit-if-changed lib test tool && flutter analyze --fatal-infos && flutter test
```

Expected: formatter reports 0 changed, `No issues found!`, then 502 passing.

`lib/l10n/app_localizations*.dart` is generated and committed. Regenerate it
with `flutter gen-l10n` after editing any `.arb`; the analyzer will not warn if
you forget, but `test/l10n/arb_test.dart` will.

To see it work against a real tree without launching the UI:

```bash
dart run tool/smoke_scan.dart /Volumes/External/codebase
```

---

## 4. Session log

Newest first.

### Session 2 — 2026-08-24

**Landed** — M12 through M16 of the v0.2.0 batch.

- **M12 Native disk.** `dart:ffi` straight to `statfs` (macOS), `statvfs`
  (Linux) and `GetDiskFreeSpaceExW` (Windows) for volume space, and `lstat`
  for `st_blocks`. Sizes are now what the disk actually gives back, not the
  sum of file lengths. Verified byte-exact against `du -sk` and within 1%
  of `df`. Every binding fails soft — see the self-check note in §6.
- **M13 Localisation.** `gen-l10n` + ARB, ten locales (en es zh hi ar pt fr de
  ja ru). Three guard tests: key parity, placeholder parity, and a lint that
  fails on a `Text('literal')` in `lib/src/ui/**`. The lint was verified to
  actually fire by planting a literal.
- **M14 Theme.** `Settings.themeMode`, chooser in Settings. The light palette
  had never been looked at, and the contrast test found why — see §6.
- **M15 Tier-2 stacks.** 26 added, 42 total. Re-scanned the owner's codebase:
  213 projects, no over-matching from the new markers.
- **M16 Motion.** `ui/anim/`: a radar sweep for scanning, a travelling band
  and swept motes for cleaning, counting byte figures, and a shimmer for rows
  whose size is still being measured. All `CustomPainter`, no dependency.
  Every one respects both the platform's reduced-motion setting and Kruftle's
  own, with a test per animation for each.

**Verified by hand, not just by test** — the app was run and driven through:

- The scan screen with the radar live over a real 31-project tree.
- Light mode on every screen; the accent colours now legible on white.
- Arabic end to end: the whole layout mirrors, sliders and switches included.
- Settings round-tripped to disk with every new field.

**One layout bug the locale tests found** — the step rail overflowed for
German and Russian labels. Fixed by widening it and making the label flexible.

### Session 3 — 2026-08-24

**Landed** — M17 through M23. Everything in the v0.2.0 batch except the
release itself.

- **M17 Disk usage.** A squarified treemap of the biggest artifact
  directories on the review step, and a before/after gauge of the volume's
  free space on the report. The treemap layout is a pure function with its own
  tests — areas proportional to bytes, tiles tiling the bounds exactly, no
  slivers. `CleanReport` now carries the two `statfs` readings.
- **M18 Cleanup profiles.** A profile becomes an ordinary `StackDefinition`,
  so detection, planning, cleaning and every safety rail treat it exactly like
  a built-in — that is the design, and the test file says so out loud. Also
  re-keyed tool status from `StackId` to binary name, because several stacks
  share one binary and profiles have no id of their own.
- **M19 Scheduled cleanups.** Pure date arithmetic with 34 tests, including
  month-end clamping and DST. In-process only; the ceiling is documented on
  the class, in the settings screen, and in the plan.
- **M20 Welcome tour.** Seven pages, illustrated with the actual widgets they
  describe rather than screenshots. Skip on every page.
- **M21/M22 Changelog and legal.** Shipped as assets so the app and the repo
  cannot drift. A test asserts the changelog's top entry matches `pubspec`,
  and another scans `lib/` for hosts the app contacts and fails if the Privacy
  Policy does not name them.
- **M23 Architectures.** The updater picks by processor via `Abi.current()`;
  a universal asset (the macOS .dmg) is accepted by both. Release and CI build
  Windows arm64 and Linux arm64 on native runners.

**Verified by hand** — the app was driven through the whole of it:

- First-run tour, all seven pages, with the radar and gauge animating.
- A profile created in the editor; `../../etc` rejected on screen with Save
  disabled, then corrected and saved.
- The schedule screen, with weekday names coming from `intl` per locale.
- The treemap on a real 99 GiB tree (one `target/` is 98% of it) and on a
  two-project fixture where the proportions are readable.
- **A real cleanup, end to end.** 65 MiB reclaimed; `cargo clean` removed
  `target/`, the opted-in delete removed `node_modules/`, `web/dist` was left
  alone because it is not in the allow-list, and every source file survived.
  npm's "Missing script: clean" appeared verbatim without stopping the run.
  The report's gauge showed 60.7 → 60.8 GiB free, from `statfs`.

**Two rendering bugs only the running app found** — both in the Markdown
renderer, both now covered by `test/ui/document_test.dart`:

1. A hard-wrapped bullet's continuation lines became separate paragraphs, so
   half of every long bullet fell out from under its dot.
2. `ListView` hands its children a tight cross-axis width, so the
   `ConstrainedBox` limiting the text to a readable measure did nothing and
   the legal documents ran the full width of the window.

**Next session picks up at** — M24. It is the only one left, and it publishes:
tag `v0.2.0`, let the release workflow build all six assets, then install
v0.1.0 from the existing release and check it offers and applies the update.
That last part is the thing v0.1.0 never got to prove.

### Session 1 — 2026-08-23

**Landed** — M0 through M10, and M11 apart from the release itself.

- Requirements clarified; four decisions locked in `PROJECT_PLAN.md` §1.
- Engine: registry, scanner, sizer, planner, cleaner, safety rails, logging,
  settings, updater, global caches. All pure Dart, all tested.
- UI: the five-step wizard, settings panel, global caches screen, update banner.
- Branding, packaging inputs, CI and release workflows, repo docs.
- Repo created and pushed; CI green.

**Verified by hand, not just by test**

- Scanned `/Volumes/External/codebase`: 212 projects, 26,293 directories,
  4.2 s. Found nested Rust crates inside Flutter apps that the owner's
  predecessor bash script misses entirely.
- Scanned `nitrite`: 31 projects, 98.5 GiB. Dry run planned 18 steps across 18
  projects — the other 13 were Gradle projects with no SDK installed and no
  opt-in ticked, which is rail 7 doing its job.
- Ran a real cleanup on a throwaway tree: 85 MiB reclaimed, every source file
  intact, and `npm`'s "Missing script: clean" surfaced verbatim without
  stopping the run.

**Two bugs that only the real app found** — both recorded in §6.

**Released** — v0.1.0. The release workflow needed two fixes to go green:
PowerShell reads `"$env:ProgramFiles(x86)"` as `$env:ProgramFiles` followed by
a literal `(x86)`, eating the space, so the Inno Setup path has to use brace
syntax; and CI had to pin `FLUTTER_VERSION` because floating stable formats
differently from the dev machine.

Verified on the published artifacts, not just in CI:

- All three installers download from the real Releases API and pass SHA-256.
- The .dmg mounts, carries the Applications symlink, and holds a **universal**
  (x86_64 + arm64) ad-hoc-signed bundle with the right id and version.
- The updater offers nothing when already at 0.1.0.

**Next session picks up at** — §2 "What is left", item 1.

---

## 5. Decisions log

Append-only. Record *why*, so a future session does not undo it.

| Date | Decision | Why |
|---|---|---|
| 2026-08-23 | Core engine is pure Dart, zero Flutter imports, enforced by a test | Fast tests, keeps a headless/CLI mode possible, forces the UI to stay a shell |
| 2026-08-23 | One `StackDefinition` data class + optional hooks, **not** a class per language | A subclass per language is the obvious over-engineering trap here; the data class covers every Tier-1 stack |
| 2026-08-23 | Size figures shown before a run are **estimates**, labelled as such | Clean commands decide for themselves what to remove; actual freed bytes are measured before-and-after and reported separately |
| 2026-08-23 | Git-tracked artifact dirs are excluded from the plan, not hidden | Deleting a committed `build/` destroys work a rebuild cannot restore |
| 2026-08-23 | The scanner descends *into* detected projects | A Flutter app's `rust/` crate has build output `flutter clean` never touches. Costs little, since artifact dirs are skipped |
| 2026-08-23 | Sizing does **not** shell out to `du` | Measured: Dart 4814 ms vs `du` 4720 ms on a 262k-file tree. The disk is the limit, not the language, so a platform-specific dependency buys nothing |
| 2026-08-23 | Apparent size, not disk usage | `du` reports allocated blocks (~17% lower here). Dart cannot get block counts without a native call. The *freed* figure is self-consistent either way, since it is one method measured twice |
| 2026-08-23 | macOS ships **unsandboxed** | The sandbox would neither let the app walk a user-chosen folder nor let `cargo` touch its own `target/`. Rules out the Mac App Store; correct for a developer tool on GitHub Releases |
| 2026-08-23 | CI pins `FLUTTER_VERSION` instead of tracking stable | `dart format` output changes between releases; floating stable failed the format check on a file the dev toolchain had formatted correctly |
| 2026-08-23 | Global caches get their own screen, guard and confirmation | They live in `$HOME`, which the project rails forbid by design, and they are shared by every project on the machine — a different decision from cleaning one project |
| 2026-08-23 | Go's module cache is only ever emptied by `go clean -modcache` | Go marks those files read-only on purpose; a recursive delete fails partway and leaves the cache corrupt |
| 2026-08-24 | Sizes default to **on-disk** (`st_blocks`), not apparent | It is the number the user gets back. The v0.1 decision to report apparent size was made because Dart could not read block counts; M12 removed that constraint. Apparent size stays available as a setting and is the automatic fallback on Windows |
| 2026-08-24 | Animations are hand-written `CustomPainter`, no Rive or Lottie | Sweeps, counters and progress are geometry over time. A runtime, an asset pipeline and a licence audit to draw an arc is the trade this project exists to avoid |
| 2026-08-24 | Semantic colours (`freed`/`warn`/`danger`) come in light/dark pairs, reached through `context.freed` | The dark-tuned green measures 1.7:1 on the light surface — a swatch, not a signal. A contrast test asserts every pair against the surface it will actually sit on |
| 2026-08-24 | A cleanup profile becomes a `StackDefinition`, not a parallel type | Everything downstream — scanner, planner, cleaner, all ten rails — then treats it identically to a built-in, and there is no second code path for a rail to be forgotten in |
| 2026-08-24 | Tool status is keyed by binary name, not `StackId` | Several stacks share one binary (`make` serves Make and Autotools) and every custom profile shares `StackId.custom`, so an enum key collides |
| 2026-08-24 | Scheduling is in-process; a missed run is offered at the next launch | Waking a closed app needs a launchd plist, a Task Scheduler entry and a systemd timer, each installed and removed by its own packager and kept in step with the app's own settings |
| 2026-08-24 | Release notes are English only | Translating every line of every release for ever is not sustainable at this size, and stale translations are worse than English. The parser accepts a per-locale shape should that change |
| 2026-08-24 | The core carries its own `kSupportedLocaleCodes` list | `Settings` must validate a stored locale but cannot import Flutter. A test asserts it equals the generated `L.supportedLocales`, so the copy cannot drift |

---

## 6. Known gotchas

Hard-won. Read before debugging something that looks impossible.

- **Isolate closures capture their whole enclosing scope.** `Isolate.run(() =>
  f(x))` written inside a loop also captures everything else in that scope. In
  `Sizer` that reached the progress callback and, through it, the controller's
  `Completer` — which Dart refuses to send across a port. The failure surfaced
  as a scan stuck at 0% with the error swallowed by an `unawaited` future, and
  **no unit test caught it** because the test's callback happened to close over
  only a `Map`. Always create the isolate closure in a scope holding nothing
  but its arguments; see `_sizeOnIsolate`. There is now a regression test whose
  callback deliberately closes over a `Completer`.

- **A GUI app does not inherit the login shell's `PATH`.** `cargo`, `flutter`
  and friends are put there by shell rc files, so a naive `which` reports every
  SDK as missing and the app silently offers raw deletion for everything.
  `ToolchainProbe` asks `$SHELL -lic` for the real PATH, once per scan.

- **Measuring is far slower than walking.** One Rust `target/` in this codebase
  holds 262,280 files. Never block a screen on sizing; stream it in. Row order
  in the results table is deliberately frozen while sizes arrive, or rows jump
  under the cursor mid-selection.

- **SVG gradients need `gradientUnits="userSpaceOnUse"` for straight lines.**
  A vertical line's bounding box has zero width, and the spec says a gradient
  over a zero-area box renders nothing. The icon's stem silently vanished.

- **Do not follow symlinks** anywhere in scan or clean. The owner's codebase
  root is on an external volume and contains cross-project links.

- **Windows paths**: compare artifact names case-insensitively, and long-path
  (>260 char) deletion needs the `\\?\` prefix. **Not yet implemented or
  tested** — see §2 item 4. Global cache paths are stored with forward slashes
  and split on join, because a literal `AppData\Local\...` becomes one nonsense
  segment anywhere but Windows.

- **`flutter analyze` is slow; `dart analyze` is not.** Same rules, seconds
  instead of minutes.

- **A wrong FFI struct offset does not crash — it returns a plausible number.**
  Which is far more dangerous than a failure. `NativeDisk` therefore stats a
  scratch file of known length at resolution time and refuses the binding
  unless `st_size` agrees with what Dart already knows. The offsets themselves
  were taken from `offsetof` on this machine, not from memory; on macOS arm64
  `struct stat` is 144 bytes with `st_size` at 96 and `st_blocks` at 104, and
  `struct statfs` is 2168 bytes with `f_bsize` at 0 and `f_blocks` at 8.

- **`statvfs` on macOS counts blocks in 32 bits.** Which overflows on a large
  volume. macOS therefore uses `statfs`, whose counts are 64-bit; Linux uses
  `statvfs`, where they already are. The two structs disagree on where the
  block size lives and how wide it is, which is what `_Field` exists for.

- **The light palette had never been rendered.** It shipped in v0.1 because
  `MaterialApp` wanted a `theme:` as well as a `darkTheme:`, and nothing ever
  selected it. The moment it became selectable the accent green turned out to
  be invisible on white. If you add a semantic colour, add both halves.

- **`dart format` is not idempotent across a `python`-driven edit.** Several
  edits in this session produced code the formatter then rewrote. Run
  `dart format lib test tool` before the analyzer, not after, or the
  `--set-exit-if-changed` check in §3 fails on work that is otherwise fine.

- **A `ListView` gives its children a tight cross-axis width.** So a
  `ConstrainedBox(maxWidth:)` inside one does nothing at all — it cannot
  shrink below a tight constraint. Wrap it in a `Center` (or an `Align`). This
  is why the legal documents shipped, briefly, set across the full width of
  the window.

- **`pumpAndSettle` never returns against a repeating animation.** The tour
  and the scanning step both loop by design, so their tests use
  `pump(Duration)` instead. If a widget test hangs after M16, this is why.

- **Translated labels are longer than English ones.** German and Russian both
  overflowed the step rail, which had been sized to fit "Review". Any fixed-
  width chrome needs its label `Flexible` with an ellipsis, and the per-locale
  widget tests in `test/ui/localization_test.dart` are what catch it — they
  assert `tester.takeException()` is null, which a RenderFlex overflow is not.
