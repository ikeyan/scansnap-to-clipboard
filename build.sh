#!/usr/bin/env bash
# .app バンドルをビルドします。
set -euo pipefail

cd "$(dirname "$0")"

OUT="ScanSnapToClipboard.app"

rm -rf "$OUT"
mkdir -p "$OUT/Contents/MacOS"
mkdir -p "$OUT/Contents/Resources"

cp src/Info.plist "$OUT/Contents/Info.plist"
cp src/ScanSnapToClipboard.sh "$OUT/Contents/MacOS/ScanSnapToClipboard"
chmod +x "$OUT/Contents/MacOS/ScanSnapToClipboard"
printf 'APPL????' >"$OUT/Contents/PkgInfo"

# ad-hoc 署名 (Gatekeeper の初回警告を緩和)
codesign --force --sign - "$OUT" >/dev/null 2>&1 || true

echo "Built: $OUT"
