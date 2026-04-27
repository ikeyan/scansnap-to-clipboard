#!/usr/bin/env bash
# .app バンドルをビルドします。
set -euo pipefail

cd "$(dirname "$0")"

SRC="src/ScanSnapToClipboard.applescript"
OUT="ScanSnapToClipboard.app"

rm -rf "$OUT"
osacompile -o "$OUT" "$SRC"

echo "Built: $OUT"
