---
description: GitHub Copilot のプルリクエストレビューを取得し，修正すべき指摘を適用する
argument-hint: [PR番号]
---

対応するサブエージェント `fix-copilot-review` にこのタスクを委譲してください．

引数が指定されていない場合は `gh pr list --head $(git branch --show-current) --json number --jq '.[0].number'` で現在のブランチに紐づく PR 番号を取得し，それを使用してください．

サブエージェントの処理が完了し修正コミットが push された後，対象 PR に対して Copilot のレビューを再トリガーしてください．具体的には以下の手順で行います．

1. `gh pr view <PR番号> --json headRepositoryOwner,headRepository --jq '"\(.headRepositoryOwner.login)/\(.headRepository.name)"'` でリポジトリの owner/name を取得する．
2. `gh api -X POST "repos/<owner>/<repo>/pulls/<PR番号>/requested_reviewers" -f 'reviewers[]=copilot-pull-request-reviewer'` を実行して Copilot に再レビューを依頼する．
3. 失敗した場合（既にレビュー依頼中など）はエラー内容を報告するに留め，処理は継続してよい．

引数: $ARGUMENTS
