---
description: 自分が開いた Open な PR を順に main へ同期し，コンフリクトを解消して push する
---

# ゴール

現在のリポジトリで、自分（認証中の GitHub アカウント）が開いた Open 状態の PR をすべて `origin/main` へ同期し、コンフリクトがあれば解消した上で push する。

# 手順

1. 開始前に作業ツリーがクリーンかつ現在のブランチを控えておく（処理後に元のブランチへ戻すため）。未コミットの変更がある場合は中断して報告する。
2. `git fetch origin main` で最新の main を取得する。
3. 対象 PR を収集する:
   - `gh pr list --author "@me" --state open --json number,title,headRefName,isDraft`
   - `isDraft == true` の PR は除外する（`--state open` により Closed / Merged は既に除外されている）。
4. 対象 PR が 0 件なら、その旨を報告して終了する。
5. **処理方式を状況から判断する**。各 PR の `headRefName` と差分（必要なら `gh pr diff {number} --name-only`）を見て、変更ファイルの重なり具合・件数から次のいずれかを選ぶ:
   - **worktree 並列**: PR が少なく、変更ファイルの重なりが小さくコンフリクトの連鎖が起きにくい場合。各 PR を per-PR ワーカー `collect-open-pr` サブエージェントに PR 番号を渡し、**worktree 分離（isolation: worktree）**で並列起動して処理させる。worktree 分離により作業ツリーの衝突を避けられる。
   - **直列**: PR が多い、または複数 PR が同じファイルを触りコンフリクトが連鎖しそうな場合。worktree 並列はせず、PR 番号の昇順に 1 件ずつ処理する（メインの作業ツリーで checkout → rebase → 解消 → push、または `collect-open-pr` サブエージェントへ直列に委譲）。連鎖コンフリクトの全体像を把握しやすく安全。
   - どちらを選んだか、その理由を簡潔にユーザーへ伝えてから処理に入ること。
   - コンフリクト解消だけを切り出したい場合は `fix-git-conflict` サブエージェントも利用できる（ただし push はしないため、push は呼び出し元で行う）。
6. 各処理の返り値（PR 番号・結果・コンフリクト概要）を集約する。
7. **後片付け**: worktree 並列を使った場合は、作成した worktree をすべて削除して元の状態に戻す（`git worktree remove`、必要なら `git worktree prune`）。`git worktree list` に余分な worktree が残っていないことを確認する。
8. 控えておいた元のブランチに戻っていることを確認する。

# 制約

- main ブランチで実行された場合や作業ツリーが dirty な場合は、作業対象が正しいかユーザーに確認を取ること。
- force-push は `git push --force` ではなく必ず `git push --force-with-lease` を使うこと。
- 自分の判断でコンフリクトを解消できない・修正が非自明または危険と判断した PR は、無理に対応せず `git rebase --abort` でその PR を一度スキップすること。1 件のスキップで全体を中断せず、残りの PR の処理を続けること。スキップした PR は理由とともに最終報告に必ず含めること。
- push や rebase で SSH 認証・GPG 鍵のエラーが出た場合は、手動実行すべきコマンドを示してユーザーに委ねること。

# 最終報告

処理した PR の一覧と各 PR の結果サマリを示すこと。各 PR について以下を含める:

- PR 番号・タイトル・ブランチ名
- 結果: `同期 & push 済み` / `更新なし（push 不要）` / `コンフリクトでスキップ` / `エラー` のいずれか
- コンフリクトを解消した場合はその概要

引数: $ARGUMENTS
