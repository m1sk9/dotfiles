---
description: 現在のブランチの PR の変更を Gemini CLI にレビューさせ，結果を PR レビューコメントとして投稿する
disable-model-invocation: true
argument-hint: [PR番号]
allowed-tools: Bash(git *), Bash(gemini *), Bash(gh *), Read, Write, Task
---

# タスク: Gemini CLI による PR コードレビュー

以下の手順で現在のブランチの PR をレビューし，結果を投稿してください．

> [!IMPORTANT]
> このスキルのコマンドは Claude が Bash ツール（zsh）で実行する前提で書いてある．コマンド置換は fish 専用の `(cmd)` ではなく `$(cmd)` を使うこと．

## 1. PR 番号の取得

引数 `$ARGUMENTS` で PR 番号が指定されている場合はそれを使用してください．

指定がない場合は，以下のコマンドで現在のブランチに紐づく PR 番号を取得してください：

```sh
gh pr list --head "$(git branch --show-current)" --json number --jq '.[0].number'
```

PR が見つからない場合は，その旨を報告して停止してください．

## 2. レビュー素材を生成する

> [!WARNING]
> **生 diff を丸ごと Gemini に渡してはいけない．** diff のメタ行（`+++ b/...` / `--- a/...` / `@@ ... @@` / `index ...` / ファイルパス見出し）をモデルが「コード本体に混入したゴミ」と誤読し，「`@Test` がパスに置換されコンパイル不能」といった**自信満々の幻覚**を生む原因になる（実例あり）．
>
> 対策として，**変更後ファイルの全文を主素材**にし，diff は「何が変わったか」の参考として末尾に添える．これによりモデルが実コードを根拠に判断できる．

`main...HEAD` で変更されたファイルの全文（削除ファイルは除く）と，参考用の unified diff を `/tmp/gemini_input.md` にまとめてください．インライン投稿のため，全文には**行番号を付与**（`cat -n`）し，さらに「変更後ファイル側でインラインコメント可能な行番号」を `/tmp/gemini_diff_lines.txt` に `path<TAB>line` 形式で抽出します：

```sh
BASE=main
INPUT=/tmp/gemini_input.md
DIFF_LINES=/tmp/gemini_diff_lines.txt
FILES=$(git diff "$BASE...HEAD" --name-only --diff-filter=ACMR)

if [ -z "$FILES" ]; then
  echo "EMPTY: レビュー対象の変更がありません"
else
  {
    echo "# レビュー対象: $BASE...HEAD で変更されたファイルの全文（変更後の状態・行番号つき）"
    echo "$FILES" | while IFS= read -r f; do
      [ -f "$f" ] || continue
      printf '\n## FILE: %s\n```\n' "$f"
      cat -n "$f"
      printf '\n```\n'
    done
    printf '\n---\n# 参考: 変更内容（unified diff）\n'
    printf 'NOTE: 以下はあくまで「どこが変わったか」の参考。メタ行はコードではない。\n```diff\n'
    git diff "$BASE...HEAD"
    printf '\n```\n'
  } > "$INPUT"

  # 変更後ファイル側（RIGHT）でインラインコメント可能な行を path<TAB>line で抽出
  # （diff の hunk 内の追加行＋文脈行が対象。これ以外の行に付けると GitHub に 422 で弾かれる）
  git diff "$BASE...HEAD" | awk '
    /^\+\+\+ b\// { f=substr($0,7); next }
    /^@@ /        { match($0, /\+[0-9]+/); ln=substr($0,RSTART+1,RLENGTH-1)+0; next }
    /^\+\+\+/     { next }
    /^---/        { next }
    /^\\/         { next }
    /^\+/         { print f"\t"ln; ln++; next }
    /^-/          { next }
    /^ /          { ln++; next }
  ' > "$DIFF_LINES"

  wc -l "$INPUT" "$DIFF_LINES"
fi
```

`EMPTY:` が出力された場合は，レビュー対象がない旨を報告して停止してください．

## 3. diff を Gemini CLI にレビューさせる

`/tmp/gemini_input.md` を素材に，幻覚と深刻度の誤較正を抑える指示つきでレビューさせ，**インライン投稿のため結果を JSON で** `/tmp/gemini_review.json` に保存してください：

```sh
gemini -y --model gemini-3.1-pro-preview -p "$(cat <<'PROMPT'
あなたはシニアソフトウェアエンジニアです。後続の素材をコードレビューしてください。

【素材の読み方】
- 各 "## FILE: <path>" 配下のコードブロックが「変更後のファイル全文」です。指摘の根拠は必ずこの全文を正とすること。
- 各行の先頭には「行番号＋タブ」が付いています。これはエディタが付けた行番号でありコード本体ではありません。指摘の line にはこの行番号を使うこと。
- 末尾の unified diff は「どこが変わったか」を示す参考です。diff のメタ行（+++ / --- / @@ / index / ファイルパス見出し）はコードではありません。コード本体と混同しないこと。

