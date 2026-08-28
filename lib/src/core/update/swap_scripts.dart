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

/// Replaces the running `.app` with the one inside the mounted disk image.
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
/// Parameters: archive, install directory, our pid, executable to relaunch.
///
/// PowerShell rather than `cmd`, for `Expand-Archive` and `Wait-Process`: both
/// have shipped in Windows since PowerShell 5.1, which is every supported
/// version of Windows 10 and 11, on x64 and arm64 alike.
const windowsSwapScript = r'''
param([string]$Archive, [string]$Dir, [int]$Owner, [string]$Exe)

# The install directory is almost certainly this process's working directory,
# and Windows will not rename a directory anything is sitting in. Asked of
# .NET rather than of $env:TEMP, which is not guaranteed to be set.
Set-Location -LiteralPath ([System.IO.Path]::GetTempPath())

# Nothing here can happen while Kruftle still holds its own files open.
try { Wait-Process -Id $Owner -Timeout 60 -ErrorAction Stop } catch {}
if (Get-Process -Id $Owner -ErrorAction SilentlyContinue) { exit 1 }

$staging = "$Dir.new"
$old = "$Dir.old"
$swapped = $false
Remove-Item -LiteralPath $staging, $old -Recurse -Force -ErrorAction SilentlyContinue

try {
  Expand-Archive -LiteralPath $Archive -DestinationPath $staging -Force

  # Inno Setup writes its uninstaller into the install directory, and it is not
  # part of the build output. Losing it would leave an Add/Remove Programs
  # entry pointing at nothing.
  Get-ChildItem -LiteralPath $Dir -Filter 'unins*' -ErrorAction SilentlyContinue |
    ForEach-Object {
      Copy-Item -LiteralPath $_.FullName -Destination $staging -Force
    }

  Move-Item -LiteralPath $Dir -Destination $old
  try {
    Move-Item -LiteralPath $staging -Destination $Dir
    $swapped = $true
  } catch {
    Move-Item -LiteralPath $old -Destination $Dir
  }
} catch {}

Remove-Item -LiteralPath $staging, $old -Recurse -Force -ErrorAction SilentlyContinue
if ($swapped) { Remove-Item -LiteralPath $Archive -Force -ErrorAction SilentlyContinue }

Start-Process -FilePath $Exe
''';
