# Kruftle compared

Honest comparison with the tools people actually reach for. Where another tool
is better, this page says so — the point is to help you pick the right one, not
to win an argument.

## The short version

| | **Kruftle** | **kondo** | **npkill** |
|---|---|---|---|
| How it removes artifacts | Runs the toolchain's **own clean command** | Deletes the directory | Deletes the directory |
| Stacks detected | 42 | 20+ | Node only |
| Interface | Desktop GUI | CLI + GUI | Interactive CLI |
| Platforms | macOS · Windows · Linux | macOS · Windows · Linux | Anywhere Node runs |
| Needs the SDK installed | Yes, for the proper clean | No | No |
| Speed | Slower | Fast | Fast |
| Space reclaimed | Slightly less | More | More |
| Skips git-tracked output | Yes | No | No |
| Follows symlinks | Never | Optional | — |
| Dry run with real measurement | Yes | — | — |
| Filter by last-modified age | No | Yes | Yes |
| Licence | GPL-3.0 | MIT | MIT |

## The actual difference

kondo describes itself, in its own README, as *"essentially `rm -rf` with a
prompt."* That is a legitimate design and it is why kondo is fast. It is also
the one thing Kruftle deliberately does not do.

Kruftle works out what each project is built with and runs **that toolchain's
own clean command** — `cargo clean`, `flutter clean`, `./gradlew clean`.
`cargo clean` knows which files in `target/` belong to Cargo. A shell glob
matching the name `target` does not.

This matters in three specific cases:

1. **The name is a coincidence.** A `target/` in a non-Rust project, a `build/`
   that is a source directory, a `dist/` someone committed on purpose.
2. **Git is tracking it.** Some repositories commit their build output
   deliberately, because the build is not reproducible on every machine. A
   rebuild will not bring that back. Kruftle skips anything git tracks.
3. **There is a symlink in the way.** `node_modules` pointing at a shared
   directory on another volume. Kruftle never follows one and never deletes
   through one.

## Where the other tools are better

**kondo is faster, and it does not need your SDKs.** Running `cargo clean`
means starting Cargo, which takes real time across a hundred crates, and it
only works if Cargo is installed. kondo deletes the directory either way. If
you are cleaning an archive disk full of projects whose toolchains you no
longer have, kondo is the better fit. Its age filter — "only projects not
touched in three months" — is genuinely useful and Kruftle has no equivalent
yet.

**kondo has a CLI. Kruftle does not, yet.** If you want this in a shell script
or a cron job, kondo works today. Kruftle's engine is pure Dart with no Flutter
imports precisely so a CLI can exist, but it is not written.

**npkill is excellent at the one thing it does.** If your problem is
`node_modules` and only `node_modules`, npkill is smaller, faster to install,
and needs no download.

**Kruftle reclaims slightly less space, on purpose.** Clean commands keep
caches that a rebuild can reuse. `cargo clean` leaves things behind that
`rm -rf target` would not. That is usually what you want, and Kruftle's report
tells you when the figure came in under the dry-run estimate and why.

## Where Kruftle is better

- **Nested projects.** The Rust crate inside a Flutter app has build output
  that `flutter clean` will never touch, and it is often where the gigabytes
  actually are. Kruftle finds projects inside projects.
- **You see it before it happens.** A dry run with a real measurement, a
  treemap of where the space actually is, and a per-project checklist.
- **Raw deletion is a fallback, not the mechanism.** It happens only when the
  SDK is genuinely absent, the directory name is on that stack's own
  allow-list, and you have ticked a box for that run.
- **The rails cannot be waived.** It refuses `/`, your home directory and
  system paths, and that refusal has no override. Every rail has a test that
  fails closed.
- **It reports what was really freed**, not what it predicted.

## Which should you use

- Your problem is `node_modules` → **npkill**.
- You want a CLI, maximum speed, or you are cleaning projects whose toolchains
  are gone → **kondo**.
- You want to see what will happen before it happens, across many languages,
  and you would rather the toolchain decide what is safe to delete →
  **Kruftle**.

*Corrections welcome — if anything here misrepresents another project, please
[open an issue](https://github.com/dizitart/kruftle/issues/new) and it will be
fixed.*
