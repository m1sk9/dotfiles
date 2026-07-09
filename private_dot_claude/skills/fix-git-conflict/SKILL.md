---
description: main からの rebase でコンフリクトを解消する
---

対応するサブエージェント `fix-git-conflict` にこのタスクを委譲してください．

引数が指定されていない場合は `gh pr list --head $(git branch --show-current) --json number --jq '.[0].number'` で現在のブランチに紐づく PR 番号を取得し，それを使用してください．

`HERDR_ENV=1` の場合，委譲の**前に** `hunk-review` スキルの「Bootstrapping a session」に従って Hunk セッションを用意してよい（herdr 外ではスキップ）．サブエージェントが解消したコンフリクトを inline 注記するので，ユーザーはコミット前に対話的に確認できる．

引数: $ARGUMENTS
