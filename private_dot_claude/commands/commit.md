---
description: 編集したファイルをコミット・プッシュする
---

# タスク: 変更ファイルのコミットとプッシュ

以下の手順で変更をコミット・プッシュしてください：

## 1. 変更ファイルの確認

`git status` と `git diff --name-only` を実行し，未コミットの変更ファイルを一覧化してください．

引数の処理：
- 引数が指定された場合: `$ARGUMENTS` で指定されたファイルのみを対象とする
- 引数がない場合: すべての未コミットの変更ファイルを対象とする

## 2. 変更内容の把握

`git diff` および `git diff --staged` を実行し，各ファイルの変更内容を把握してください．
新規ファイルの場合は `git diff` に表示されないため，ファイルの内容を直接確認してください．

## 3. ユーザーへの確認

以下を提示し，処理を続行するか確認してください：
- 対象ファイルの一覧
- 各ファイルの変更概要（追加・変更・削除の簡潔な説明）

## 4. コミットメッセージの生成

変更内容に基づき，**Conventional Commits** 仕様に従ってコミットメッセージを生成してください．

### Conventional Commits のフォーマット：

```
<type>[optional scope]: <description>

[optional body]
```

### type の選定基準：
- **feat**: 新機能の追加
- **fix**: バグ修正
- **docs**: ドキュメントのみの変更
- **style**: コードの意味に影響しない変更（空白，フォーマット，セミコロンの追加等）
- **refactor**: バグ修正でも機能追加でもないコード変更
- **perf**: パフォーマンスを改善するコード変更
- **test**: テストの追加・修正
- **build**: ビルドシステムや外部依存に影響する変更
- **ci**: CI 設定ファイルやスクリプトの変更
- **chore**: その他の変更（ソースやテストファイルを変更しない）

### メッセージのルール：
- description は英語で，小文字で始め，末尾にピリオドを付けない
- 命令形で書く（例: add feature / added feature ではなく add feature）
- scope は変更対象のモジュールやコンポーネント名を使う（任意）
- 破壊的変更 (BREAKING CHANGE) がある場合は type の直後に感嘆符を付ける
- body にはより詳細な変更理由や内容を記載する（複数ファイルにまたがる変更や，意図が明確でない変更の場合）

### メッセージの例：
- feat(auth): add JWT token refresh endpoint
- fix: resolve race condition in database connection pool
- docs: update API reference for v2 endpoints
- refactor(core): migrate from callbacks to async/await

## 5. コミットメッセージの確認

生成したコミットメッセージをユーザーに提示し，問題がなければ次に進んでください．
ユーザーが修正を希望した場合は，修正を反映してください．

## 6. コミットとプッシュの実行

1. `git add` で対象ファイルをステージングする
2. `git commit` でコミットする
3. `git push` で現在のブランチにプッシュする

### 署名について：
- Claude Code の設定 `includeCoAuthoredBy` に従ってください
- この設定が有効な場合，Claude Code が自動的に Co-authored-by トレーラーを付与します
- コミットコマンドに署名に関するオプションを手動で追加する必要はありません

## 7. 完了報告

以下を報告してください：
- コミットハッシュ（短縮形）
- コミットメッセージ
- プッシュ先のブランチ名
- プッシュの成否

---

対象: $ARGUMENTS
