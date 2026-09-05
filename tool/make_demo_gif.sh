#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Assembles the frames written by `flutter test tool/demo_frames.dart` into
# the README/site demo GIF.
#
#   flutter test tool/demo_frames.dart
#   tool/make_demo_gif.sh
#
# Needs ffmpeg. Frame timing is per-scene rather than uniform: the scan and
# the run are motion and read fast, while review and report are the two
# frames a viewer actually stops to read.
set -euo pipefail

cd "$(dirname "$0")/.."

frames="tool/demo/frames"
out="tool/demo/kruftle-demo.gif"
width=900

[ -d "$frames" ] || { echo "No frames in $frames — run: flutter test tool/demo_frames.dart" >&2; exit 1; }
command -v ffmpeg >/dev/null || {
  echo "ffmpeg not found. brew install ffmpeg (macOS), apt install ffmpeg (Debian)." >&2
  exit 1
}

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# Hold counts per scene, at 10 fps: scan is motion, review and report are read.
hold_for() {
  case "$1" in
    *-scan)   echo 5  ;;   # 0.5s each, four of them
    *-review) echo 28 ;;   # 2.8s — the 21.5 GiB frame
    *-run)    echo 6  ;;   # 0.6s each
    *-report) echo 38 ;;   # 3.8s — the payoff, and the last thing on screen
    *)        echo 10 ;;
  esac
}

i=0
for f in "$frames"/*.png; do
  name="$(basename "$f" .png)"
  for _ in $(seq "$(hold_for "$name")"); do
    ln -sf "$(cd "$(dirname "$f")" && pwd)/$(basename "$f")" \
       "$work/$(printf '%05d' "$i").png"
    i=$((i + 1))
  done
done

echo "Assembling $i frames at ${width}px wide…"

# Two passes: a palette built from the whole sequence, then the encode. A
# per-frame palette makes the amber and green shimmer between frames.
ffmpeg -v error -framerate 10 -i "$work/%05d.png" \
  -vf "scale=${width}:-1:flags=lanczos,palettegen=stats_mode=diff" \
  -y "$work/palette.png"

mkdir -p "$(dirname "$out")"
ffmpeg -v error -framerate 10 -i "$work/%05d.png" -i "$work/palette.png" \
  -lavfi "scale=${width}:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=3:diff_mode=rectangle" \
  -loop 0 -y "$out"

echo "wrote $out ($(du -h "$out" | cut -f1))"
