#!/bin/bash
# ScanSnap to Clipboard
# ScanSnap Home から argv 経由で渡された JPEG ファイルをクリップボードに
# 画像としてコピーする。

LOG="$HOME/Library/Logs/ScanSnapToClipboard.log"
mkdir -p "$(dirname "$LOG")"

{
	printf '\n===== %s =====\n' "$(date '+%Y-%m-%d %H:%M:%S')"
	printf 'argv (%d):\n' "$#"
	i=0
	for a in "$@"; do
		printf '  [%d] %s\n' "$i" "$a"
		i=$((i + 1))
	done
} >>"$LOG" 2>&1

notify() {
	/usr/bin/osascript -e "display notification \"$1\" with title \"ScanSnap to Clipboard\"" >/dev/null 2>&1 || true
}

# Last existing path wins (matches the original "last image wins" behaviour).
input=""
for a in "$@"; do
	if [ -e "$a" ]; then
		input="$a"
	fi
done

if [ -z "$input" ]; then
	echo "no file in argv" >>"$LOG"
	notify "ファイルが渡されませんでした"
	exit 0
fi

esc=$(printf '%s' "$input" | sed 's/\\/\\\\/g; s/"/\\"/g')

if /usr/bin/osascript -e "set the clipboard to (read (POSIX file \"$esc\") as JPEG picture)" >>"$LOG" 2>&1; then
	echo "copied: $input" >>"$LOG"
	notify "クリップボードにコピーしました"
else
	echo "copy failed: $input" >>"$LOG"
	notify "コピーに失敗しました (ログ参照)"
fi
