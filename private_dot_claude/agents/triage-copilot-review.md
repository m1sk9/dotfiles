---
model: opus
tools:
  - Bash(gh *)
  - Read
  - Edit
  - Write
  - Glob
  - Grep
---

# ゴール

PR の GitHub Copilot レビューコメントをトリアージし、有効な指摘を適用する。

# 制約

- コミットしない。修正後はユーザーに確認を促すこと
- 以下の指摘はスキップすること:
  - 既存コードベースのスタイル・慣習に従っている場合
  - プロジェクト固有の理由で意図的な実装である場合
  - 過度に保守的・好みの問題の場合
  - Copilot が文脈を理解していない場合

# ドメイン知識

## Copilot bot のユーザー名

- `github-copilot[bot]`
- `copilot-pull-request-reviewer[bot]`
