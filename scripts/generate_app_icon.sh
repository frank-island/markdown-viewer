#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_SVG="$ROOT/design/icons/obsidian-ribbon.svg"
OUTPUT_ICNS="$ROOT/App/Resources/AppIcon.icns"
TMP_DIR="$(mktemp -d)"
ICONSET_DIR="$TMP_DIR/AppIcon.iconset"

mkdir -p "$ICONSET_DIR"

render_png() {
  local size="$1"
  local name="$2"
  /opt/homebrew/bin/rsvg-convert \
    --width "$size" \
    --height "$size" \
    "$SOURCE_SVG" \
    --output "$ICONSET_DIR/$name"
}

render_png 16 icon_16x16.png
render_png 32 icon_16x16@2x.png
render_png 32 icon_32x32.png
render_png 64 icon_32x32@2x.png
render_png 128 icon_128x128.png
render_png 256 icon_128x128@2x.png
render_png 256 icon_256x256.png
render_png 512 icon_256x256@2x.png
render_png 512 icon_512x512.png
render_png 1024 icon_512x512@2x.png

iconutil -c icns "$ICONSET_DIR" -o "$OUTPUT_ICNS"
rm -rf "$TMP_DIR"

echo "Generated $OUTPUT_ICNS from $SOURCE_SVG"
