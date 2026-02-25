---
description: PR の説明マークダウンを生成してクリップボードにコピーする
disable-model-invocation: true
allowed-tools: Bash(git *)
---

現在のブランチと base ブランチの差分を分析して，GitHub PR の説明マークダウンを生成し，クリップボードにコピーしてください．

引数で言語を指定できます：
- `ja` または `japanese` → 日本語で生成
- `en` または `english` → 英語で生成（デフォルト）

引数が指定されていない場合は英語で生成します．

## 手順

1. `git branch --show-current` で現在のブランチ名を確認する
2. `git log main..HEAD --oneline` でコミット一覧を取得する（main がなければ master や develop を試す）
3. `git diff main...HEAD` で差分全体を確認する
4. 指定された言語（デフォルト: 英語）でテンプレートに従い PR 説明を生成する
5. 生成した内容を `pbcopy` でクリップボードにコピーする

## PR 説明テンプレート（英語）

<!-- Brief summary of what and why -->

## PR 説明テンプレート（日本語）

<!-- このPRで何をしたか，なぜしたかを簡潔に -->

## ルール（英語の場合）

- Write the summary concisely in English (2-3 sentences)
- Group changes by feature/fix, not by commit
- Wrap error names and variable names in backticks
- Remove template comments and replace with actual content
- Copy to clipboard with `echo "<content>" | pbcopy`
- Report "Copied to clipboard" after copying

## ルール（日本語の場合）

- 概要は日本語で簡潔に（2〜3文程度）
- 句読点「，」「．」を守る
- 変更内容はコミット単位ではなく機能・修正単位でまとめる
- エラー名や変数名などの英語部分は ` ` で囲む
- テンプレートのコメントは削除して実際の内容に置き換える
- クリップボードへのコピーは `echo "<内容>" | pbcopy` で実行する
- コピー完了後に「クリップボードにコピーしました」と報告する
