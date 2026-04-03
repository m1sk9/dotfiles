---
description: 指定された PR の GitHub Actions 失敗原因を調査し，修正を適用する
argument-hint: [PR番号]
---

対応するサブエージェント `fix-ci` にこのタスクを委譲してください．

引数が指定されていない場合は `gh pr list --head $(git branch --show-current) --json number --jq '.[0].number'` で現在のブランチに紐づく PR 番号を取得し，それを使用してください．

引数: $ARGUMENTS
