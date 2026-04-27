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

- ScanSnap Home から渡された JPEG を AppleScript の `read ... as JPEG picture` で読み込み、`set the clipboard to ...` でクリップボードに画像としてセットします。
- 複数ファイルが渡された場合は最後の 1 枚をコピーします（典型的には 1 ファイルのみ渡される想定）。
- 完了時に macOS の通知センターへ通知を出します。

## ライセンス

MIT License
