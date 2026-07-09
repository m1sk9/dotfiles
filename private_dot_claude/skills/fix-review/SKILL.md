---
description: PR の全レビュー（人間・Copilot・その他 Bot）を取得し，修正すべき指摘を適用する
argument-hint: [PR番号]
---

対応するサブエージェント `fix-review` にこのタスクを委譲してください．

引数が指定されていない場合は `gh pr list --head $(git branch --show-current) --json number --jq '.[0].number'` で現在のブランチに紐づく PR 番号を取得し，それを使用してください．

`HERDR_ENV=1` の場合，委譲の**前に** `hunk-review` スキルの「Bootstrapping a session」に従って Hunk セッションを用意してよい（herdr 外ではスキップ）．サブエージェントが適用・スキップ内容を inline 注記するので，ユーザーはコミット前に対話的に確認できる．

引数: $ARGUMENTS
