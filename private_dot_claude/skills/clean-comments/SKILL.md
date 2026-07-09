---
description: 不要なコメントを削除し、重要なコメントにラベルを付与
argument-hint: [file or directory]
---

対応するサブエージェント `clean-comments` にこのタスクを委譲してください．

`HERDR_ENV=1` の場合，委譲の**前に** `hunk-review` スキルの「Bootstrapping a session」に従って Hunk セッションを用意してよい（herdr 外ではスキップ）．サブエージェントがコメントの削除・ラベル付与を inline 注記するので，ユーザーはコミット前に対話的に確認できる．

引数: $ARGUMENTS
