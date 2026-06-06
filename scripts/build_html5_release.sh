#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
TEMP_DIR="$BUILD_DIR/web_release_temp"
RELEASE_ZIP="$BUILD_DIR/web_release.zip"
EXPORT_PATH="$BUILD_DIR/web.zip"

rm -rf "$TEMP_DIR" "$EXPORT_PATH" "$RELEASE_ZIP"
mkdir -p "$TEMP_DIR"

# Export HTML5. Godot may emit web assets and a .zip file that is actually HTML.
godot --headless --path "$ROOT_DIR" --export-release "HTML5" "$EXPORT_PATH"

# Prefer the actual HTML export file if Godot wrote it to web.zip, otherwise fall back to web.html or archive contents.
if [[ -f "$EXPORT_PATH" ]] && file "$EXPORT_PATH" | grep -q 'HTML document'; then
  cp "$EXPORT_PATH" "$TEMP_DIR/index.html"
elif [[ -f "$BUILD_DIR/web.html" ]]; then
  cp "$BUILD_DIR/web.html" "$TEMP_DIR/index.html"
elif [[ -f "$EXPORT_PATH" ]]; then
  unzip -q "$EXPORT_PATH" -d "$TEMP_DIR"
  if [[ -f "$TEMP_DIR/web.html" && ! -f "$TEMP_DIR/index.html" ]]; then
    mv "$TEMP_DIR/web.html" "$TEMP_DIR/index.html"
  fi
else
  echo "No HTML5 export output found in $BUILD_DIR" >&2
  exit 1
fi

# Copy the standard Godot HTML5 assets.
for asset in web.js web.wasm web.pck web.png web.icon.png web.apple-touch-icon.png web.audio.worklet.js web.audio.position.worklet.js; do
  if [[ -f "$BUILD_DIR/$asset" ]]; then
    cp "$BUILD_DIR/$asset" "$TEMP_DIR/"
  fi
done

(cd "$TEMP_DIR" && zip -qr "$RELEASE_ZIP" .)
echo "Created HTML5 release package: $RELEASE_ZIP"
ls -lh "$RELEASE_ZIP"
