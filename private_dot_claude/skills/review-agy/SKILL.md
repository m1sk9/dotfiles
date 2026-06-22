---
description: 現在のブランチの PR の変更を Antigravity CLI（agy）にレビューさせ，結果を PR レビューコメントとして投稿する
disable-model-invocation: true
argument-hint: [PR番号]
allowed-tools: Bash(git *), Bash(agy *), Bash(script *), Bash(gh *), Read, Write, Task
---

# タスク: Antigravity CLI（agy）による PR コードレビュー

以下の手順で現在のブランチの PR をレビューし，結果を投稿してください．

> [!IMPORTANT]
> このスキルのコマンドは Claude が Bash ツールで実行する前提で書いてある．コマンド置換は fish 専用の `(cmd)` ではなく `$(cmd)` を使うこと．実行環境は **macOS（BSD 系コマンド）** を前提とする（`script` の引数順が GNU 版と異なる点に注意）．

> [!WARNING]
> **`agy -p` は非 TTY（パイプ・リダイレクト・サブプロセス）下で最終応答を stdout に出さず黙って捨てる既知の不具合がある（exit code は 0 のまま）．** したがって `agy -p "..." > file.json` のような素のリダイレクトは**空ファイルを生む**．本スキルでは擬似 TTY（macOS の BSD `script -q /dev/null <command>`）でラップして出力を確保し，ANSI エスケープと `\r` を除去してからファイルに保存する（後述の手順 3 で具体化）．`--output-format json` 等のフラグは未安定なので頼らない．

> [!NOTE]
> **設計思想（なぜこの構成か）**
> このパイプラインは「別モデル（Antigravity CLI 上の Gemini）が finder，Claude が検証者」という役割分担で独立シグナルを確保している．Claude が書いたコードを Claude が検証すると盲点が相関して取りこぼし（recall）が増えるため，finder は必ず非 Claude モデルに担わせる（agy は `claude-opus` / `claude-sonnet` も選べるが，finder にこれらを選ぶと独立性が崩れるので使わない．本スキルでは `gemini-3.1-pro` を用いる）．
> 取りこぼし対策は手順 3 の **multi-lens（correctness / security / spec）** で稼ぎ，誤検知対策（precision）は手順 3.6 の **Subagent 検証**で稼ぐ．検証層は severity を動かさず妥当性判定に徹し，severity は手順 3.7 で orchestrator がルーブリックで較正する（検証者の hedging が深刻度を歪めるのを防ぐ）．

## 1. PR 番号の取得

引数 `$ARGUMENTS` で PR 番号が指定されている場合はそれを使用してください．

指定がない場合は，以下のコマンドで現在のブランチに紐づく PR 番号を取得してください：

```sh
gh pr list --head "$(git branch --show-current)" --json number --jq '.[0].number'
```

PR が見つからない場合は，その旨を報告して停止してください．

## 2. レビュー素材を生成する

> [!WARNING]
> **生 diff を丸ごと agy に渡してはいけない．** diff のメタ行（`+++ b/...` / `--- a/...` / `@@ ... @@` / `index ...` / ファイルパス見出し）をモデルが「コード本体に混入したゴミ」と誤読し，「`@Test` がパスに置換されコンパイル不能」といった**自信満々の幻覚**を生む原因になる（実例あり）．
>
> 対策として，**変更後ファイルの全文を主素材**にし，diff は「何が変わったか」の参考として末尾に添える．これによりモデルが実コードを根拠に判断できる．

`main...HEAD` で変更されたファイルの全文（削除ファイルは除く）と，参考用の unified diff を `/tmp/agy_input.md` にまとめてください．インライン投稿のため，全文には**行番号を付与**（`cat -n`）し，さらに「変更後ファイル側でインラインコメント可能な行番号」を `/tmp/agy_diff_lines.txt` に `path<TAB>line` 形式で抽出します：

