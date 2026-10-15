---
description: PR のコンフリクト・未解決レビュー・失敗している CI をまとめて調べ，必要なものだけ修正してコミットする
argument-hint: [PR番号] [conflict|review|ci ...]
---

PR を「マージ可能な状態」に近づけるため，コンフリクト解消・レビュー対応・CI 修正を順に行う．各フェーズの実作業はサブエージェント（`fix-pr-conflict` / `fix-pr-review` / `fix-pr-ci`）に委譲し，このスキル層は対象の特定・トリアージ・順序制御・最終報告だけを担う．

引数: $ARGUMENTS

## 1. 対象 PR を特定する

- 引数の数値を PR 番号とする．無ければ `gh pr list --head $(git branch --show-current) --json number --jq '.[0].number'` で現在のブランチに紐づく PR を使う．取得できなければ中断して報告する．
- 現在のブランチが PR の head ブランチと異なる場合は `gh pr checkout NUMBER` で切り替える．作業ツリーに未コミットの変更がある場合は切り替えず，中断して報告する．
- 引数に `conflict` / `review` / `ci` が含まれる場合はそのフェーズだけを対象にする（トリアージで「作業なし」と判定されても実行する）．含まれなければ全フェーズを対象にし，トリアージで作業があるものだけ実行する．

## 2. トリアージする

サブエージェントを起動する前に，各フェーズに作業があるかを安く判定する．

- **conflict**: `gh pr view NUMBER --json mergeable,mergeStateStatus` で `mergeable` が `CONFLICTING` のときだけ対象．`UNKNOWN` の場合は数秒置いて一度だけ再取得する．コンフリクトしていない PR は rebase しない（履歴を無意味に書き換え，force push を強いるため）．
- **review**: `fix-pr-review` の手順 1 と同じ GraphQL クエリで `isResolved: false` のスレッド，または `state` が `CHANGES_REQUESTED` / `COMMENTED` で本文が空でないレビューがあれば対象．
- **ci**: `gh pr checks NUMBER --json bucket --jq '[.[] | select(.bucket=="fail")] | length'` が 1 以上なら対象．`pending` しか無い場合は対象外とし，完了待ちである旨を報告に含める．

対象フェーズが 1 つも無ければ，その旨を報告して終了する．

## 3. （任意）Hunk セッションを用意する

`HERDR_ENV=1` の場合，委譲の**前に** `hunk-review` スキルの「Bootstrapping a session」に従って Hunk セッションを用意してよい（herdr 外ではスキップ）．サブエージェントは pane を起動できないため，ここで 1 度だけ用意する．

各フェーズは `hunk session reload` で自分の差分を読み込み直すため，**前のフェーズの注記は次のフェーズで置き換わる**．フェーズごとに確認したい場合は，各フェーズの完了後にユーザーへ確認を取ってから次へ進むこと．

## 4. フェーズを順に委譲する

順序は **conflict → review → ci** で固定する．後のフェーズは前のフェーズの結果（rebase 後のベース・レビュー修正）の上で作業するため，並列にしない．

各フェーズの委譲時は PR 番号と，前のフェーズの返り値の要点（rebase したか・どのファイルを変えたか）を渡す．

- `fix-pr-conflict`: `origin/main` に rebase してコンフリクトを解消する．
- `fix-pr-review`: 未解決レビューをトリアージし，妥当な指摘を適用してコミットし，スレッドへ反映する．
- `fix-pr-ci`: 失敗している CI を診断し，修正可能なものを直してコミットする．

前のフェーズが失敗・中断した場合（rebase を abort した等）は後続フェーズを実行せず，そこで報告する．

## 5. 報告する

全フェーズの返り値を 1 つにまとめて報告する．

- 対象 PR 番号・タイトル
- フェーズごとの実行有無（スキップした場合はトリアージ結果）と結果の要約
- 作成したコミットの一覧（`git log --oneline origin/<head>..HEAD`）
- **push が必要かどうか**．rebase したなら `git push --force-with-lease` が必要であることを冒頭で目立つように示す（push しない限りリモートの PR はコンフリクトしたまま・CI も古い HEAD のまま）．
- ユーザーの判断が必要な残件（各サブエージェントの残件を集約）

## 共通の方針

- **push はしない**．すべてのフェーズでコミットまでに留め，push はユーザーに委ねる．
- `gh` / `git` 操作で SSH 認証・GPG 鍵のエラーが出た場合は停止し，手動実行すべきコマンドを示してユーザーに委ねる．
