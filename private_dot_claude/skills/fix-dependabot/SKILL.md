---
description: Dependabot アラートを取得し，脆弱性のある依存関係を修正する
argument-hint: [owner/repo or empty for current repo]
---

対応するサブエージェント `fix-dependabot` にこのタスクを委譲してください．

`HERDR_ENV=1` の場合，委譲の**前に** `hunk-review` スキルの「Bootstrapping a session」に従って Hunk セッションを用意してよい（herdr 外ではスキップ）．サブエージェントが依存・lockfile の変更を inline 注記するので，ユーザーはコミット前に対話的に確認できる．

引数: $ARGUMENTS
