#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Renders the Microsoft Store artwork from assets/store/*.svg and the plain
# app icon from assets/icon/kruftle.svg. Needs `rsvg-convert` (brew install
# librsvg). The box/poster wordmark is live text, so render those on a
# machine that has Helvetica Neue — otherwise it falls back to Arial.
#
#   ./tool/make_store_art.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/assets/store"
ICON="$ROOT/assets/icon/kruftle.svg"

rsvg-convert -w 1080 -h 1080 "$OUT/box-art.svg"    -o "$OUT/kruftle-box-1080.png"
rsvg-convert -w 2160 -h 2160 "$OUT/box-art.svg"    -o "$OUT/kruftle-box-2160.png"
rsvg-convert -w  720 -h 1080 "$OUT/poster-art.svg" -o "$OUT/kruftle-poster-720x1080.png"
rsvg-convert -w 1440 -h 2160 "$OUT/poster-art.svg" -o "$OUT/kruftle-poster-1440x2160.png"

# Plain Store icons: the app mark exactly as it is everywhere else, rendered
# straight from the master SVG at each target size rather than resampled from
# a raster, so there is no resampling artifact to introduce a variation at
# all -- full bleed, same as every non-macOS icon this SVG already produces.
for size in 300 150 71; do
  rsvg-convert -w "$size" -h "$size" "$ICON" -o "$OUT/kruftle-icon-$size.png"
done

echo "store art regenerated in $OUT"
