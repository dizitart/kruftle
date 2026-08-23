# Security Policy

## Reporting a vulnerability

Please report security issues privately through
[GitHub Security Advisories](https://github.com/dizitart/kruftle/security/advisories/new)
rather than opening a public issue. We aim to acknowledge within a few days.

## What counts as a security issue here

Kruftle deletes files, so the interesting failures are about deleting the
wrong ones:

- **Escaping the chosen directory** — any path that makes Kruftle touch
  something outside the folder the user selected, including via a symlink,
  a junction, or a `..` component that survives normalisation.
- **Bypassing the allow-list** — getting Kruftle to remove a directory that no
  matched stack declares as build output.
- **Skipping the confirmation gate** — any raw deletion that happens without
  the user opting into that category for that run.
- **Deleting tracked content** — anything that defeats the git guard.
- **Update integrity** — anything that makes the updater install a binary whose
  SHA-256 does not match the digest published in the release's `checksums.txt`.

Untrusted input worth noting: Kruftle reads directory names and lockfiles from
whatever tree it is pointed at, and runs build tools it finds on `PATH`. A
crafted directory tree that makes it run something unintended, or delete
outside its allow-list, is a valid report.

## What is out of scope

- **Unsigned binaries.** Kruftle ships without a Developer ID or Authenticode
  signature. That is a known, documented trade-off, not a vulnerability. Verify
  downloads against `checksums.txt` on the release.
- **The unsandboxed macOS build.** Kruftle cannot run in the App Sandbox: it
  exists to walk directories the user chooses and to run their build tools.
  See `macos/Runner/DebugProfile.entitlements` for the reasoning.
- **Deleting build output that the user selected and confirmed.** That is the
  product working.
