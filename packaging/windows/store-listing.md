# Microsoft Store — listing details (English)

Copy each block into the matching Partner Center field.

## Short description
*(≤270 characters)*

```
Kruftle finds every project on your disk — Rust, Node, Flutter, Gradle, Go and 37 more — and reclaims the space their build output takes, by running each toolchain's own clean command. Dry run first, git-tracked files skipped, never a blind rm -rf.
```

## Description
*(≤10,000 characters; plain text, no markdown — Partner Center does not render it)*

```
A developer machine accumulates build output the way a workshop accumulates sawdust. A target/ here, a node_modules/ there, a build/ in every Flutter app — none of it precious, all of it invisible, and collectively tens of gigabytes.

Kruftle scans a directory, works out what every project underneath it is built with, and reclaims that space by running each toolchain's own clean command — cargo clean for Rust, flutter clean for Flutter, ./gradlew clean for Gradle, go clean for Go, dotnet clean for .NET, and so on across 42 toolchains in total.

WHY THE TOOL'S OWN COMMAND

Because rm -rf on a guessed directory name is how people lose work. cargo clean knows which files in target/ are Cargo's; a shell glob does not. Kruftle only ever deletes a directory outright when the SDK for that project genuinely is not installed, the directory name is on a per-stack allow-list, and you have ticked a box saying so for that run.

WHAT IT DOES

• Finds every project, including ones nested inside other projects — the Rust crate in a Flutter app has build output that flutter clean will never touch.
• Detects the toolchain and whether it is installed, so you know before you start which projects will get a proper clean and which are offered a fallback.
• Dry run first, with a real measurement of what would be freed — or skip it.
• Choose what runs: select all, none, or exactly the projects you mean.
• Cleans in parallel and reports what was actually freed, not what was predicted.
• Logs everything, and exports it when you want to know what happened.

SAFETY

Disk cleanup tools get one chance to earn trust. Kruftle:

• Refuses to run on the drive root, your home directory, or any system path — a refusal that cannot be waived.
• Asks before scanning a path near the root of a drive, since a mapped network drive or a mounted volume can put a real codebase at a location that looks like one.
• Never follows a symlink, and never deletes through one.
• Deletes only directory names a matched toolchain explicitly declares — never a glob, never a pattern you typed.
• Re-checks every rule at the moment of deletion, not just when planning.
• Skips anything Git tracks, because some repositories commit their build/ and a rebuild will not bring it back.
• Asks before every category of raw deletion, every run.

SUPPORTED TOOLCHAINS

42 toolchains, detected by marker file and cleaned with that toolchain's own command:

Systems — Rust, Go, Zig, Nim, Crystal, D, Fortran, Ada
Native / C++ — CMake, Make, Bazel, Meson, Ninja, Autotools, Conan, vcpkg, PlatformIO
JVM & .NET — Maven, Gradle, sbt, Clojure, .NET
Dart — Flutter, Dart
Apple — Xcode, Swift Package
Web & scripting — Node.js, Deno, PHP/Composer, Python, Ruby, Perl
Functional — Haskell, Cabal, Erlang, Elixir, OCaml, Gleam
Data & infra — Julia, R, Terraform, Unity

Kruftle is free software (GPL-3.0-or-later) and its source is public. Full manual and toolchain list: kruftle.dizitart.com
```

## Additional system requirements

**Minimum hardware** *(one per row, "Add more" for each)*

```
Windows 10 version 1809 (build 17763) or later
64-bit processor (x64 or ARM64)
4 GB RAM
250 MB free disk space
```

**Recommended hardware**

```
Windows 11
8 GB RAM
SSD (scanning and deletion are disk-bound)
```

## Keywords
*(7 keywords, 17 words total — limit is 7 / 21)*

```
disk cleanup
build artifacts
developer tools
node_modules
cargo clean
free disk space
project cleaner
```

## Copyright and trademark info

```
© 2026 Dizitart. Kruftle is free software under the GNU General Public License v3.0 or later. All other product names and toolchain names are trademarks of their respective owners.
```

## Applicable license terms

This field replaces the Store's Standard Application License, which is what you
want for a GPL app — the full GPL text is far over the field limit, so the
notice below points at it.

```
Kruftle is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Kruftle is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

Full licence text: https://www.gnu.org/licenses/gpl-3.0.html
Source code: https://github.com/dizitart/kruftle

These terms apply in place of the Microsoft Standard Application License Terms.
```

## Developed by

```
Dizitart
```
