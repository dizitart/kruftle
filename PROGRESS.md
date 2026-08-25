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
| **Current milestone** | **v0.2.2** — the About panel links out to Kruftle's own page and to Dizitart |
| **Last updated** | 2026-08-26 |
| **Build green?** | Yes — 583 tests, analyzer clean, formatter clean, all five release targets green |
| **Repo** | https://github.com/dizitart/kruftle (public, GPL-3.0) |
| **CI** | Green — analyze/test plus release builds on all three OSs |
| **Released** | [v0.2.2](https://github.com/dizitart/kruftle/releases/tag/v0.2.2) — .dmg, two .exe, two .AppImage, two .deb, checksums.txt |

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
- [x] **M24** Release & self-update — published, and an installed v0.1.0 updated itself

**v0.3.0** (see `PROJECT_PLAN.md` §5c)

- [x] **M25** Background cleanups — launchd / systemd / Task Scheduler, headless run
- [x] **M26** Interface polish — new mark, colophon, one dropdown, sorted caches

### What is left

1. **`Updater.install` on Windows and Linux.** macOS now replaces its own
   bundle, and the swap script is driven against a real `.dmg` and a real
   process in `mac_swap_test.dart` — but running the `.exe` silently and
   replacing a running AppImage in place have still never happened. Both need
   a machine of that kind with an older build installed on it.
2. **Windows and Linux run-throughs generally** — only macOS has been driven
   by hand. Worth checking: PATH probing without a login shell on Windows, the
   `\\?\` long-path case noted in §6, and the background job on both — the
   generated unit, argv and plist are asserted against each other in
   `background_service_test.dart`, but only launchd has actually been asked to
   load one.
3. **v0.1.0 users on Windows cannot auto-update correctly.** The updater that
   shipped in v0.1.0 takes the *first* asset ending in `.exe`, and v0.2.0
   publishes two — x64 and arm64. Half of them will be offered the wrong one.
   Nothing can be done to the released v0.1.0; v0.2.0's updater picks by
   processor, so this ends with v0.2.0. Worth a line in the release notes.
4. ~~Tier-2 stacks~~ — done in M15.

---

## 3. Green check

Run this first, every session. It is the definition of "the tree is healthy".

```bash
cd /Volumes/External/codebase/kruftle && dart format --output=none --set-exit-if-changed lib test tool && flutter analyze --fatal-infos && flutter test
```

Expected: formatter reports 0 changed, `No issues found!`, then 583 passing.

`lib/l10n/app_localizations*.dart` is generated and committed. Regenerate it
with `flutter gen-l10n` after editing any `.arb`; the analyzer will not warn if
you forget, but `test/l10n/arb_test.dart` will.

To see it work against a real tree without launching the UI:

```bash
dart run tool/smoke_scan.dart /Volumes/External/codebase
```

To look at every screen without running the app — any locale, either palette:

```bash
flutter test test/tools/shots.dart --dart-define=locale=de --dart-define=brightness=light
```

The PNGs land in `build/shots/`. Nothing is asserted and nothing is committed;
it is there to be looked at. Regenerate the app icon's rasters with:

```bash
./tool/make_icons.sh
```

---

## 4. Session log

Newest first.

### Session 10 — 2026-08-26

**Landed** — v0.2.2: two links in Settings → About.

- **Kruftle website** (`kruftle.dizitart.com`) and **Dizitart**
  (`www.dizitart.com`), next to the existing source-code row. One new ARB key
  across all ten locales for "Kruftle website"; the publisher's row is the
  literal `Dizitart`, since a brand name is the same in every language.
- **The privacy policy had to move with it.** `about_test.dart` scans every
  `Uri.https(` host in `lib/` and fails if the policy does not name it. The
  new hosts are browser-opened links, not fetches, so §4's "not network
  activity" bullet now names them explicitly and says so; "Last updated"
  bumped to 2026-08-26. `hasAcceptedLegal` is a plain bool with no date
  comparison, so nobody is re-prompted for consent.

### Session 9 — 2026-08-25

**Landed** — v0.2.1 re-cut again: the last thirteen failing clean steps, read
off a real 333 GB run's log.

- **The bug, one level down.** Session 7 resolved the *executable* through
  `ToolchainProbe`, which fixed 94 of 96 failures. It did not fix the ten
  that read `env: node: No such file or directory`: `npm` started fine, then
  its script reached for `node` through a `#!/usr/bin/env node` shebang, and
  `env` searched the **child's** PATH — still the Finder one, because
  `Process.start` inherits the parent environment and we never replaced it.
  Same root cause, one process deeper.
- **The fix.** `ToolchainProbe.searchPathValue()` exposes the directories the
  probe already searches; `SystemProcessRunner` passes them as the child's
  `PATH`. Never an empty one — an empty PATH is worse than the inherited one.
- **Reproduced before and after** by running the core under
  `env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin` — exactly what launchd hands a
  Finder-launched `.app`. Before: `exit=127, env: node: No such file or
  directory`, the log line verbatim. After: exit 0.
- **Three failures were Kruftle planning a command it could not run.**
  `npm run clean` at every `package.json` (most declare no such script);
  `make distclean` at an Autotools tree whose Makefile the *previous* run's
  distclean had already deleted. Both resolvers now read the file —
  `DirListing` carries its own path for this — and offer no command rather
  than a command that fails. The projects fall back to allow-listed deletion,
  which is what they should have had all along.
- **One failure was real** and stays a failure: a `pom.xml` missing four
  dependency versions. Maven prints that to stdout, so the report showed a
  bare `exited 1`; a failing command now falls back to stdout when stderr is
  silent.

### Session 8 — 2026-08-25

**Landed** — v0.2.1 re-cut: the macOS update installs itself.

- **The bug.** `Updater.install` on macOS did one thing: `open` the `.dmg`.
  Finder then refused the drag into Applications — *the app is already
  running* — because it was: Kruftle had opened the image and stayed up. The
  update could not be completed by the only route the app offered.
- **The fix** is what Sparkle does, minus Sparkle: `Updater.macSwapScript`, a
  detached `/bin/sh` that waits for our PID to go, mounts the image, `ditto`s
  the new bundle beside the old one, swaps them, and `open`s the result.
  `install()` now returns whether the caller must quit, and
  `UpdateController` calls `exit(0)` when it says so — the quit is the
  precondition for the swap, not a courtesy.
- **Nothing is lost when it fails.** The old bundle is moved aside, not
  deleted, and moved back if the new one will not take its place. An
  Applications folder this user cannot write to, an unreadable image, a
  process that will not exit within ten seconds — every one of those ends at
  `open "$dmg"`, which is precisely the old behaviour.
- **No shell interpolation.** Paths go in as `$1 $2 $3`, so a release asset
  cannot name itself into a command.
- **Tested against the real thing.** `mac_swap_test.dart` builds a `.dmg` with
  `hdiutil`, installs a fake old bundle, holds it with a live process, and
  asserts nothing moves until that process dies — the bug itself, as an
  assertion. `open` is stubbed through `PATH` so the suite launches nothing.
- **The banner no longer says the installer has been opened**, in all ten
  locales, because on macOS it now has not been.

### Session 7 — 2026-08-25

**Landed** — v0.2.1: the reason v0.2.0 reclaimed nothing, the toast that would
not leave, and one instance at a time.

- **The bug worth the release.** A run over the owner's whole codebase planned
  96 clean commands and 95 of them failed in about ten milliseconds each with
  `No such file or directory`. Nothing was reclaimed out of an estimated
  311 GiB. The one step that worked was `make distclean` — and `make` is the
  only tool in that list living in `/usr/bin`. The app had been opened from
  Finder, so its PATH was `/usr/bin:/bin:/usr/sbin:/sbin`, and
  `Process.start('cargo', …)` could not find a thing. §6 has carried a note
  about this since session 1 — but only about *probing*. `ToolchainProbe` had
  known the absolute path of every one of those binaries all along; the
  cleaner then threw it away and spawned the bare name.
- **The fix** is three lines: `SystemProcessRunner` asks the probe where the
  binary is and spawns that path, and the probe is now a shared instance so
  the login shell is asked once per process rather than once per object.
  `./gradlew` and `./mvnw` are left alone — they are paths already, and mean
  the working directory.
- **Proved against the real bug**, not just in a unit test: the release
  `.app` was run with `env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin SHELL=/bin/zsh`
  — a Finder launch in every way that matters — over a tree holding a real
  `cargo` target and a Flutter `build/`. Both were cleaned. Before the fix the
  same binary would have failed both.
- **The toast that never went away.** `SnackBar` has a `persist` flag whose
  default is `action != null`, and a persistent snack bar *ignores its own
  duration*. The export toast carries a "Show" action, so it sat over the
  report until it was clicked. All toasts now go through `showToast`, which
  pins `persist: false` and five seconds.
- **One Kruftle at a time.** `InstanceLock` — an advisory `flock` on a file in
  the support directory, taken by the window and by the background run alike.
  The OS releases it however the process dies, so there is no stale lock to
  reason about and no port to collide with. A second launch gets a small
  window saying so; a scheduled run that arrives while a window is open writes
  `Background run declined: Kruftle is already open` and stops.
- **Driven by hand on macOS**: two copies launched, and the window list read
  back through `CGWindowListCopyWindowInfo` — 1160x780 for the app, 560x340
  for the notice.

### Session 6 — 2026-08-25

**Landed** — the first-run consent gate, and v0.2.0 re-cut with it.

- **The gate.** `ui/consent_page.dart`: the Terms of Service and the Privacy
  Policy in front of the tour, both documents openable from the screen itself,
  accept or quit. Nothing new was written for it — the documents were already
  shipping as assets and already had a `DocumentPage` to render them, so this
  is a screen with two buttons and one settings flag, `hasAcceptedLegal`.
- **Where it sits.** `_Root` in `ui/app.dart` is now a three-way gate: consent,
  then tour, then the app. Still a gate rather than a pushed route, for the
  reason already recorded there — nothing behind it should build.
- **Driven by hand on macOS,** from a cleared preferences domain: the gate on
  launch, both documents opening and coming back, accept leading into the
  tour, the flag on disk, and a relaunch going straight to the wizard.
- **One trap found in the test suite** — see §6 on the asset cache.

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

### Session 5 — 2026-08-25

**Landed** — M24. v0.2.0 is published, and the one thing v0.1.0 could never
prove is proved.

- **The release.** Tag `v0.2.0`, all five build jobs green on the first run,
  seven assets and `checksums.txt`:
  `Kruftle-0.2.0-macos.dmg` (universal), `-windows-x64-setup.exe`,
  `-windows-arm64-setup.exe`, `-x86_64.AppImage`, `-aarch64.AppImage`,
  `-amd64.deb`, `-arm64.deb`.
- **Self-update, end to end, from the real thing.** The released `v0.1.0` .dmg
  was mounted and run. It found 0.2.0 unprompted, said "Kruftle 0.2.0 is
  available (22.1 MiB)", downloaded it, verified the SHA-256 against the
  release's `checksums.txt`, and opened the installer — which mounted, and
  contained Kruftle 0.2.0. `tool/check_update.dart 0.1.0 --download` did the
  same for all three platforms' assets in one go, each one verified.
- **The About panel, from the shipped artifact.** The app was copied out of
  the published .dmg and run: version 0.2.0 (3), Kruftle's mark, not
  Flutter's.
- **The background job, fired by launchd, from the published build.** Turning
  the switch on wrote a LaunchAgent pointing at the .app inside the .dmg;
  `launchctl kickstart` ran it; with nothing pre-selected it deleted nothing
  and reported `freedBytes: 0`, and with **Tool caches** ticked it deleted
  `__pycache__/`, freed 204,800 bytes and left the source alone. Switching it
  off removed both the plist and the loaded job.

**Two cross-platform bugs found by reading the Linux and Windows paths again**
rather than by running them, since neither can be run here:

1. **The AppImage would have registered a path that stops existing.** The
   payload is mounted on a FUSE filesystem under `/tmp/.mount_XXXXXX` and
   unmounted the instant the process exits, so `Platform.resolvedExecutable`
   names something that is gone long before the timer fires. The job is now
   pointed at `$APPIMAGE`, which is the `.AppImage` itself.
2. **The systemd units ignored `XDG_CONFIG_HOME`.** A user who has moved their
   config directory has moved it for systemd too; writing to a hard-coded
   `~/.config` would have put the units somewhere systemd never looks.

And a test group that pins the three job formats against *each other* — every
weekday, the same executable and flag, the same minute, and midnight. A
weekday that is Thursday on macOS and Wednesday on Linux is the kind of bug
nobody reports, because nobody is watching at 03:05 to see which day it ran.

**The About panel, again.** It was reported as still showing Flutter's icon.
It was not: the report came from a `flutter run` session, which hot-reloads
the Dart-side title-bar image while leaving the app bundle and the Swift
delegate as they were. A debug build of the tree at that moment already
resolved the right icon — checked by having the delegate write
`NSApp.applicationIconImage` to a PNG. The delegate now assigns the icon at
both ends of launching and falls back to `AppIcon.icns` if the asset
catalogue lookup fails, which is the case an incremental build actually hits.

### Session 4 — 2026-08-25

**Landed** — M25 (background cleanups) and M26 (interface polish).

- **M25 Background service.** The v0.2.0 ceiling — "it cannot wake itself while
  closed" — is gone. `core/schedule/background_service.dart` writes a launchd
  LaunchAgent, a systemd **user** timer or a Task Scheduler entry from the same
  `CleanupSchedule` the in-app reminder already used, and removes it again. No
  daemon: all three platforms ship a scheduler that starts with the session, so
  Kruftle registers a job and exits rather than idling for a week to do ten
  minutes of work.
- **The headless second entrypoint.** `main()` checks for `--background-clean`
  or `KRUFTLE_BACKGROUND=1` and, when it finds either, runs
  `src/background_run.dart` and exits without `runApp`, a window manager, a
  locale or a widget tree. Two signals rather than one because argv does not
  reach the Dart entrypoint on macOS and the environment is the awkward one to
  set on Windows.
- **Rail 7 with nobody watching.** An unattended run plans with
  `Settings.rememberedRisks` and nothing else, so it runs each toolchain's own
  clean command and deletes only what the user pre-selected — empty on a fresh
  install. Verified both ways on a real build (see below).
- **M26 Interface.** New app mark; version/licence/provenance moved out of the
  About card into a colophon below it; one `KruftleDropdown` at all five call
  sites; log levels read as prose in all ten locales; the title bar's buttons
  pushed to the right edge; the global cache list sortable by size both ways.

**Verified against real builds and real bytes, not only by test**

- **The background run, end to end, from the release .app.**
  `KRUFTLE_BACKGROUND=1 Kruftle.app/Contents/MacOS/Kruftle --background-clean`
  against a scratch tree: **no window appeared**, it scanned, deleted
  `__pycache__/` and `.pytest_cache/`, freed 430,080 bytes, left `main.py` and
  `pyproject.toml` alone, wrote `lastRun` back so the in-app banner would not
  double-fire, and exited 0.
- **Rail 7, the negative case.** The same fixture with `rememberedRisks: []`
  deleted **nothing** and reported `freedBytes: 0`.
- **The guard.** With no schedule configured it declined and said so in the log
  rather than cleaning anything.
- **launchd for real.** `install()` wrote the plist, `launchctl bootstrap`
  accepted it, `launchctl print` showed the program, the `--background-clean`
  argument and `KRUFTLE_BACKGROUND => 1`, and `uninstall()` removed both the
  job and the file with nothing left behind.
- **Every screen, rendered.** `flutter test test/tools/shots.dart` — see below.

**New: a darkroom instead of a person driving the app.** `test/tools/shots.dart`
renders each screen offscreen to `build/shots/`, at a real window size, in any
locale and either palette. It made the colophon, the rounded dropdown menu, the
capitalised log levels, the right-aligned title bar and the sort control all
checkable without a screen recording, and it caught nothing wrong in German
(the long-label locale) or Arabic (RTL, including the new switch and its help
paragraph). It is under `test/` so the analyzer treats its test-only APIs as
such, and it does not end in `_test.dart` so the suite skips it.

**Then driven by hand, on the release build, screen by screen.** Which is
where the last three findings came from:

1. **The About panel really was showing Flutter's logo**, and really is fixed:
   assigning `NSApp.applicationIconImage` from the bundle's own `AppIcon` in
   `applicationWillFinishLaunching` puts the new mark there. Opened and looked
   at.
2. **The registration banner lied when no folder had been chosen.** With
   `runInBackground` on and no root, `isConfigured` is false, so nothing is
   ever handed to the operating system — but the screen still said "Registered
   with the system scheduler". The banner is now gated on `isConfigured` too,
   with a test whose name says why. Nothing else on the screen was wrong; this
   was found only by turning the switch on before picking the folder.
3. **The tour undersold the feature it was introducing.** "Set it and forget
   it" still promised a reminder and nothing more. `tourScheduleBody` now says
   Kruftle can register with the operating system and run with its window
   closed, in all ten languages.

**The full lifecycle, on the real machine, through the real screen** — the
switch wrote `~/Library/LaunchAgents/com.dizitart.kruftle.agent.plist` pointing
at the running .app; `launchctl print` showed it loaded; changing the day from
Monday to Friday re-registered it and `Weekday` went from 1 to 5 in both the
file and launchd's live copy; turning the switch off removed both. Also driven:
the whole wizard on a scratch tree (scan, review, the treemap, the deletion
confirmation, the run, the report — `__pycache__` gone, `pyproject.toml`
untouched), the global cache screen sorted both ways against real sizes
(15.7 GiB down to 1.1, then back up), the profile editor's three validation
errors with Save disabled, the seven tour pages, and every dropdown in light as
well as dark.

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
  Windows arm64 and Linux arm64 on native runners — which needed the SDK
  cloned from git rather than installed by `flutter-action`, for the reason
  in §6.

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

**Next session picked up at** — M24, in session 5. It publishes:
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
| 2026-08-24 | ~~Scheduling is in-process; a missed run is offered at the next launch~~ | Waking a closed app needs a launchd plist, a Task Scheduler entry and a systemd timer, each installed and removed by its own packager and kept in step with the app's own settings — **superseded 2026-08-25, see below** |
| 2026-08-25 | The app writes and removes the OS scheduler job itself, not the packager | Which is what dissolved the 2026-08-24 objection: the job is created from the same `CleanupSchedule` the screen edits, on the same save, so the two cannot drift; and an uninstall that never runs the app cannot leave one behind, because turning the switch off is what removes it |
| 2026-08-25 | No resident daemon; the OS's own scheduler is the background service | launchd, Task Scheduler and systemd user timers all already start with the session and survive reboots. A process of our own would sit in login items, in the tray and in `ps` for a week to do ten minutes of work |
| 2026-08-25 | An unattended run may only delete what was already pre-selected in Settings | Rail 7 says the user opts into raw deletion. Nobody is at the keyboard at 03:00 to be asked, so the background run honours the existing opt-in and cannot widen it. On a fresh install that set is empty, so an unattended run does clean commands only |
| 2026-08-25 | Both `--background-clean` and `KRUFTLE_BACKGROUND=1` are set on every job | Neither signal survives everywhere: macOS's Flutter runner does not forward argv to the Dart entrypoint, and setting an environment variable through `schtasks` means wrapping the command in `cmd /c`. Setting both costs two lines and removes the per-platform special case |
| 2026-08-25 | One `KruftleDropdown` rather than styling `DropdownButton` at each site | Five call sites that have to agree with each other. Its `style` is derived from the theme rather than built from a bare `TextStyle`, because the menu items inherit that style and nothing else |
| 2026-08-25 | The screen shots come from a widget test, not a screen recorder | `test/tools/shots.dart` renders the real tree offscreen at a real size. It runs in any locale and either palette without a person, a window server or a video, and the fonts are loaded from the machine so the text is legible rather than the harness's blank boxes |
| 2026-08-24 | Release notes are English only | Translating every line of every release for ever is not sustainable at this size, and stale translations are worse than English. The parser accepts a per-locale shape should that change |
| 2026-08-24 | The core carries its own `kSupportedLocaleCodes` list | `Settings` must validate a stored locale but cannot import Flutter. A test asserts it equals the generated `L.supportedLocales`, so the copy cannot drift |
| 2026-08-25 | Clean commands are spawned at the **absolute path the probe found**, never by bare name | A desktop-launched app has a four-directory PATH. Resolving at plan time and spawning at run time were two different answers to the same question, and the app shipped for a release with the second one wrong |
| 2026-08-25 | One instance, enforced by an advisory file lock in the support directory | Two cleanups over one tree means two build tools writing one directory. A lock file is released by the OS on any exit, unlike a pid file; a loopback socket would risk a firewall prompt for no gain |
| 2026-08-25 | Every toast goes through `showToast`, which sets `persist: false` | The Material default makes any snack bar with an action permanent, which is never what Kruftle wants, and it is invisible at the call site |
---

## 6. Known gotchas

- **Reading a bundled asset in a widget test poisons the next test that reads
  the same one.** The bundle caches it as a buffer the following test cannot
  read back, and its `FutureBuilder` silently renders the error branch — so a
  test that passes alone fails when another one happens to read the same file
  first. `addTearDown(rootBundle.clear)` in whichever test reads it. This is
  why the consent-gate test in `test/ui/about_test.dart` has that line and the
  legal-document tests below it do not.


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
  `ToolchainProbe` asks `$SHELL -lic` for the real PATH, once per scan. **And the answer has to
  be carried through to `Process.start`** — a resolved path that is then not
  used is exactly the shape of the v0.2.0 bug: every command failed with
  `No such file or directory` while the review screen cheerfully reported
  every toolchain as installed. **Resolving the executable is still not
  enough**: `npm run clean` spawns `node`, a Gradle wrapper spawns `java`, and
  those search the child's PATH. The child gets the probe's PATH as its
  environment, or the bug simply reappears one process deeper — which is
  exactly what v0.2.1 shipped.

- **Never plan a clean command you have not checked exists.** `npm run clean`
  in a package with no such script, `make clean` in a Makefile with no such
  target, `make distclean` in an Autotools tree the last run already
  distcleaned — each exits non-zero and lands in the report as a failed clean
  when nothing is wrong. A resolver may read the project's own files
  (`DirListing.path` is there for this) and return `null`; the fallback to
  allow-listed deletion is the better answer anyway.

- **A `SnackBar` with an action never times out.** `persist` defaults to
  `action != null`, and a persistent snack bar ignores `duration` entirely.
  Use `showToast`; do not call `showSnackBar` directly.

- **Dart's file locks exclude processes, not isolates.** POSIX locks are held
  per process, so a second `lockSync` inside the same Kruftle is granted. That
  is why `InstanceLock` keeps the granted lock in a static — a
  `RandomAccessFile` closes itself when collected, and a closed file is an
  unlocked file — and why its test spawns a real child process.

- **`Platform.resolvedExecutable` under `flutter test` is `flutter_tester`,**
  which cannot run a script. A test that needs a child Dart process wants
  `$FLUTTER_ROOT/bin/dart` with `--packages=.dart_tool/package_config.json`.

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

- **Flutter ships no arm64 SDK for Windows or Linux.** Only macOS gets both
  in the release manifest, so `subosito/flutter-action` fails outright on an
  arm64 Windows or Linux runner with "Unable to determine Flutter version".
  The fix is to clone the SDK at the pinned tag and let it bootstrap its own
  Dart SDK and engine artifacts — both `dartsdk-linux-arm64` and
  `dartsdk-windows-arm64` do exist. Verified: all five build jobs green,
  including both arm64 ones.

- **An empty directory does not cost zero bytes.** It costs nothing on APFS
  and a whole 4 KiB block on ext4, so a test asserting zero passes on a Mac
  and fails the moment CI runs it on Linux. Anything asserting an exact byte
  count belongs in `SizeMode.apparent`; on-disk assertions should compare
  against `du`, which is the only claim that mode makes.

- **Inside an AppImage, `Platform.resolvedExecutable` has a shelf life.** The
  payload is mounted under `/tmp/.mount_XXXXXX` and unmounted the moment the
  process exits, so any path written down for later — a systemd unit, a
  desktop entry, a config file — is dead on arrival. `$APPIMAGE` is the one
  that survives. `BackgroundService.executablePath` is the only place this is
  handled.

- **A `flutter run` session hot-reloads Dart assets but not the app bundle.**
  So an icon shown by `Image.asset` updates while the Dock tile, the About
  panel and anything in the Swift or asset-catalogue side stay as they were at
  the last native build. Two apparently contradictory icons in one screenshot
  is the tell, and the answer is a real rebuild, not a hunt through AppKit.

- **A `ListView` gives its children a tight cross-axis width.** So a
  `ConstrainedBox(maxWidth:)` inside one does nothing at all — it cannot
  shrink below a tight constraint. Wrap it in a `Center` (or an `Align`). This
  is why the legal documents shipped, briefly, set across the full width of
  the window.

- **`pumpAndSettle` never returns against a repeating animation.** The tour
  and the scanning step both loop by design, so their tests use
  `pump(Duration)` instead. If a widget test hangs after M16, this is why.

- **`toByteData` never completes inside a widget test.** PNG encoding runs on
  the real event loop, which the tester's fake one does not advance, so the
  future simply hangs and the whole file dies at the ten-minute suite timeout
  with no error. Wrap the capture in `tester.runAsync`. This is why
  `test/tools/shots.dart` looks the way it does.

- **`flutter test` renders every unloaded font family as a blank box.** Which
  makes an offscreen screenshot useless for reading and fine for measuring.
  `FontLoader` fixes it, but only for families something actually asks for:
  a widget whose `style` is a bare `TextStyle` with no family — as
  `DropdownButton`'s menu items were — falls back to the placeholder even when
  the theme has been patched, because `DefaultTextStyle` in the menu replaces
  rather than merges.

- **`Flexible` plus a following `Spacer` splits the free space in two.** Both
  default to a flex of 1, so the title bar's buttons sat in the middle of the
  bar rather than against its right edge. One flexible child is what pushes a
  trailing group to the end.

- **A `DropdownButton`'s menu is rounded by two pixels unless told otherwise.**
  Next to cards rounded by ten, the hover highlight looks like it is
  overflowing its own menu. `borderRadius:` on the button rounds the menu.

- **Translated labels are longer than English ones.** German and Russian both
  overflowed the step rail, which had been sized to fit "Review". Any fixed-
  width chrome needs its label `Flexible` with an ellipsis, and the per-locale
  widget tests in `test/ui/localization_test.dart` are what catch it — they
  assert `tester.takeException()` is null, which a RenderFlex overflow is not.
