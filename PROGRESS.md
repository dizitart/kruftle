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
| **Current milestone** | M11 — packaging & first release |
| **Last updated** | 2026-08-23 |
| **Build green?** | Yes — 170 tests, analyzer clean, formatter clean |
| **Repo** | https://github.com/dizitart/kruftle (public, GPL-3.0) |
| **CI** | Green on Linux + analyze/test; macOS and Windows builds verified in workflow |
| **Released?** | Not yet — no tag pushed |

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
- [~] **M11** Packaging & CI — workflows written, first release not yet cut

### What is left

1. **Cut `v0.1.0`** — push the tag, watch `release.yml`, confirm all four
   assets plus `checksums.txt` land on the release.
2. **Verify self-update for real** — install `v0.1.0`, publish `v0.1.1`,
   confirm the installed build offers and applies it. This is the one feature
   that cannot be proven without two published releases.
3. **Visual check of the global caches screen** — its logic has 18 tests, but
   the screen itself has never been looked at (the session that built it ended
   with the machine locked). Run the app, click the globe icon in the title bar.
4. **Windows and Linux run-throughs** — only macOS has been driven by hand.
   Worth checking: PATH probing without a login shell on Windows, and the
   `\\?\` long-path case noted in §6.
5. Tier-2 stacks from `PROJECT_PLAN.md` §3, whenever wanted.

---

## 3. Green check

Run this first, every session. It is the definition of "the tree is healthy".

```bash
cd /Volumes/External/codebase/kruftle && dart format --output=none --set-exit-if-changed lib test tool && flutter analyze --fatal-infos && flutter test
```

Expected: formatter reports 0 changed, `No issues found!`, then 170 passing.

To see it work against a real tree without launching the UI:

```bash
dart run tool/smoke_scan.dart /Volumes/External/codebase
```

---

## 4. Session log

Newest first.

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
