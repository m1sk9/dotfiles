---
description: Hunk セッションに自分で書いた inline コメントを読み，指摘をローカルに適用する
argument-hint: [file for scope, optional]
---

対応するサブエージェント `apply-hunk-comments` にこのタスクを委譲してください．

稼働中の Hunk セッションが無い場合は，指摘のソースが存在しないため，ユーザーに `hunk diff` の起動とコメント追加を促してください．

引数: $ARGUMENTS
