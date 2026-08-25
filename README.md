<h1 align="center">Kruftle</h1>

<p align="center">
  <img alt="Kruftle" src="assets/icon/kruftle-512.png" width="128" height="128">
</p>

<p align="center">
  <em>Reclaim your disk. Kill the cruft.</em>
</p>

<p align="center">
  <a href="https://github.com/dizitart/kruftle/releases"><img alt="Release" src="https://img.shields.io/github/v/release/dizitart/kruftle?sort=semver"></a>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/badge/license-GPL--3.0-blue"></a>
  <img alt="Platforms" src="https://img.shields.io/badge/platform-macOS%20%7C%20Windows%20%7C%20Linux-lightgrey">
</p>

---

A developer machine accumulates build output the way a workshop accumulates
sawdust. A `target/` here, a `node_modules/` there, a `build/` in every Flutter
app — none of it precious, all of it invisible, and collectively tens of
gigabytes.

**Kruftle** scans a directory, works out what every project underneath it is
built with, and reclaims that space by running each toolchain's *own* clean
command.

```
cargo clean · flutter clean · mvn clean · ./gradlew clean · go clean · dotnet clean · swift package clean · mix clean · …
```

## Why the tool's own command

Because `rm -rf` on a guessed directory name is how people lose work.

`cargo clean` knows which files in `target/` are Cargo's. A shell glob does
not. Kruftle only ever deletes a directory outright when the SDK for that
project genuinely is not installed, the directory name is on a per-stack
allow-list, and you have ticked a box saying so for that run.

## What it does

- **Finds every project**, including the ones nested inside other projects —
  the Rust crate in a Flutter app has build output that `flutter clean` will
  never touch.
- **Detects the toolchain and whether it is installed**, so you know before you
  start which projects will get a proper clean and which are offered a fallback.
- **Dry run first**, with a real measurement of what would be freed. Or skip it.
- **Choose what runs.** Select all, none, or exactly the projects you mean.
- **Cleans in parallel**, projects at a time, and reports what was actually
  freed rather than what was predicted.
- **Logs everything** and exports it when you want to know what happened.

## Safety

Disk cleanup tools get one chance to earn trust. Kruftle:

- refuses to run on `/`, your home directory, or any system path
- never follows a symlink, and never deletes through one
- deletes only directory names a matched stack explicitly declares — never a
  glob, never a pattern you typed
- re-checks every rule at the moment of deletion, not just when planning
- **skips anything git tracks**, because some repos commit their `build/` and a
  rebuild will not bring that back
- asks before every category of raw deletion, every run

Each of those has a test that fails closed.

## Supported stacks

Rust · Flutter · Dart · Maven · Gradle · Node (npm/yarn/pnpm/bun) · Python ·
Go · CMake · Make · .NET · Swift · Xcode · Zig · Elixir · Ruby

Adding another is one file and one list entry — see
[`lib/src/core/registry/`](lib/src/core/registry/).

## Install

Download the installer for your platform from
[Releases](https://github.com/dizitart/kruftle/releases). Kruftle updates itself
from there afterwards.

Builds are currently unsigned, so the first launch needs one extra step:

- **macOS** — `xattr -dr com.apple.quarantine /Applications/Kruftle.app`
- **Windows** — SmartScreen → *More info* → *Run anyway*
- **Linux** — `chmod +x Kruftle-*.AppImage`

## Building from source

```bash
flutter pub get
flutter test
flutter run -d macos   # or -d windows, -d linux
```

## License

GPL-3.0-or-later. See [LICENSE](LICENSE).
