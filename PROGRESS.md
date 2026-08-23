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
| **Current milestone** | M0 — Foundations |
| **Last updated** | 2026-08-23 |
| **Build green?** | see §3 |
| **Pushed to GitHub?** | No — repo not yet created |

---

## 2. Milestone board

Legend: `[ ]` not started · `[~]` in progress · `[x]` done & green

- [~] **M0** Foundations
- [ ] **M1** Detection core
- [ ] **M2** Scanner
- [ ] **M3** Sizing & dry run
- [ ] **M4** Cleanup engine + safety rails
- [ ] **M5** Logging
- [ ] **M6** Settings
- [ ] **M7** Wizard UI
- [ ] **M8** Global caches module
- [ ] **M9** Auto-updater
- [ ] **M10** Branding & assets
- [ ] **M11** Packaging & CI & publish

---

## 3. Green check

Run this first, every session. It is the definition of "the tree is healthy".

```bash
cd /Volumes/External/codebase/kruftle && flutter analyze && flutter test
```

Expected: `No issues found!` then all tests passing. If it is not green, fixing
that comes before any new feature work.

---

## 4. Session log

Newest first. One entry per session: what landed, what is half-done, what the
next session should pick up.

### Session 1 — 2026-08-23

**Landed**
- Requirements clarified with the owner; four decisions locked (name, update
  mechanism, signing, aggressive-clean scope). Recorded in `PROJECT_PLAN.md` §1.
- Read the owner's predecessor bash script at
  `/Volumes/External/codebase/cleanup/cleanup_build_artifacts.sh` — it is the
  seed for the stack detection matrix and encodes the owner's intent
  ("no files deleted directly, only official build commands").
- `flutter create` scaffold: `com.dizitart.kruftle`, platforms macos/windows/linux.
- `PROJECT_PLAN.md` and this file written.

**In progress**
- M0 foundations: license, lint config, dependencies, the no-flutter-imports
  test guard.

**Next session picks up at**
- Finish M0, then M1 (models + `StackRegistry` + Tier-1 stack definitions),
  TDD. See `PROJECT_PLAN.md` §5.

---

## 5. Decisions log

Append-only. Record *why*, so a future session does not undo it.

| Date | Decision | Why |
|---|---|---|
| 2026-08-23 | Core engine is pure Dart, zero Flutter imports, enforced by a test | Fast tests, keeps a headless/CLI mode possible, forces the UI to stay a shell |
| 2026-08-23 | One `StackDefinition` data class + optional `resolve` hook, **not** a class per language | A subclass per language is the obvious over-engineering trap here; the data class covers every case in the Tier-1 matrix |
| 2026-08-23 | Size figures shown before a run are **estimates**, labelled as such | Official clean commands decide for themselves what to remove; we can only measure the well-known artifact dirs beforehand. Actual freed bytes are measured after the fact and reported separately |
| 2026-08-23 | Git-tracked artifact dirs are excluded from default selection, not hidden | Deleting a committed `build/` destroys real work; the user may still opt in deliberately |

---

## 6. Known gotchas

- **Do not follow symlinks** anywhere in scan or clean. The owner's codebase
  root (`/Volumes/External/codebase`) is on an external volume and contains
  cross-project links.
- `flutter clean` and `cargo clean` both need the SDK on `PATH`; the GUI app on
  macOS does **not** inherit a login shell `PATH`. The toolchain probe must
  resolve binaries via a login shell (`$SHELL -lic 'command -v x'`) or an
  explicit search path, not bare `Process.run('which')`. This bites every
  Flutter desktop app and will silently report "SDK missing" for everything.
- Windows path handling: artifact dirs must be compared case-insensitively,
  and long-path (>260 char) deletion needs the `\\?\` prefix.
