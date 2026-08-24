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
MAC="$ROOT/macos/Runner/Assets.xcassets/AppIcon.appiconset"
for size in 16 32 64 128 256 512 1024; do
  render "$size" "$MAC/app_icon_${size}.png"
done

# Windows .ico — every size Explorer picks from, in one file.
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
for size in 16 24 32 48 64 128 256; do render "$size" "$TMP/$size.png"; done
magick "$TMP"/16.png "$TMP"/24.png "$TMP"/32.png "$TMP"/48.png \
       "$TMP"/64.png "$TMP"/128.png "$TMP"/256.png \
       "$ROOT/windows/runner/resources/app_icon.ico"

echo "icons regenerated from $(basename "$SVG")"
