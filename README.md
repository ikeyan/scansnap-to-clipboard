# ScanSnap to Clipboard

ScanSnap Home でスキャンした JPEG をそのまま macOS のクリップボードに画像としてコピーする、連携アプリケーションです。

スキャン → どこかに保存 → ファイルを開いて全選択 → コピー、という手順を、スキャンと同時にクリップボードへ載せるショートカットに置き換えます。コピー後はそのまま Slack / メール / メモなどに貼り付けできます。

## 動作環境

- macOS（AppleScript / Launch Services が動く環境）
- ScanSnap Home

## インストール

このリポジトリをクローン（または ZIP ダウンロード）し、同梱されている `ScanSnapToClipboard.app` を `/Applications` などお好みの場所に移動します。

```sh
git clone https://github.com/ikeyan/scansnap-to-clipboard.git
```

ソースからビルドし直したい場合は以下のとおりです。

```sh
cd scansnap-to-clipboard
./build.sh
```

未署名のアプリのため、初回起動時に Gatekeeper の警告が出ることがあります。Finder で右クリック → 「開く」で一度許可するか、システム設定の「プライバシーとセキュリティ」から許可してください。

## ScanSnap Home 側の設定

1. ScanSnap Home でプロファイルを新規追加（または既存プロファイルを編集）。
2. **ファイル形式** を `JPEG (*.jpg)` にする。
3. **連携アプリケーション** で「設定…」→「追加…」を選び、`ScanSnapToClipboard.app` のパスを指定。
4. **連携可能なファイル形式** は「画像データ」→ `JPEG (*.jpg)` をチェック。
5. プロファイルの連携アプリケーションに、追加した `ScanSnapToClipboard` を選択。

以後、このプロファイルでスキャンするたびに、最新の JPEG がクリップボードに画像として乗ります。

## 動作

- ScanSnap Home は連携アプリケーションを `NSWorkspace.launchApplicationAtURL:options:configuration:error:` の `NSWorkspaceLaunchConfigurationArguments` 経由で起動するため、JPEG のパスは **argv** で渡ってきます（`on open` の Apple Event ではありません）。本アプリはそのパスを `osascript` 経由で `read ... as JPEG picture` し、`set the clipboard to ...` で画像としてクリップボードへセットします。
- バンドルは中身が小さなシェルスクリプトの `.app`（`LSUIElement = true` で Dock アイコンも出さない）。
- 複数ファイルが渡された場合は最後の 1 枚をコピーします。
- クリップボードへのコピーに成功したら、ScanSnap が保存先（既定では `~/Documents/`）に書き出した元 JPEG を削除します。コピーに失敗した場合は安全のため残します。
- 完了時に macOS の通知センターへ通知を出します。
- 起動ログは `~/Library/Logs/ScanSnapToClipboard.log` に追記されるので、うまく動かない場合はそこを確認してください。

## テスト

`./tests/run-tests.sh` を実行すると、ビルド済みバイナリを ScanSnap と同じ呼び方 (argv 渡し) で叩き、クリップボードへのコピーとファイル削除の挙動を検証します。作業ディレクトリは `mktemp -d -t ...` で `$TMPDIR` 配下に切るため `/tmp` は触りません。クリップボードの初期内容に依存しないように、状態を確認するテストでは事前に sentinel 文字列をセットしてから比較します。

## ライセンス

MIT License
