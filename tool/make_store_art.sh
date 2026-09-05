#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Renders the Microsoft Store artwork from assets/store/*.svg. Needs
# `rsvg-convert` (brew install librsvg). The wordmark is live text, so render
# on a machine that has Helvetica Neue — otherwise it falls back to Arial.
#
#   ./tool/make_store_art.sh
set -euo pipefail

OUT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/assets/store"

rsvg-convert -w 1080 -h 1080 "$OUT/box-art.svg"    -o "$OUT/kruftle-box-1080.png"
rsvg-convert -w 2160 -h 2160 "$OUT/box-art.svg"    -o "$OUT/kruftle-box-2160.png"
rsvg-convert -w  720 -h 1080 "$OUT/poster-art.svg" -o "$OUT/kruftle-poster-720x1080.png"
rsvg-convert -w 1440 -h 2160 "$OUT/poster-art.svg" -o "$OUT/kruftle-poster-1440x2160.png"

echo "store art regenerated in $OUT"
