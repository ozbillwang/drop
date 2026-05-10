#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build/macos"
STAGING_DIR="$BUILD_DIR/staging"
ZIP_PATH="$BUILD_DIR/Drop-macos.zip"
DMG_PATH="$BUILD_DIR/Drop.dmg"

mkdir -p "$BUILD_DIR"
rm -rf "$STAGING_DIR" "$ZIP_PATH" "$DMG_PATH"
mkdir -p "$STAGING_DIR"

godot --headless --path "$ROOT_DIR" --export-release "macOS" "$ZIP_PATH"
unzip -q "$ZIP_PATH" -d "$STAGING_DIR"

APP_PATH="$(find "$STAGING_DIR" -maxdepth 1 -name "*.app" -type d | head -n 1)"
if [[ -z "$APP_PATH" ]]; then
	echo "No .app bundle found after export." >&2
	exit 1
fi

codesign --force --deep --sign - "$APP_PATH"
hdiutil create -volname "Drop" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_PATH"

echo "Created $DMG_PATH"
