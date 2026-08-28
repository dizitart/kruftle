#!/usr/bin/env bash
# Packages the Linux release bundle as an AppImage, a .deb, and a .tar.gz.
# Usage: build-packages.sh <version> [arch]
#
# `arch` is the Flutter target: x64 (default) or arm64. It picks the bundle
# directory, the appimagetool build, and the names the packages are given —
# each ecosystem has its own spelling for the same processor, which is why
# there are three variables rather than one.
#
# The .tar.gz is what the in-app updater applies: it is the bundle and nothing
# else, so unpacking it over an installed copy replaces that copy exactly. It
# is also a perfectly good way to install Kruftle by hand, which is the only
# form that can then keep itself up to date without a package manager.
set -euo pipefail

VERSION="${1:?usage: build-packages.sh <version> [arch]}"
ARCH="${2:-x64}"

case "$ARCH" in
  x64)   BUNDLE_ARCH=x64;   APPIMAGE_ARCH=x86_64;  DEB_ARCH=amd64 ;;
  arm64) BUNDLE_ARCH=arm64; APPIMAGE_ARCH=aarch64; DEB_ARCH=arm64 ;;
  *) echo "unknown arch: $ARCH (expected x64 or arm64)" >&2; exit 2 ;;
esac

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUNDLE="$ROOT/build/linux/$BUNDLE_ARCH/release/bundle"
OUT="$ROOT/dist"

# Everything the desktop sees Kruftle by. `linux/runner/my_application.cc` calls
# `g_set_prgname(APPLICATION_ID)`, so the window announces itself under this
# name and nothing else; the desktop entry and the icon have to carry it too
# or the window matches no application at all and gets a generic icon.
APP_ID=com.dizitart.kruftle
DESKTOP="$ROOT/packaging/linux/$APP_ID.desktop"

mkdir -p "$OUT"

[ -d "$BUNDLE" ] || { echo "no release bundle at $BUNDLE" >&2; exit 1; }

# An invalid desktop entry is not an error at install time — it is silently
# ignored at runtime, which looks exactly like the icon bug this file exists to
# stop coming back.
if command -v desktop-file-validate >/dev/null; then
  desktop-file-validate "$DESKTOP"
fi

grep -q "^set(APPLICATION_ID \"$APP_ID\")" "$ROOT/linux/CMakeLists.txt" || {
  echo "APPLICATION_ID in linux/CMakeLists.txt is not $APP_ID" >&2; exit 1; }

install_tree() {
  # Lays out the shared parts of every package format:
  #   <prefix>/usr/{bin,lib/kruftle,share/{applications,icons}}
  local prefix="$1" linkdir="$2"
  mkdir -p "$prefix/usr/lib/kruftle" "$prefix/usr/bin" \
           "$prefix/usr/share/applications"
  cp -r "$BUNDLE"/. "$prefix/usr/lib/kruftle/"
  ln -sf "$linkdir/kruftle" "$prefix/usr/bin/kruftle"
  cp "$DESKTOP" "$prefix/usr/share/applications/$APP_ID.desktop"
  for size in 16 32 48 64 128 256 512; do
    local dir="$prefix/usr/share/icons/hicolor/${size}x${size}/apps"
    mkdir -p "$dir"
    cp "$ROOT/assets/icon/linux/${size}x${size}/kruftle.png" "$dir/$APP_ID.png"
  done
}

# ------------------------------------------------------------------ tar.gz
# The updater's payload: the bundle exactly as it sits installed, so the swap
# is a rename and nothing more.
tar -czf "$OUT/Kruftle-$VERSION-linux-$APPIMAGE_ARCH.tar.gz" -C "$BUNDLE" .

# ----------------------------------------------------------------- AppImage
APPDIR="$OUT/Kruftle.AppDir"
rm -rf "$APPDIR"
install_tree "$APPDIR" "../lib/kruftle"

# AppImage looks for these three at the AppDir root, and the icon's basename
# has to equal the desktop entry's Icon= key.
cp "$DESKTOP" "$APPDIR/$APP_ID.desktop"
cp "$ROOT/assets/icon/linux/256x256/kruftle.png" "$APPDIR/$APP_ID.png"
cat > "$APPDIR/AppRun" <<'RUN'
#!/usr/bin/env bash
HERE="$(dirname "$(readlink -f "${0}")")"
exec "$HERE/usr/lib/kruftle/kruftle" "$@"
RUN
chmod +x "$APPDIR/AppRun"

APPIMAGETOOL="$OUT/appimagetool"
if [ ! -x "$APPIMAGETOOL" ]; then
  curl -fsSL -o "$APPIMAGETOOL" \
    "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$APPIMAGE_ARCH.AppImage"
  chmod +x "$APPIMAGETOOL"
fi
# CI containers have no FUSE, so run appimagetool from its extracted contents.
ARCH="$APPIMAGE_ARCH" "$APPIMAGETOOL" --appimage-extract-and-run \
  "$APPDIR" "$OUT/Kruftle-$VERSION-$APPIMAGE_ARCH.AppImage"

# ---------------------------------------------------------------------- deb
DEBDIR="$OUT/deb"
rm -rf "$DEBDIR"
install_tree "$DEBDIR" "/usr/lib/kruftle"
mkdir -p "$DEBDIR/DEBIAN"
cat > "$DEBDIR/DEBIAN/control" <<CONTROL
Package: kruftle
Version: $VERSION
Section: devel
Priority: optional
Architecture: $DEB_ARCH
Depends: libgtk-3-0, libblkid1, liblzma5
Maintainer: Dizitart <https://github.com/dizitart>
Homepage: https://github.com/dizitart/kruftle
Description: Reclaim disk space from build artifacts
 Kruftle finds every project under a directory, identifies its build
 tooling, and reclaims disk space by running that toolchain's own clean
 command. Raw deletion is a last resort, allow-listed and confirmed.
CONTROL

# On a full desktop, dpkg's own file triggers refresh both caches. On a system
# installed with plain `dpkg -i`, or one without desktop-file-utils' triggers,
# nothing does — and GTK reads the icon cache in preference to the directory,
# so a freshly installed icon stays invisible until something rebuilds it.
# Both commands are optional and both are told not to fail the install.
for script in postinst postrm; do
  cat > "$DEBDIR/DEBIAN/$script" <<'HOOK'
#!/bin/sh
set -e
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
fi
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
exit 0
HOOK
  chmod 755 "$DEBDIR/DEBIAN/$script"
done

dpkg-deb --build --root-owner-group "$DEBDIR" \
  "$OUT/Kruftle-$VERSION-$DEB_ARCH.deb"

rm -rf "$APPDIR" "$DEBDIR" "$APPIMAGETOOL"
ls -la "$OUT"
