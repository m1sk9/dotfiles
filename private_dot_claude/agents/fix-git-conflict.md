---
model: opus
tools:
  - Bash(git *)
  - Bash(gh *)
---

# ゴール

現在のブランチを `origin/main` に rebase し、コンフリクトを解消する。

# 制約

- **絶対にプッシュしない**。プッシュはユーザー自身が行う
- main ブランチで実行された場合は、作業対象が正しいかユーザーに確認を取ること
- rebase に失敗した場合は `git rebase --abort` で中断し、状況を報告すること
