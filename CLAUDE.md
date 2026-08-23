# Kruftle — instructions for Claude Code

**Before doing anything, read `PROJECT_PLAN.md` then `PROGRESS.md`.**
`PROJECT_PLAN.md` holds locked decisions and the architecture; `PROGRESS.md`
holds where the work actually stands and what to pick up next.

## Working rules

- **TDD.** Test first or alongside. Never leave the tree red.
- **Green check** before starting and before finishing:
  ```bash
  flutter analyze && flutter test
  ```
- `lib/src/core/**` is pure Dart. Never import `package:flutter/*` there — a
  test enforces this.
- Adding language support = one file in `lib/src/core/registry/stacks/` plus one
  line in `stack_registry.dart`. If you find yourself adding an abstract class
  per language, stop; that is not the design.
- The safety rails in `lib/src/core/clean/safety.dart` are non-negotiable.
  Every rail has a test. Do not weaken one without the owner's say-so.
- Every source file carries the SPDX header:
  `// SPDX-License-Identifier: GPL-3.0-or-later`
- **Update `PROGRESS.md` before you finish a session** — session log entry,
  milestone board, and any new decision or gotcha.
