// SPDX-License-Identifier: GPL-3.0-or-later

/// The helpers that replace Kruftle with a newer Kruftle.
///
/// None of this can happen while Kruftle is alive: every operating system
/// holds the files of a running program, which is exactly the "the app is
/// already running" refusal Finder gives when a bundle is dragged over itself.
/// So each script is started detached, waits for our process to go, and only
/// then swaps. Sparkle ships a helper binary to do this; here it is a dozen
/// lines of the shell every target already has.
///
/// Every path arrives as an argument, never interpolated into the script, so a
/// release asset cannot name itself into a command.
///
/// All three follow the same shape: unpack beside the installed copy, rename
/// the old one aside, move the new one into place, and put the old one back if
/// that fails. A failed update leaves the working Kruftle exactly where it was.
library;

/// Replaces the running `.app` with the one inside a `.zip`, then starts it.
///
/// Arguments: archive, `.app` bundle, our pid.
///
/// `ditto -x -k` rather than `unzip`: it is what made the archive, and it is
/// the only extractor on macOS that restores a bundle's symlinks, resource
/// forks and executable bits intact — an `unzip`ped `.app` is a broken `.app`.
///
/// The staging directory is a sibling of the installed bundle, so the move into
/// place is a rename on the same filesystem rather than a copy, and a directory
/// this user cannot create is the same answer as a bundle they cannot replace.
const macArchiveSwapScript = r'''
      cd / || exit 1
      zip=$1; app=$2; pid=$3
      waited=0
      while kill -0 "$pid" 2>/dev/null && [ "$waited" -lt 600 ]; do
        sleep 0.1; waited=$((waited + 1))
      done
      kill -0 "$pid" 2>/dev/null && exit 1

      staging=$app.new
      swapped=
      rm -rf "$staging" "$app.old"
      if mkdir -p "$staging" && ditto -x -k "$zip" "$staging" 2>/dev/null; then
        new=$(ls -d "$staging"/*.app 2>/dev/null | head -1)
        if [ -n "$new" ] && mv "$app" "$app.old" 2>/dev/null; then
          if mv "$new" "$app" 2>/dev/null; then
            swapped=1
            # Nothing here was quarantined -- the download never went through
            # LaunchServices -- but an archive can carry the attribute, and a
            # quarantined bundle is one Gatekeeper stops rather than opens.
            xattr -dr com.apple.quarantine "$app" 2>/dev/null
          else
            mv "$app.old" "$app"
          fi
        fi
      fi
      rm -rf "$staging" "$app.old"
      [ -n "$swapped" ] && rm -f "$zip"

      open "$app"
''';

/// Replaces the running `.app` with the one inside the mounted disk image.
///
/// The fallback for a release published before [macArchiveSwapScript]'s `.zip`
/// existed. Same swap, with `hdiutil` in front of it.
///
/// Arguments: disk image, `.app` bundle, our pid.
///
/// If the swap cannot even be attempted — `/Applications` not writable by this
/// user — the disk image is opened instead and the user is where they would
/// have been anyway.
const macSwapScript = r'''
      dmg=$1; app=$2; pid=$3
      waited=0
      while kill -0 "$pid" 2>/dev/null && [ "$waited" -lt 100 ]; do
        sleep 0.1; waited=$((waited + 1))
      done
      kill -0 "$pid" 2>/dev/null && { open "$dmg"; exit 0; }

      mount=$(mktemp -d /tmp/kruftle-update.XXXXXX)
      hdiutil attach -nobrowse -readonly -noverify -mountpoint "$mount" "$dmg" \
        >/dev/null || { rmdir "$mount"; open "$dmg"; exit 0; }
      new=$(ls -d "$mount"/*.app 2>/dev/null | head -1)

      staging=$app.new
      swapped=
      rm -rf "$staging" "$app.old"
      if [ -n "$new" ] && ditto "$new" "$staging" 2>/dev/null &&
         mv "$app" "$app.old" 2>/dev/null; then
        if mv "$staging" "$app" 2>/dev/null; then
          swapped=1
        else
          mv "$app.old" "$app"
        fi
      fi
      rm -rf "$staging" "$app.old"
      hdiutil detach "$mount" -quiet 2>/dev/null; rmdir "$mount" 2>/dev/null

      if [ -n "$swapped" ]; then open "$app"; else open "$dmg"; fi
''';

