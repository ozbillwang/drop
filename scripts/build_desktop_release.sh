#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-1.0.0}"
DIST_DIR="$ROOT_DIR/build/release-$VERSION"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR" "$ROOT_DIR/build/windows" "$ROOT_DIR/build/linux"

"$ROOT_DIR/scripts/build_macos_dmg.sh"
cp "$ROOT_DIR/build/macos/Drop.dmg" "$DIST_DIR/Drop-$VERSION-macOS-universal.dmg"

rm -rf "$ROOT_DIR/build/windows"
mkdir -p "$ROOT_DIR/build/windows"
godot --headless --path "$ROOT_DIR" --export-release "Windows Desktop" "$ROOT_DIR/build/windows/Drop.exe"
(cd "$ROOT_DIR/build/windows" && zip -qr "$DIST_DIR/Drop-$VERSION-windows-x86_64.zip" .)

rm -rf "$ROOT_DIR/build/linux"
mkdir -p "$ROOT_DIR/build/linux"
godot --headless --path "$ROOT_DIR" --export-release "Linux/X11" "$ROOT_DIR/build/linux/Drop.x86_64"
chmod +x "$ROOT_DIR/build/linux/Drop.x86_64"
(cd "$ROOT_DIR/build/linux" && zip -qr "$DIST_DIR/Drop-$VERSION-linux-x86_64.zip" .)

(cd "$DIST_DIR" && shasum -a 256 Drop-"$VERSION"-* > SHA256SUMS.txt)

echo "Release artifacts:"
ls -lh "$DIST_DIR"
