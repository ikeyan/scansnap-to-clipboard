#!/bin/bash
# 統合テスト。ビルド済み .app のバイナリを直接 ScanSnap と同じ呼び方
# (argv 渡し) で叩いて、クリップボードとファイル削除の挙動を検証する。
#
# 作業ディレクトリは mktemp -d (macOS では $TMPDIR 配下) を使う。
# クリップボードの初期内容に依存しないように設計してある。

set -u

cd "$(dirname "$0")/.."
./build.sh >/dev/null

APP="$PWD/ScanSnapToClipboard.app/Contents/MacOS/ScanSnapToClipboard"
WORK=$(mktemp -d -t scansnap-to-clipboard-tests)
trap 'rm -rf "$WORK"' EXIT

pass=0
fail=0

mk_jpeg() {
	# 128x128 のダミー JPEG (有効な最小限のバイト列)
	python3 - "$1" <<'PY'
import sys
open(sys.argv[1], "wb").write(bytes.fromhex(
    "ffd8ffe000104a46494600010100000100010000"
    "ffdb0043000806060706050807070709090807090a0c14"
    "0d0c0b0b0c19121309141d1a1f1e1d1a1c1c20242e2720"
    "222c231c1c2837292c30313434341f27393d38323c2e33"
    "3432ffc0000b0801000100010111003fffd9"
))
PY
}

clipboard_jpeg_to() {
	osascript >/dev/null 2>&1 <<EOF
try
    set img to the clipboard as JPEG picture
    set fp to open for access POSIX file "$1" with write permission
    set eof fp to 0
    write img to fp
    close access fp
end try
EOF
}

set_clipboard_text() {
	osascript -e "set the clipboard to \"$1\"" >/dev/null 2>&1
}

clipboard_text() {
	osascript 2>/dev/null <<'EOF'
try
    return the clipboard as text
on error
    return ""
end try
EOF
}

assert() {
	local desc="$1"
	shift
	if "$@"; then
		printf '  \033[32mPASS\033[0m %s\n' "$desc"
		pass=$((pass + 1))
	else
		printf '  \033[31mFAIL\033[0m %s\n' "$desc"
		fail=$((fail + 1))
	fi
}

run_test() {
	echo "[$1]"
	"$2"
	echo
}

test_basic_single_jpeg() {
	local f="$WORK/scan.jpg"
	mk_jpeg "$f"
	"$APP" "$f" >/dev/null 2>&1
	assert "渡されたファイルが削除される" test ! -e "$f"
	local out="$WORK/out.jpg"
	clipboard_jpeg_to "$out"
	assert "クリップボードに JPEG が入っている" test -s "$out"
}

test_multiple_files() {
	local f1="$WORK/a.jpg" f2="$WORK/b.jpg"
	mk_jpeg "$f1"
	mk_jpeg "$f2"
	"$APP" "$f1" "$f2" >/dev/null 2>&1
	assert "1 番目のファイルが削除される" test ! -e "$f1"
	assert "2 番目のファイルが削除される" test ! -e "$f2"
	local out="$WORK/out.jpg"
	clipboard_jpeg_to "$out"
	assert "クリップボードに JPEG が入っている" test -s "$out"
}

test_nonexistent_argv() {
	local sentinel="ssc-sentinel-${RANDOM}-${RANDOM}"
	set_clipboard_text "$sentinel"
	"$APP" "$WORK/no-such-file.jpg" >/dev/null 2>&1
	local got
	got=$(clipboard_text)
	assert "存在しない引数ではクリップボードを変更しない" test "$got" = "$sentinel"
}

test_broken_jpeg_kept() {
	# 空ファイルは osascript の `read ... as JPEG picture` がエラー (-39)
	# になる。コピー失敗時はファイルを残す挙動を検証。
	local f="$WORK/broken.jpg"
	: >"$f"
	"$APP" "$f" >/dev/null 2>&1
	assert "コピー失敗時に元ファイルを残す" test -e "$f"
}

run_test "基本: 1 枚の JPEG" test_basic_single_jpeg
run_test "複数ファイル渡し" test_multiple_files
run_test "存在しない argv パス" test_nonexistent_argv
run_test "壊れた JPEG (空ファイル)" test_broken_jpeg_kept

echo "Passed: $pass / Failed: $fail"
[ "$fail" -eq 0 ]
