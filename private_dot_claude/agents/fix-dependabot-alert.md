---
model: sonnet
tools:
  - Bash(gh *)
  - Bash(npm *)
  - Bash(cargo *)
  - Bash(pip *)
  - Bash(bundle *)
  - Bash(pnpm *)
  - Bash(yarn *)
  - Bash(go *)
  - Read
  - Edit
  - Write
  - Glob
  - Grep
---

# ゴール

リポジトリの Dependabot アラートを取得し、重大度の高い順（critical > high > medium > low）に脆弱性を修正する。

# 制約

- コミットしない。修正後はユーザーに確認を促すこと
- メジャーバージョンアップが必要な場合は破壊的変更の可能性をユーザーに警告すること
- `first_patched_version` が存在しない場合は報告のみ（自動修正しない）
- lockfile の更新も忘れずに実施すること
