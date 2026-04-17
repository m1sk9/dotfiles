---
description: プルリクエストのレビューコメントを取得し，修正すべき指摘を適用する（Copilot 以外のレビュアー対象）
argument-hint: [PR番号]
---

対応するサブエージェント `fix-review` にこのタスクを委譲してください．

引数が指定されていない場合は `gh pr list --head $(git branch --show-current) --json number --jq '.[0].number'` で現在のブランチに紐づく PR 番号を取得し，それを使用してください．

引数: $ARGUMENTS
