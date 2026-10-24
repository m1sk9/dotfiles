---
description: macOS の現在のシステム設定と，一括設定用 Lua スクリプトの settings 表との齟齬を洗い出し，解消する
---

`~/dotfiles/.chezmoiscripts/run_onchange_after_configure-macos-defaults.lua` の `settings` 表と，実機の `defaults` の現在値を突き合わせ，食い違いを解消する．表に載っているキーだけを対象にする（`defaults read <domain>` の全量 diff はノイズが大きく，意図した変更か判別できないため，表に無いキーは検出しない）．

## 1. 表を読む

Lua ファイルを読み，`settings`（ドメイン → キー → 値）と `restarts` を把握する．

## 2. 実機と比較する

表の各 `domain` / `key` について `defaults read <domain> <key> 2>/dev/null` を実行し，Lua スクリプトの `encode` / `current` と同じ規則で期待値と比較する．

- bool: `true` → `1`，`false` → `0`
- 数値: `%g` 書式の文字列（整数・小数とも）
- 文字列: そのまま
- read の出力が空（エラー）: 実機で「未設定」として扱う

Bash ツールは zsh で評価されるので，複数キーはループで 1 コマンドにまとめてよい（`for` / `do` / `done`）．

`luajit -e` にインラインで書かず，スクラッチパッドの `.lua` ファイルに書き出して実行する．シェルと Lua の二重クォートで壊れやすく，特に Lua の `\047` は 10 進数のエスケープで `'` ではなく `/` になる．全キーが「未設定」になったら，比較側の不具合を疑って `defaults read <domain> <key>` を 1 件直接実行して確かめる．

## 3. 差分を報告する

食い違いを 1 行ずつ一覧にする: `domain key: 表=… / 実機=…`．差分が無ければ，その旨を報告して終了する．

あわせて，`settings` にあるが `restarts` に無いドメインを報告する（Dock などの再起動が走らない原因になる．再起動が不要なドメインもあるので，指摘に留める）．

## 4. 解消方向を決める

方向は差分ごとにユーザーへ確認する．まとめて選べる場合は一度に聞いてよい．

- **実機が正**（GUI で変えた）: 表の値を実機の値に更新する．値の Lua 型は元の表に合わせる（`true` / 整数 / 文字列）．
- **表が正**: 表は編集しない．次の `chezmoi apply` で実機が表に揃う．

## 5. 反映する

表を編集した場合のみ行う．

1. `chezmoi diff` で差分を確認し，`chezmoi apply` を実行する．
2. 「表が正」とされた差分を実機へ反映するには，Lua スクリプトを直接実行する（`luajit ~/dotfiles/.chezmoiscripts/run_onchange_after_configure-macos-defaults.lua`）．`run_onchange_` は表が変わったときしか再実行されないので，表を編集しなかった場合は apply では反映されない．
3. `git add` → `git commit` → `git push`．コミットは Conventional Commits の英語で，本文に Why（なぜ表を実機に合わせたか）を書く．

## 方針

- 表のコメント規約に合わせる（既存の Why / Why not コメントは残し，値の変更で嘘になるものだけ直す）．
- 新しいキーの追加はこのスキルの範囲外．ユーザーが求めた場合のみ，ドメインとキーを表に足す．
