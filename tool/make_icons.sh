#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Renders every raster the app ships from the one SVG, so the mark can only be
# changed in one place. Needs `rsvg-convert` (librsvg) and ImageMagick, both of
# which are `brew install librsvg imagemagick`.
#
#   ./tool/make_icons.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SVG="$ROOT/assets/icon/kruftle.svg"
OUT="$ROOT/assets/icon"

render() { rsvg-convert -w "$1" -h "$1" "$SVG" -o "$2"; }

# In-app (title bar, tour, about).
render 512 "$OUT/kruftle-512.png"

# Linux hicolor theme, as the .deb and the AppImage want it.
for size in 16 32 48 64 128 256 512; do
  mkdir -p "$OUT/linux/${size}x${size}"
  render "$size" "$OUT/linux/${size}x${size}/kruftle.png"
done

# macOS asset catalogue.
#
# Alone among the three, macOS does not want the mark drawn to the edge of the
# canvas. Its icon grid puts the body of an app icon in the middle 824 of 1024
# points and leaves the rest transparent, and every icon in the Dock is laid
# out on that assumption. A full-bleed icon is not clipped to fit — it is drawn
# at the size it was given, which is why Kruftle stood a quarter taller than
# everything beside it. Same artwork, 80.5% of the canvas, centred.
MAC="$ROOT/macos/Runner/Assets.xcassets/AppIcon.appiconset"
MACTMP="$(mktemp -d)"
trap 'rm -rf "$MACTMP"' EXIT
for size in 16 32 64 128 256 512 1024; do
  body=$(( (size * 824 + 512) / 1024 ))   # rounded, not truncated
  render "$body" "$MACTMP/body.png"
  magick "$MACTMP/body.png" -background none -gravity center \
    -extent "${size}x${size}" "$MAC/app_icon_${size}.png"
done

# Windows .ico — every size Explorer picks from, in one file. Full-bleed:
# Windows and GNOME both lay out square icons edge to edge.
TMP="$MACTMP"
for size in 16 24 32 48 64 128 256; do render "$size" "$TMP/$size.png"; done
magick "$TMP"/16.png "$TMP"/24.png "$TMP"/32.png "$TMP"/48.png \
       "$TMP"/64.png "$TMP"/128.png "$TMP"/256.png \
       "$ROOT/windows/runner/resources/app_icon.ico"

echo "icons regenerated from $(basename "$SVG")"
