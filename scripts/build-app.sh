#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/Codex Ne Kadar.app"
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/CodexNeKadar.build.XXXXXX")"
BIN="$BUILD_DIR/arm64-apple-macosx/release/CodexNeKadar"
trap 'rm -rf "$BUILD_DIR"' EXIT

cd "$ROOT"
swift build --jobs 1 -c release --scratch-path "$BUILD_DIR"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/CodexNeKadar"
cp "$ROOT/Resources/Info.plist" "$APP/Contents/Info.plist"
codesign --force --sign - "$APP"
echo "Uygulama hazır: $APP"
