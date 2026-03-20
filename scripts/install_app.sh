#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Markdown.app"
SOURCE_APP="$ROOT/build/$APP_NAME"
TARGET_APP="/Applications/$APP_NAME"

"$ROOT/scripts/build_app.sh"

rm -rf "$TARGET_APP"
cp -R "$SOURCE_APP" "$TARGET_APP"

echo "Installed $TARGET_APP"
