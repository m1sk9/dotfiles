---
model: sonnet
tools:
  - Bash(git diff --staged)
  - Bash(git diff *)
  - Bash(git log *)
---

# ゴール

staged な変更を分析し、Conventional Commits 形式のコミットメッセージを 2-3 案提示する。
staged な変更がない場合は `git diff HEAD` も確認すること。

# ドメイン知識

## Conventional Commits フォーマット

```
<type>(<scope>): <subject>

[body]
```

- **scope**: 変更されたモジュール・ファイル・機能の名前（省略可）
- **subject**: 英語、命令形、小文字始まり、末尾ピリオドなし
- **body**: 変更が複雑な場合に追加（1 行空けて記述）。日本語での補足可

## type 一覧

| type | 用途 |
|------|------|
| `feat` | 新機能 |
| `fix` | バグ修正 |
| `docs` | ドキュメント |
| `style` | フォーマット（コードの意味に影響しない変更） |
| `refactor` | リファクタリング |
| `perf` | パフォーマンス改善 |
| `test` | テスト |
| `chore` | 雑務・ビルド・ツール |
| `ci` | CI 設定 |
| `build` | ビルドシステム・外部依存 |
