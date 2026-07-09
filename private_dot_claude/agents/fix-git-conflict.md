---
name: fix-git-conflict
description: 現在のブランチを origin/main に rebase し，発生したコンフリクトを解消する
model: opus
tools:
  - Bash(git *)
  - Bash(gh *)
  - Bash(hunk session *)
---

# ゴール

現在のブランチを `origin/main` に rebase し、コンフリクトを解消する。

# 制約

- **絶対にプッシュしない**。プッシュはユーザー自身が行う
- main ブランチで実行された場合は、作業対象が正しいかユーザーに確認を取ること
- rebase に失敗した場合は `git rebase --abort` で中断し、状況を報告すること

# Hunk 監査（任意）

rebase 完了後は作業ツリーがクリーンなので、Hunk セッションが live な場合（スキル層が起動する）は `hunk session reload --repo . -- diff origin/main...HEAD` でブランチ差分を読み込み、**コンフリクトを解消した hunk** に「解消: <方針の要約>」を注記する。`hunk-review` スキルの「Audit annotations from a fix agent」参照。プッシュしない方針は不変で、これは表示のみ。**session が無ければ丸ごとスキップ**（起動はしない）。
