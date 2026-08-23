#!/usr/bin/env bash
# Packages the Linux release bundle as an AppImage and a .deb.
# Usage: build-packages.sh <version>
set -euo pipefail

VERSION="${1:?usage: build-packages.sh <version>}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUNDLE="$ROOT/build/linux/x64/release/bundle"
OUT="$ROOT/dist"
mkdir -p "$OUT"

[ -d "$BUNDLE" ] || { echo "no release bundle at $BUNDLE" >&2; exit 1; }

install_tree() {
  # Lays out the shared parts of both package formats:
  #   <prefix>/usr/{bin,lib/kruftle,share/{applications,icons}}
  local prefix="$1" linkdir="$2"
  mkdir -p "$prefix/usr/lib/kruftle" "$prefix/usr/bin" \
           "$prefix/usr/share/applications"
  cp -r "$BUNDLE"/. "$prefix/usr/lib/kruftle/"
  ln -sf "$linkdir/kruftle" "$prefix/usr/bin/kruftle"
  cp "$ROOT/packaging/linux/kruftle.desktop" "$prefix/usr/share/applications/"
  for size in 16 32 48 64 128 256 512; do
    local dir="$prefix/usr/share/icons/hicolor/${size}x${size}/apps"
    mkdir -p "$dir"
    cp "$ROOT/assets/icon/linux/${size}x${size}/kruftle.png" "$dir/kruftle.png"
  done
}

# ----------------------------------------------------------------- AppImage
APPDIR="$OUT/Kruftle.AppDir"
rm -rf "$APPDIR"
install_tree "$APPDIR" "../lib/kruftle"

# AppImage looks for these three at the AppDir root.
cp "$ROOT/packaging/linux/kruftle.desktop" "$APPDIR/kruftle.desktop"
cp "$ROOT/assets/icon/linux/256x256/kruftle.png" "$APPDIR/kruftle.png"
cat > "$APPDIR/AppRun" <<'RUN'
#!/usr/bin/env bash
HERE="$(dirname "$(readlink -f "${0}")")"
exec "$HERE/usr/lib/kruftle/kruftle" "$@"
RUN
chmod +x "$APPDIR/AppRun"

APPIMAGETOOL="$OUT/appimagetool"
if [ ! -x "$APPIMAGETOOL" ]; then
  curl -fsSL -o "$APPIMAGETOOL" \
    "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
  chmod +x "$APPIMAGETOOL"
fi
# CI containers have no FUSE, so run appimagetool from its extracted contents.
ARCH=x86_64 "$APPIMAGETOOL" --appimage-extract-and-run \
  "$APPDIR" "$OUT/Kruftle-$VERSION-x86_64.AppImage"

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
Architecture: amd64
Depends: libgtk-3-0, libblkid1, liblzma5
Maintainer: Dizitart <https://github.com/dizitart>
Homepage: https://github.com/dizitart/kruftle
Description: Reclaim disk space from build artifacts
 Kruftle finds every project under a directory, identifies its build
 tooling, and reclaims disk space by running that toolchain's own clean
 command. Raw deletion is a last resort, allow-listed and confirmed.
CONTROL
dpkg-deb --build --root-owner-group "$DEBDIR" "$OUT/Kruftle-$VERSION-amd64.deb"

rm -rf "$APPDIR" "$DEBDIR" "$APPIMAGETOOL"
ls -la "$OUT"