```sh
BASE=main
INPUT=/tmp/agy_input.md
DIFF_LINES=/tmp/agy_diff_lines.txt
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

## 2.5. 仕様・PR 文脈を収集する（recall 強化）

コードと diff だけでは「要件を満たしているか」が判断できず，仕様適合性の指摘（例: サイズ上限の未実装による課金リスク）が構造的に出ません．PR 本文とリンク Issue を素材として収集し，後段の `spec` lens に渡します（`<PR番号>` は手順 1 の番号に置換）：

```sh
PR=<PR番号>
CONTEXT=/tmp/agy_context.md
{
  echo "# PR コンテキスト（満たすべき要件・仕様の参考。コードではなく『何を満たすべきか』の根拠）"
  echo
  gh pr view "$PR" --json title,body --jq '"## PR: " + .title + "\n\n" + (.body // "(本文なし)")'
  # クローズ対象としてリンクされた Issue ＋ 本文で参照された #番号 を収集して取得
  REFS=$( { gh pr view "$PR" --json closingIssuesReferences --jq '.closingIssuesReferences[].number'; gh pr view "$PR" --json body --jq '.body // ""' | grep -oE '#[0-9]+' | tr -d '#'; } | sort -un )
  for n in $REFS; do
    echo
    gh issue view "$n" --json number,title,body --jq '"## Linked Issue #" + (.number|tostring) + ": " + .title + "\n\n" + (.body // "(本文なし)")' 2>/dev/null || true
  done
} > "$CONTEXT"
wc -l "$CONTEXT"
```

> [!NOTE]
> PR 本文も Issue も無い場合は `$CONTEXT` がほぼ空になる．その場合 `spec` lens は「明示された要件が無い」前提で動き，推測で要件をでっち上げず findings を空にしてよい．

## 3. diff を Antigravity CLI（agy）に複数の観点（lens）でレビューさせる

単一の汎用プロンプトでは attack-surface や仕様適合の指摘が出にくく，取りこぼし（recall）が生じます．そこで**観点（lens）ごとに独立した agy 実行**を行い，後で統合します．lens は次の 3 つ：

- `correctness`: バグ・ロジック誤り・正当性・性能劣化・リソースリーク
- `security`: 攻撃面（injection・認証認可・データ露出・DoS / 課金濫用・path traversal・secret 露出 等）を敵対的に探す
- `spec`: 手順 2.5 の要件に対し，diff が各要件を満たすか／未実装・仕様違反が無いかを問う

> [!IMPORTANT]
> 各 lens の実行は `agy --dangerously-skip-permissions -m gemini-3.1-pro -p "..."` を **擬似 TTY でラップ**し，出力を ANSI 除去してからファイルに保存する（前述の非 TTY stdout 不具合の回避）．macOS（BSD `script`）の形は次のとおり：
>
> ```sh
> script -q /dev/null agy --dangerously-skip-permissions -m gemini-3.1-pro -p "<プロンプト>" \
>   | perl -pe 's/\x1b\[[0-9;]*[A-Za-z]//g' | tr -d '\r' > <出力先>.json
> ```
>
> - `--dangerously-skip-permissions`: ツール権限プロンプトを自動承認（旧 Gemini CLI の `-y` 相当）．レビューは読み取り主体なので付与する．
> - `-m gemini-3.1-pro`: finder のモデル．**`claude-*` は選ばない**（独立シグナルを保つため）．
> - 擬似 TTY 経由のため出力に進捗 UI / ANSI の残滓が混じり得るが，手順 3.5 の「最初の `{` から対応する最後の `}` まで」抽出が吸収する．

まず全 lens 共通の指示をシェル変数に入れます．**finder の severity_hint はあくまで暫定**で，最終 severity は後段（手順 3.7）で再較正される点に注意：

```sh
COMMON=$(cat <<'PROMPT'
あなたはシニアソフトウェアエンジニアです。後続の素材を、指定された観点に絞ってコードレビューしてください。

【素材の読み方】
- 各 "## FILE: <path>" 配下のコードブロックが「変更後のファイル全文」です。指摘の根拠は必ずこの全文を正とすること。
- 各行の先頭には「行番号＋タブ」が付いています。これはエディタが付けた行番号でありコード本体ではありません。指摘の line にはこの行番号を使うこと。
- 末尾の unified diff は「どこが変わったか」を示す参考です。diff のメタ行（+++ / --- / @@ / index / ファイルパス見出し）はコードではありません。コード本体と混同しないこと。
- 設計提案・命名・スタイル・好みの改善案は出さない。これはコードレビューであって設計レビューではない。

【判定規律 — 厳守】
- すべての指摘に rationale として該当ファイル全文の実際の行を引用する。引用できない指摘は出さない。
- severity_hint（Critical/High/Medium/Low）と confidence（高/中/低）はあくまで finder の暫定見積りである。最終的な深刻度は後段の検証で再較正されるので、確証が無いものを過大に見積もらない。
- 「コンパイル/構文エラー」「テストが落ちる」「実行時に失敗する」等の動作上の断定は、コードから論理的に確実に言える場合のみ。確実でなければ explanation の先頭に「推測:」を付ける。
- 観点を埋めるために指摘をでっち上げない。担当観点に該当が無ければ findings を空配列にする。
- 出力前に各指摘を自己検証する：引用した行が全文に実在するか、それが diff のメタ行でないか。反するものは削除する。

【出力形式 — JSON のみ】
前置き・後置き・コードフェンス（```）を一切付けず、次の構造の JSON だけを出力すること：
{
  "summary": "担当観点での全体所感（日本語・簡潔に。指摘が無ければ LGTM とだけ書く）",
  "findings": [
    {
      "path": "対象ファイルパス（## FILE: の値をそのまま）",
      "line": 42,
      "severity_hint": "Critical|High|Medium|Low",
      "confidence": "高|中|低",
      "summary": "一行要約",
      "rationale": "該当行の実際の引用（行番号プレフィックスは除く）",
      "explanation": "説明"
    }
  ]
}
- line は指摘箇所の行番号（各行頭の数字）。特定の行に紐づかない指摘（未実装・ファイル全体に関わる等）は line を null にする。
- 指摘が無くても {"summary": "...", "findings": []} を返す。
PROMPT
)
```

次に lens ごとに実行します．`correctness` と `security` は `/tmp/agy_input.md` を素材に：

```sh
script -q /dev/null agy --dangerously-skip-permissions -m gemini-3.1-pro -p "$COMMON

【このパスの担当観点 = correctness（これだけを見る）】
- バグ・ロジック誤り・正当性、確実に言えるパフォーマンス劣化・リソースリーク。
- チェックリスト（該当が無ければスキップ）: 境界条件 / off-by-one、null・未初期化、エラーハンドリングと例外パス、並行性・ブロッキング I/O、リソース解放、リトライ安全性・idempotency、トランザクション境界、外部 API のドメイン制約（数量・状態遷移など）。

$(cat /tmp/agy_input.md)" | perl -pe 's/\x1b\[[0-9;]*[A-Za-z]//g' | tr -d '\r' > /tmp/agy_review_correctness.json

script -q /dev/null agy --dangerously-skip-permissions -m gemini-3.1-pro -p "$COMMON

【このパスの担当観点 = security（これだけを見る・敵対的に考える）】
- 「この変更を攻撃者がどう悪用できるか」を能動的に探す。受け身で読まず、悪用シナリオを起点に考える。
- チェックリスト（該当が無ければスキップ）: 入力検証・injection（SQL / コマンド / Markdown / HTML 等）、認証認可の欠落・誤り、データ露出（内部 ID・storage key・secret）、SSRF・path traversal、リソース濫用・課金濫用（サイズ / 件数上限の欠如、presigned URL の悪用）、例外の握り潰しによる検証バイパス、idempotency の欠如による多重実行。

$(cat /tmp/agy_input.md)" | perl -pe 's/\x1b\[[0-9;]*[A-Za-z]//g' | tr -d '\r' > /tmp/agy_review_security.json
```

`spec` は要件（手順 2.5）と実装の両方を素材に：

```sh
script -q /dev/null agy --dangerously-skip-permissions -m gemini-3.1-pro -p "$COMMON

【このパスの担当観点 = spec（仕様適合性。これだけを見る）】
- 下の「PR コンテキスト」に書かれた要件・仕様を一つずつ取り出し、変更後コードがそれを満たしているかを照合する。
- 満たしていない／未実装／仕様と矛盾する点を findings にする。要件に紐づく実装箇所があれば line を付け、未実装で行が無い場合は line を null にする。
- コンテキストに明示された要件が無い場合は、推測で要件をでっち上げず findings を空にする。

===== PR コンテキスト（要件・仕様）=====
$(cat /tmp/agy_context.md)

===== 実装（変更後コード）=====
$(cat /tmp/agy_input.md)" | perl -pe 's/\x1b\[[0-9;]*[A-Za-z]//g' | tr -d '\r' > /tmp/agy_review_spec.json

wc -l /tmp/agy_review_correctness.json /tmp/agy_review_security.json /tmp/agy_review_spec.json
```

> [!NOTE]
> いずれかの出力が空（0 バイト / `findings` を含まない）の場合，非 TTY stdout の取りこぼしが疑われる．`script -q /dev/null` ラップが効いているか，`agy --version` で CLI が動くかを確認し，必要なら当該 lens を再実行する．それでも空なら手順 3.5 の規律に従いその lens を欠落として扱う．

## 3.5. lens 横断で統合・重複排除し，指摘を 1 件ずつファイルに分割する

3 つの lens の出力には重複が出るため，統合・重複排除してから検証します．

1. `Read` で `/tmp/agy_review_correctness.json`・`/tmp/agy_review_security.json`・`/tmp/agy_review_spec.json` を読む．各ファイルにコードフェンスや進捗 UI・余分な文章が混じっていれば，純粋な JSON 部分（最初の `{` から対応する最後の `}` まで）だけを採用する．いずれかが JSON として解釈できない場合は，その lens を欠落として扱い（その旨を最終報告に残す），残りの lens で続行する．
2. 全 findings を連結し，**重複排除**する：`path` が同じで，かつ `line` が同じ（または `rationale` が実質同一）の指摘は 1 件に統合する．統合時は最も具体的な `rationale` / `explanation` を残す．
3. 各 finding に由来 lens を `category`（`correctness` / `security` / `spec`）として付与する．3 lens 分の `summary`（全体所感）は結合して保持しておく（手順 4 の全体コメントで使う）．
4. 統合後の findings が空なら，検証は不要．手順 4 に進み LGTM として投稿する．
5. 空でなければ出力先ディレクトリを作る：

```sh
rm -rf /tmp/agy_findings && mkdir -p /tmp/agy_findings
```

6. 各 finding を `Write` で `/tmp/agy_findings/finding_NN.json`（`NN` は `01` から始まる連番）に書き出す．追跡用に `index`（連番）を付与する：

```json
{
  "index": 1,
  "category": "correctness|security|spec",
  "path": "...",
  "line": 42,
  "severity_hint": "...",
  "confidence": "...",
  "summary": "...",
  "rationale": "...",
  "explanation": "..."
}
```

## 3.6. 各指摘を Subagent で「妥当性」だけ検証する（並列）

> [!IMPORTANT]
> 検証層は precision（幻覚除去）のためにあり，recall は手順 3 の multi-lens で稼ぐ．ここでは **severity を動かさず**，妥当性の判定と severity 較正に使う材料の収集に徹する（severity は手順 3.7 で orchestrator がルーブリックで較正する）．

手順 3.5 で書き出した finding ファイルそれぞれに対し，**`Task` ツールで `Explore` 型（read-only）の Subagent を 1 件 1 つ起動**します．**全 Subagent を 1 メッセージ内でまとめて起動して並列実行**してください（finding が多い場合も同時起動でよい）．

各 Subagent への指示（プロンプト）には次を含めること：

- 検証対象の finding ファイルパス（例: `/tmp/agy_findings/finding_03.json`）を渡し，まず `Read` で読ませる．
- finding の `path` が指す**実ファイルを現物として `Read`** し（`spec` 由来で `line=null` の指摘は，関連する実装ファイルを探して読む），以下を判定させる：
  1. `rationale` の引用が実コードに対応するか（一字一句一致でなくとも可．**diff のメタ行の誤読**でないか）．
  2. 指摘がコード上**論理的に成立する**か（バグ／攻撃／仕様違反として現実に起こり得るか）．
- **severity は判定しない．** 代わりに severity 較正の材料となる信号を返す．
- Subagent は**コードフェンスや前置きを一切付けず**，次の構造の JSON **のみ**を最終出力として返すこと：

```json
{
  "index": 3,
  "valid": true,
  "certainty": "高|中|低",
  "exploitability": "yes|no|unknown",
  "blast_radius": "broad|local|minimal",
  "reason": "判定理由（日本語・簡潔に。妥当性の根拠。severity には言及しない）"
}
```

- `valid`: 引用が実在し，かつ指摘が論理的に成立するなら `true`．幻覚・diff 誤読・主張が明らかに誤りなら `false`．
- `certainty`: その指摘が現実に問題である確からしさ（実コードからの確証度）．
- `exploitability`: 悪用・誤動作が実際にトリガ可能か（`security` / `correctness` で意味を持つ．該当しなければ `unknown`）．
- `blast_radius`: 影響範囲（`broad`=データ破壊 / 全体波及 / 外部公開，`local`=一機能内，`minimal`=軽微）．

## 3.7. 妥当性結果を集約し，severity をルーブリックで較正する

全 Subagent の結果が出揃ったら，orchestrator（Claude）が集約する：

1. `valid == false` の finding は**投稿対象から除外**する（幻覚・誤読・誤り）．
2. 残った finding の severity を，検証で得た信号から次のルーブリックで決定する．**finder の `severity_hint` は無視し，このルーブリックを正とする**（検証者の hedging が severity を歪めるのを防ぐため）：

| 条件 | severity |
|---|---|
| `certainty=低` | Low（`blast_radius=minimal` なら除外も検討） |
| `certainty=中` | Medium |
| `certainty=高` かつ `blast_radius` が `local`/`minimal` かつ `exploitability≠yes` | Medium |
| `certainty=高` かつ `exploitability=yes` かつ `blast_radius=local` | High |
| `certainty=高` かつ `blast_radius=broad` かつ `exploitability≠yes` | High |
| `certainty=高` かつ `exploitability=yes` かつ `blast_radius=broad` | Critical |

3. 較正後の severity を各 finding に確定値として持たせる．**除外件数・各 finding の最終 severity と certainty** は，手順 4 の全体コメント本文フッタ直前に「自動検証サマリ（除外 / 較正）」節として簡潔に記録する（透明性のため）．

このように検証・較正した finding 集合を，以降の手順 4 の入力とする．

## 4. レビュー結果を PR に投稿する（インライン + 全体コメントのハイブリッド）

ここからは Claude（orchestrator）が振り分けを行います．`gh pr review` ではなく **GitHub Reviews API** を 1 リクエストで叩き，diff 内の行はインラインコメント，それ以外は全体コメント本文にまとめて投稿します．

### 4-1. 素材の読み込み

1. 投稿対象の finding 集合は，手順 3.7 で**妥当性検証を通過し severity を較正したもの**を用いる（全体所感の `summary` は手順 3.5 で結合した 3 lens 分を使う）．finding が空（手順 3.5 で空，または全件除外）なら LGTM として投稿する．
2. `Read` で `/tmp/agy_diff_lines.txt` を読み，`path<TAB>line` の集合（インライン可能行）を把握する．
3. 幻覚の除去と severity 較正は手順 3.6・3.7 で済んでいるため，ここでの再検証は不要．除外・較正の内訳は手順 4-3 のフッタ直前の節に記録する．

### 4-2. インラインと全体への振り分け

各 finding を次の規則で振り分ける：

- `line` が `null` でなく，かつ `path<TAB>line` が手順 4-1 の集合に**存在する** → **インラインコメント**にする．
- それ以外（`line` が `null`，または diff 外の行＝集合に無い） → **全体コメント本文**の「diff 外の指摘」節に Markdown でまとめる（`spec` 由来の未実装指摘は多くがここに入る）．

インラインコメントの `body` は次の形式（`<severity>` は手順 3.7 で較正した確定値）：

```
**[<severity>]** <category>｜確信度:<certainty>｜<summary>

根拠: `<rationale>`

<explanation>
```

### 4-3. ペイロードを組み立てて投稿

`Write` で `/tmp/agy_payload.json` に次の構造を書き出す（`<...>` は実値に置換）：

```json
{
  "event": "COMMENT",
  "body": "<全体コメント本文>",
  "comments": [
    { "path": "<path>", "line": <line>, "side": "RIGHT", "body": "<インライン本文>" }
  ]
}
```

- `body`（全体コメント本文）には次を含める：ヘッダ（下記）＋ 3 lens を結合した `summary` ＋「diff 外の指摘」節（4-2 で振り分けた分．無ければ「diff 外の指摘なし」）＋「自動検証サマリ（除外 / 較正）」節（手順 3.7 の内訳）＋ フッタ（自動生成の注意書き）．
- インライン対象が 1 件も無ければ `comments` は `[]` にする（`body` だけのレビューが投稿される）．

ヘッダ／フッタの文面：

```
🤖 AI Code Review

> Generated by: Antigravity CLI / agy (multi-lens reviewer) + Claude Code (orchestrator / verifier)
> Model: gemini-3.1-pro
> Scope: main...HEAD（変更ファイル全文 + 参考 diff + PR/仕様文脈／correctness・security・spec の3観点）
```

```
---
このレビューは自動生成されたものです．AI の指摘には誤検知が混じり得ます．逆に取りこぼし（recall）も残り得るため，最終判断は人間のレビュアーが行ってください．
```

投稿（`<PR番号>` は手順 1 の番号に置換．`{owner}/{repo}` は `gh` がカレントリポジトリから自動補完する）：

```sh
gh api repos/{owner}/{repo}/pulls/<PR番号>/reviews --method POST --input /tmp/agy_payload.json
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
