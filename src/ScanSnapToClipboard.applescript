-- ScanSnap to Clipboard
-- ScanSnap Home から渡された JPEG ファイルをクリップボードに画像として
-- コピーするための連携アプリケーション。

on open droppedFiles
	set fileCount to count of droppedFiles
	if fileCount = 0 then return
	try
		set lastFile to item fileCount of droppedFiles
		set the clipboard to (read lastFile as JPEG picture)
		if fileCount = 1 then
			display notification "クリップボードにコピーしました" with title "ScanSnap to Clipboard"
		else
			display notification (fileCount as string) & " 件のうち最後の画像をクリップボードにコピーしました" with title "ScanSnap to Clipboard"
		end if
	on error errMsg
		display notification "エラー: " & errMsg with title "ScanSnap to Clipboard"
	end try
end open

on run
	display dialog "このアプリケーションは、ScanSnap Home から渡された JPEG ファイルをクリップボードに画像としてコピーします。" & return & return & "ScanSnap Home のプロファイルで「連携アプリケーション」として登録してご利用ください。" buttons {"OK"} default button "OK" with title "ScanSnap to Clipboard"
end run