/// Starts Kruftle again once this process has gone, and nothing else.
///
/// Arguments: executable, our pid.
///
/// For the updates that are applied by something other than a swap helper — a
/// `.deb` handed to `dpkg` — where the files are replaced while Kruftle is
/// still running but the *running* Kruftle is still the old one. It cannot
/// start its replacement itself: the new process would collide with the single
/// instance lock the old one is still holding.
const relaunchScript = r'''
      cd / || exit 1
      exe=$1; pid=$2
      waited=0
      while kill -0 "$pid" 2>/dev/null && [ "$waited" -lt 600 ]; do
        sleep 0.1; waited=$((waited + 1))
      done
      kill -0 "$pid" 2>/dev/null && exit 1

      "$exe" >/dev/null 2>&1 &
''';

/// Replaces an installed Linux bundle directory with the contents of a
/// `.tar.gz`, then starts the new build.
///
/// Arguments: tarball, install directory, our pid, executable to relaunch.
///
/// `cd /` first because the install directory is very likely this process's
/// working directory, and a script cannot remove the ground it stands on.
const linuxSwapScript = r'''
      cd / || exit 1
      tgz=$1; dir=$2; pid=$3; exe=$4
      waited=0
      while kill -0 "$pid" 2>/dev/null && [ "$waited" -lt 600 ]; do
        sleep 0.1; waited=$((waited + 1))
      done
      kill -0 "$pid" 2>/dev/null && exit 1

      staging=$dir.new
      swapped=
      rm -rf "$staging" "$dir.old"
      if mkdir -p "$staging" && tar -xzf "$tgz" -C "$staging" &&
         mv "$dir" "$dir.old" 2>/dev/null; then
        if mv "$staging" "$dir" 2>/dev/null; then
          swapped=1
        else
          mv "$dir.old" "$dir"
        fi
      fi
      rm -rf "$staging" "$dir.old"
      [ -n "$swapped" ] && rm -f "$tgz"

      "$exe" >/dev/null 2>&1 &
''';

/// Replaces the running AppImage file with the downloaded one.
///
/// Arguments: downloaded AppImage, the AppImage we are running as, our pid.
///
/// An AppImage is a single file that the kernel has mounted for as long as it
/// is running, so it cannot be written over from inside itself — which is what
/// the previous version of this did, and why a Linux update could leave a
/// half-written binary behind.
const appImageSwapScript = r'''
      cd / || exit 1
      new=$1; cur=$2; pid=$3
      waited=0
      while kill -0 "$pid" 2>/dev/null && [ "$waited" -lt 600 ]; do
        sleep 0.1; waited=$((waited + 1))
      done
      kill -0 "$pid" 2>/dev/null && exit 1

      chmod +x "$new" || exit 1
      # `mv` across filesystems copies and unlinks, so a failure half-way
      # through would leave a truncated Kruftle where the working one was.
      cp -p "$cur" "$cur.old" 2>/dev/null
      if mv -f "$new" "$cur" 2>/dev/null; then
        rm -f "$cur.old"
      else
        [ -f "$cur.old" ] && mv -f "$cur.old" "$cur"
        exit 1
      fi

      "$cur" >/dev/null 2>&1 &
''';

