---
description: main からの rebase でコンフリクトを解消する
---

対応するサブエージェント `fix-git-conflict` にこのタスクを委譲してください．

引数が指定されていない場合は `gh pr list --head $(git branch --show-current) --json number --jq '.[0].number'` で現在のブランチに紐づく PR 番号を取得し，それを使用してください．

引数: $ARGUMENTS
