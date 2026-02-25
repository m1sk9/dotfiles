---
description: staged な変更を分析して適切なコミットメッセージを生成する
allowed-tools: Bash(git diff --staged), Bash(git diff *)
---

staged な変更内容を `git diff --staged` で取得し，適切なコミットメッセージを生成してください．

## ルール

- Conventional Commits 形式を使用する: `<type>(<scope>): <subject>`
- type は以下から選択: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`, `build`
- scope は変更されたモジュール・ファイル・機能の名前（省略可）
- subject は英語，命令形，小文字始まり，末尾ピリオドなし
- 変更が複雑な場合は body も追加（1行空けて記述）
- 日本語での補足説明を body に入れても良い

## 手順

1. `git diff --staged` を実行して変更内容を確認する
2. 変更の種類・影響範囲・意図を分析する
3. 最適なコミットメッセージを提案する
4. 複数の候補がある場合は 2〜3 案提示する

staged な変更がない場合は `git diff HEAD` も確認すること．
