#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Markdown"
APP_BUNDLE_ID="com.elsiepiao.markdown"
BUILD_DIR="$ROOT/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
SDK="$(xcrun --sdk macosx --show-sdk-path)"
PLIST_BUDDY="/usr/libexec/PlistBuddy"

mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

swiftc \
  -sdk "$SDK" \
  -target arm64-apple-macos14.0 \
  -module-name "$APP_NAME" \
  -o "$MACOS_DIR/$APP_NAME" \
  "$ROOT"/App/*.swift \
  "$ROOT"/App/Preview/*.swift \
  "$ROOT"/App/Support/*.swift

cp "$ROOT/App/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$ROOT"/App/Resources/* "$RESOURCES_DIR/"

"$PLIST_BUDDY" -c "Set :CFBundleExecutable $APP_NAME" "$CONTENTS_DIR/Info.plist"
"$PLIST_BUDDY" -c "Set :CFBundleIdentifier $APP_BUNDLE_ID" "$CONTENTS_DIR/Info.plist"
"$PLIST_BUDDY" -c "Set :CFBundleName $APP_NAME" "$CONTENTS_DIR/Info.plist"

codesign --force --deep --sign - "$APP_DIR"

echo "Built $APP_DIR"