/// Replaces a Windows install directory with the contents of a `.zip`.
///
/// Parameters: archive, install directory, our pid, executable to relaunch, and
/// a file to write an account of itself to. That last one exists because this
/// runs entirely after Kruftle has exited: a swap that quietly does nothing
/// leaves no trace anywhere, which is exactly what happened on Windows.
///
/// PowerShell rather than `cmd`, for `Expand-Archive` and `Wait-Process`: both
/// have shipped in Windows since PowerShell 5.1, which is every supported
/// version of Windows 10 and 11, on x64 and arm64 alike.
const windowsSwapScript = r'''
param(
  [string]$Archive,
  [string]$Dir,
  [int]$Owner,
  [string]$Exe,
  [string]$Log
)

# Expand-Archive writes a progress bar. This helper is started detached, with
# no console to write it to, and a host that cannot render progress can fail
# before doing any work at all. Silencing it also makes Expand-Archive many
# times faster on Windows PowerShell 5.1.
$ProgressPreference = 'SilentlyContinue'

# Everything this helper does, written where Kruftle can find it. It runs after
# Kruftle has exited, so nothing it does is visible anywhere else; the next
# launch folds this file into the activity log and deletes it. A swap that goes
# wrong in silence is a swap nobody can diagnose.
function Note($message) {
  try {
    Add-Content -LiteralPath $Log -Encoding UTF8 `
      -Value ("{0} {1}" -f (Get-Date).ToString('s'), $message)
  } catch {}
}

Note "helper started; pid $PID, PowerShell $($PSVersionTable.PSVersion)"
Note "archive $Archive"
Note "install $Dir"

# The install directory is almost certainly the exited process's working
# directory, and Windows will not rename a directory anything is sitting in.
Set-Location -LiteralPath ([System.IO.Path]::GetTempPath())

# Polled rather than Wait-Process: it is one thing that cannot throw for a
# reason worth distinguishing, and every second of it can be reported.
$deadline = (Get-Date).AddSeconds(90)
while ((Get-Process -Id $Owner -ErrorAction SilentlyContinue) -and
       (Get-Date) -lt $deadline) {
  Start-Sleep -Milliseconds 200
}
if (Get-Process -Id $Owner -ErrorAction SilentlyContinue) {
  Note "Kruftle ($Owner) is still running after 90s; nothing was changed"
  exit 1
}
Note "Kruftle ($Owner) has exited"

$staging = "$Dir.new"
$old = "$Dir.old"
$swapped = $false
Remove-Item -LiteralPath $staging, $old -Recurse -Force -ErrorAction SilentlyContinue

# Renaming a directory Windows still has a handle on fails, and a handle can
# outlive the process that held it by a moment -- an indexer or a virus scanner
# looking at what just changed. Worth a few tries before giving up on it.
function Move-WithRetry($from, $to) {
  for ($i = 1; $i -le 12; $i++) {
    try { Move-Item -LiteralPath $from -Destination $to -ErrorAction Stop; return $true }
    catch { Start-Sleep -Milliseconds 500 }
  }
  return $false
}

try {
  Expand-Archive -LiteralPath $Archive -DestinationPath $staging -Force
  Note "unpacked to $staging"

  # Inno Setup writes its uninstaller into the install directory, and it is not
  # part of the build output. Losing it would leave an Add/Remove Programs
  # entry pointing at nothing.
  Get-ChildItem -LiteralPath $Dir -Filter 'unins*' -ErrorAction SilentlyContinue |
    ForEach-Object {
      Copy-Item -LiteralPath $_.FullName -Destination $staging -Force
      Note "carried over $($_.Name)"
    }

  if (Move-WithRetry $Dir $old) {
    if (Move-WithRetry $staging $Dir) {
      $swapped = $true
      Note 'swapped'
    } else {
      Note 'could not move the new build into place; putting the old one back'
      [void](Move-WithRetry $old $Dir)
    }
  } else {
    Note "could not rename $Dir out of the way; nothing was changed"
  }
} catch {
  Note "failed: $($_.Exception.Message)"
}

Remove-Item -LiteralPath $staging, $old -Recurse -Force -ErrorAction SilentlyContinue
if ($swapped) {
  Remove-Item -LiteralPath $Archive -Force -ErrorAction SilentlyContinue
}

try {
  Start-Process -FilePath $Exe
  Note "started $Exe"
} catch {
  Note "could not start $Exe : $($_.Exception.Message)"
}
''';