【レビュー範囲 — これだけを見る】
- バグ・ロジック誤り・正当性
- セキュリティ
- 確実に言えるパフォーマンス劣化・リソースリーク
- 設計提案・命名・スタイル・好みの改善案は出さない。これはコードレビューであって設計レビューではない。

【観点チェックリスト（該当が無ければスキップ。埋めるために捏造しない）】
境界条件 / off-by-one、null・未初期化、エラーハンドリングと例外パス、並行性・ブロッキング I/O、リソース解放、認証認可、入力検証・injection、リトライ安全性・idempotency、外部 API のドメイン制約（数量・状態遷移など）。

【判定規律 — 厳守】
- 各指摘に深刻度 Critical/High/Medium/Low と確信度（高/中/低）を付ける。
- Critical・High を付けてよいのは「確信度=高」かつ「根拠の行引用がある」指摘だけ。確信度が中以下の指摘は Medium 以下に置く。確証の無い指摘を上位に置かない。
- すべての指摘に rationale として該当ファイル全文の実際の行を引用する。引用できない指摘は出さない。
- 「コンパイル/構文エラー」「テストが落ちる」「実行時に失敗する」等の動作上の断定は、コードから論理的に確実に言える場合のみ。確実でなければ explanation の先頭に「推測:」を付け、深刻度は Medium 以下にする。
- 観点を埋めるために指摘をでっち上げない。該当が無ければ findings を空配列にする。
- 出力前に各指摘を自己検証する：引用した行が全文に実在するか、それが diff のメタ行でないか、深刻度と確信度の対応が上のルールに反していないか。反するものは削除するか格下げする。

【出力形式 — JSON のみ】
前置き・後置き・コードフェンス（```）を一切付けず、次の構造の JSON だけを出力すること：
{
  "summary": "全体所感（日本語・簡潔に。指摘が無ければ LGTM とだけ書く）",
  "findings": [
    {
      "path": "対象ファイルパス（## FILE: の値をそのまま）",
      "line": 42,
      "severity": "Critical|High|Medium|Low",
      "confidence": "高|中|低",
      "summary": "一行要約",
      "rationale": "該当行の実際の引用（行番号プレフィックスは除く）",
      "explanation": "説明"
    }
  ]
}
- line は指摘箇所の行番号（各行頭の数字）。ファイル全体に関わる等で特定の行に紐づかない指摘は line を null にする。
- 指摘が無くても {"summary": "...", "findings": []} を返す。
PROMPT
)

$(cat /tmp/gemini_input.md)" > /tmp/gemini_review.json

wc -l /tmp/gemini_review.json
```

## 3.5. 指摘を 1 件ずつファイルに分割する

Gemini の出力は幻覚を含み得るため，投稿前に**各指摘を独立した Subagent で検証**します．その下準備として，`/tmp/gemini_review.json` の各 finding を 1 件 1 ファイルに切り出します．

1. `Read` で `/tmp/gemini_review.json` を読む．コードフェンスや余分な文章が混じっていれば，純粋な JSON 部分（最初の `{` から対応する最後の `}` まで）だけを採用する．JSON として解釈できない場合は，その旨を報告して停止する．
2. `findings` が空配列なら，検証は不要．手順 4 に進み，LGTM として投稿する．
3. `findings` が空でなければ，出力先ディレクトリを作る：

```sh
rm -rf /tmp/gemini_findings && mkdir -p /tmp/gemini_findings
```

4. 各 finding を `Write` で `/tmp/gemini_findings/finding_NN.json`（`NN` は `01` から始まる連番）に書き出す．各ファイルには元の finding オブジェクトをそのまま入れ，追跡用に `index`（連番）を付与する：

```json
{
  "index": 1,
  "path": "...",
  "line": 42,
  "severity": "...",
  "confidence": "...",
  "summary": "...",
  "rationale": "...",
  "explanation": "..."
}
```

## 3.6. 各指摘を Subagent で検証する（並列・自動 drop/downgrade）

手順 3.5 で書き出した finding ファイルそれぞれに対し，**`Task` ツールで `Explore` 型（read-only）の Subagent を 1 件 1 つ起動**します．**全 Subagent を 1 メッセージ内でまとめて起動して並列実行**してください（finding が多い場合も同時起動でよい）．

各 Subagent への指示（プロンプト）には次を含めること：

- 検証対象の finding ファイルパス（例: `/tmp/gemini_findings/finding_03.json`）を渡し，まず `Read` で読ませる．
- finding の `path` が指す**実ファイルを現物として `Read`** し，以下を検証させる：
  1. `rationale` の引用が，対象ファイルの該当行付近に**実在**するか（一字一句一致でなくとも，引用が実コードに対応するか）．
  2. その指摘が **diff のメタ行（`+++` / `---` / `@@` / `index` / パス見出し）の誤読**に由来する幻覚でないか．
  3. 指摘内容がコード上**論理的に正しい**か（バグ・セキュリティ・性能劣化の主張として成立するか）．
  4. `severity` と `confidence` の較正が妥当か（Critical/High は「確信度=高」かつ「実在する行引用あり」が条件．満たさなければ過大評価）．
