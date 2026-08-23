# Contributing to Kruftle

Thanks for looking. Kruftle is a disk cleanup tool, so the bar for changes that
touch deletion is deliberately high — everything else is easy.

## Getting set up

Kruftle pins its Flutter version so that local and CI agree byte for byte,
including `dart format` output, which changes between Flutter releases.

```bash
flutter --version    # must match FLUTTER_VERSION in .github/workflows/ci.yml
flutter pub get
flutter test
flutter run -d macos # or -d windows, -d linux
```

Before you push:

```bash
dart format lib test tool && flutter analyze --fatal-infos && flutter test
```

## Adding support for a language or build tool

This is the change we most want, and it is meant to be small: **one file and
one list entry.**

1. Add a value to `StackId` in `lib/src/core/models/stack.dart`.
2. Write a `StackDefinition` in the right file under
   `lib/src/core/registry/stacks/`.
3. Add it to `kStacks` in `lib/src/core/registry/stack_registry.dart`.
4. Add a row to the detection table in
   `test/core/registry/stack_registry_test.dart`.

```dart
const zigStack = StackDefinition(
  id: StackId.zig,
  displayName: 'Zig',
  markers: {'build.zig'},                       // what makes it this project
  tool: ToolProbe(binary: 'zig'),               // probed on PATH
  cleanCommand: CleanCommand('zig', ['clean']), // the official clean
  artifacts: [ArtifactPath('zig-out')],         // fallback + size estimate
);
```

If the invocation depends on the directory's contents — a wrapper script, a
package manager chosen by lockfile — supply `resolveCleanCommand` instead.

**Please do not** introduce a class per language. The data class plus its two
optional hooks covers every stack in the matrix, and an abstract base with one
implementation each is exactly the kind of structure this codebase is trying
not to grow.

## The rules that are not up for negotiation

`lib/src/core/clean/safety.dart` holds ten safety rails, each with a test that
fails closed. They exist because a cleanup tool gets exactly one chance to earn
someone's trust:

- never run on `/`, `$HOME`, or a system path
- never follow a symlink, never delete through one
- deletion is allow-listed by exact directory name — never a glob
- every rule is re-checked at the moment of deletion, not just when planning
- anything git tracks is left alone
- raw deletion needs the user's explicit opt-in, every run

A PR that weakens one of these needs to say why in the description, and will
be read closely.

Related: `lib/src/core/**` is pure Dart and must never import
`package:flutter/*`. A test enforces it. That is what keeps the engine fast to
test and usable headlessly.

## Commits and PRs

Explain *why* in the commit body — the code already says what. Keep the tree
green: `flutter analyze --fatal-infos` and `flutter test` both pass on every
commit, and CI checks formatting too.

## Reporting a bug

Kruftle writes a JSONL activity log, and Settings → Logging → **Show** reveals
it. Attaching the relevant lines makes a cleanup bug enormously easier to
diagnose. Please redact paths you would rather not share.
