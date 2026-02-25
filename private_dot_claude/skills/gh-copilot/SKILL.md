---
description: GitHub Copilot のプルリクエストレビューを取得し，修正すべき指摘を適用する
argument-hint: [PR番号]
allowed-tools: Bash(gh *), Read, Edit, Write, Glob, Grep
---

# タスク: GitHub Copilot レビューの取得と修正

GitHub Copilot がプルリクエストに送ったレビューを取得し，修正すべき指摘を判断して適用してください．

## 手順

### 1. PR 番号の特定

引数が指定された場合は `$ARGUMENTS` を PR 番号として使用してください．
指定がない場合は以下の方法で現在の PR を特定してください：

```bash
gh pr view --json number,title,headRefName
```

### 2. GitHub Copilot レビューの取得

以下のコマンドで当該 PR に対するすべてのレビューコメントを取得してください：

```bash
# PR 全体のレビュー一覧（Copilot のレビューサマリーを含む）
gh api repos/{owner}/{repo}/pulls/{PR番号}/reviews

# インラインのレビューコメント一覧
gh api repos/{owner}/{repo}/pulls/{PR番号}/comments
```

リポジトリの owner と repo 名は以下で取得してください：

```bash
gh repo view --json owner,name
```

### 3. GitHub Copilot のレビューを抽出

取得したレビューおよびコメントの中から，`user.login` が `"github-copilot[bot]"` または `"copilot-pull-request-reviewer[bot]"` のものだけを抽出してください．

### 4. 指摘内容の分析と判断

各 Copilot コメントについて以下の観点で判断してください：

**修正すべき（Fix）：**
- バグ・ロジックエラーの指摘
- セキュリティ上の問題
- パフォーマンスの明確な問題
- Null 安全性・型安全性の問題
- エラーハンドリングの欠落
- 明らかなコードの誤り

**修正不要（Skip）：**
- 既存のコードベースのスタイル・慣習に従っている場合
- プロジェクト固有の理由で意図的な実装である場合
- 指摘が過度に保守的・好みの問題の場合
- 変更により別の問題が生じる可能性がある場合
- Copilot の指摘内容が文脈を理解していない場合

### 5. 修正の実施

修正すべき指摘について：

1. 該当ファイルを Read ツールで読み込み，現在のコードを確認する
2. 指摘の `diff_hunk` と `path`，`line` を参照して該当箇所を特定する
3. Edit ツールで修正を適用する
4. 修正内容の概要を記録する

### 6. 結果の報告

以下の形式で報告してください：

```
## GitHub Copilot レビュー対応結果

### 修正した指摘 (N 件)

1. **[ファイルパス:行番号]** - {指摘の要約}
   - 理由: {なぜ修正したか}
   - 変更: {何をどう変えたか}

### 修正しなかった指摘 (M 件)

1. **[ファイルパス:行番号]** - {指摘の要約}
   - 理由: {なぜ現状のままでよいか}
```

Copilot のレビューが存在しない場合は「GitHub Copilot のレビューコメントは見つかりませんでした」と報告してください．

---

対象 PR: $ARGUMENTS