- Subagent は**コードフェンスや前置きを一切付けず**，次の構造の JSON **のみ**を最終出力として返すこと：

```json
{
  "index": 3,
  "verdict": "keep | drop | downgrade",
  "corrected_severity": "Critical|High|Medium|Low",
  "reason": "判定理由（日本語・簡潔に）"
}
```

- `verdict` の基準：
  - `drop`: 引用が実在しない／diff メタ行の誤読／主張が明らかに誤り（＝幻覚または無効）．
  - `downgrade`: 指摘自体は成立するが severity が過大．`corrected_severity` に適正値を入れる．
  - `keep`: そのまま有効．`corrected_severity` は元の severity と同じ値を入れる．

全 Subagent の結果が出揃ったら，Claude（orchestrator）が集約する：

- `verdict == "drop"` の finding は**投稿対象から除外**する．
- `verdict == "downgrade"` の finding は `severity` を `corrected_severity` で**上書き**する．
- `verdict == "keep"` はそのまま残す．
- 除外・降格した件数とその理由は，手順 4 の全体コメント本文フッタ直前に「自動検証で除外/降格した指摘」節として簡潔に記録する（透明性のため）．

このように検証を通過・補正した finding 集合を，以降の手順 4 の入力とする．

## 4. レビュー結果を PR に投稿する（インライン + 全体コメントのハイブリッド）

ここからは Claude（orchestrator）が振り分けを行います．`gh pr review` ではなく **GitHub Reviews API** を 1 リクエストで叩き，diff 内の行はインラインコメント，それ以外は全体コメント本文にまとめて投稿します．

### 4-1. 素材の読み込み

1. 投稿対象の finding 集合は，手順 3.6 で**Subagent 検証を通過・補正したもの**を用いる（`summary` は `/tmp/gemini_review.json` のものをそのまま使う）．finding が空（手順 3.5 の段階で空，または全件 drop）なら LGTM として投稿する．
2. `Read` で `/tmp/gemini_diff_lines.txt` を読み，`path<TAB>line` の集合（インライン可能行）を把握する．
3. 幻覚の除去は手順 3.6 で済んでいるため，ここでの再検証は不要．3.6 で除外・降格した件数は手順 4-3 のフッタ直前の節に記録する．

### 4-2. インラインと全体への振り分け

各 finding を次の規則で振り分ける：

- `line` が `null` でなく，かつ `path<TAB>line` が手順 4-1 の集合に**存在する** → **インラインコメント**にする．
- それ以外（`line` が `null`，または diff 外の行＝集合に無い） → **全体コメント本文**の「diff 外の指摘」節に Markdown でまとめる．

インラインコメントの `body` は次の形式：

```
**[<severity>]** 確信度:<confidence>｜<summary>

根拠: `<rationale>`

<explanation>
```

### 4-3. ペイロードを組み立てて投稿

`Write` で `/tmp/gemini_payload.json` に次の構造を書き出す（`<...>` は実値に置換）：

```json
{
  "event": "COMMENT",
  "body": "<全体コメント本文>",
  "comments": [
    { "path": "<path>", "line": <line>, "side": "RIGHT", "body": "<インライン本文>" }
  ]
}
```

- `body`（全体コメント本文）には次を含める：ヘッダ（下記）＋ Gemini の `summary` ＋「diff 外の指摘」節（4-2 で振り分けた分．無ければ「diff 外の指摘なし」）＋ フッタ（自動生成の注意書き）．
- インライン対象が 1 件も無ければ `comments` は `[]` にする（`body` だけのレビューが投稿される）．

ヘッダ／フッタの文面：

```
🤖 AI Code Review

> Generated by: Gemini CLI (reviewer) + Claude Code (orchestrator)
> Model: gemini-3.1-pro-preview
> Scope: main...HEAD（変更ファイル全文 + 参考 diff／インライン投稿対応）
```

```
---
このレビューは自動生成されたものです．AI の指摘には誤検知が混じり得ます．最終判断は人間のレビュアーが行ってください．
```

投稿（`<PR番号>` は手順 1 の番号に置換．`{owner}/{repo}` は `gh` がカレントリポジトリから自動補完する）：

```sh
gh api repos/{owner}/{repo}/pulls/<PR番号>/reviews --method POST --input /tmp/gemini_payload.json
```

> [!NOTE]
> Reviews API は，**diff の hunk に含まれない行**を `comments[].line` に指定すると `422 Unprocessable Entity` を返す．抽出漏れ等で 422 が出た場合は，該当コメントを `comments` から外して全体コメント本文（「diff 外の指摘」節）へ移し，再投稿すること．エラー内容に出てくる `path`/`line` を手掛かりにする．

## 5. 完了報告

投稿が完了したら，以下のコマンドで PR の URL を取得して表示してください：

```sh
gh pr view <PR番号> --json url --jq '.url'
```

---

引数: $ARGUMENTS
