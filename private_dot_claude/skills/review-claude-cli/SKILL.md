---
description: 現在のブランチの変更を別セッションの Claude CLI（claude -p / headless）にレビューさせ，結果を PR レビューコメントとして投稿する
disable-model-invocation: true
argument-hint: [PR番号] [--scope merge-base|staged|working] [--base <branch>]
allowed-tools: Bash(git *), Bash(gh *), Bash(claude *), Bash(~/.claude/skills/review-claude-cli/review-prep.sh *), Read, Write, Task
---

# タスク: 別セッション Claude CLI による PR コードレビュー

以下の手順で変更をレビューし，結果を投稿してください．

> [!IMPORTANT]
> **このスキルの本体は「別プロセスの `claude -p`（headless）を finder として起動する orchestration」である．**
> あなた（今このスキルを読んでいる session）が，自分の文脈の中でレビューを書いてはいけない．それは文脈共有＝独立性ゼロのレビューであり，このスキルの前提が丸ごと崩れる．レビューの実体（findings）は，必ず手順 3 で起動する **別セッションの `claude -p`** が生成する．あなたの役割は orchestrator（素材生成・検証・較正・投稿）に限る．
>
> **`claude -p` の呼び出しが失敗（exit code ≠ 0）した場合，黙って自分の文脈内レビューへ fallback してはいけない．** 失敗は fail loud（その旨を報告して停止）すること．「独立性があるつもりで実は無い」状態が最悪である．

> [!NOTE]
> **設計思想（なぜこの構成か）**
> 旧構成（Gemini を finder にする版）は「別モデルが finder，Claude が検証者」で独立シグナルを得ていた．本構成では finder も検証者も Claude だが，finder は **このsessionと文脈を一切共有しない別プロセス（`claude -p`）** である点が独立性の源泉になる．「自分が書いたコードだから正しいはず」という相関した盲点を，文脈ゼロの finder が持たないことに価値がある．
> 同一モデル系列のため recall の独立性は別モデル版より弱い．これは手順 3 の **multi-lens（correctness / security / spec）** で補い，誤検知対策（precision）は手順 4 の **Subagent 検証**で稼ぎ，severity は手順 5 で orchestrator がルーブリックで較正する．

> [!IMPORTANT]
> **コマンドは小さく分割してある（重要）．** 素材生成（git/gh の組み立て）は `~/.claude/skills/review-claude-cli/review-prep.sh` に，finder のプロンプトは `~/.claude/skills/review-claude-cli/prompts/*.md` に外出ししてある．これにより各 Bash コマンドが短く・承認可能になる．**巨大な単一ブロックを自分で組み立て直さないこと**（承認レイヤに弾かれて動かなくなる）．コマンドは Bash ツール（zsh）で実行する前提．パス・引数は下記のリテラルをそのまま使い，`<...>` だけ実値に置換する．
>
> このスキルは `~/.claude/skills/review-claude-cli/` 配下に `chezmoi apply` 済みであることを前提とする（`review-prep.sh` と `prompts/` が無ければ apply を促す）．

> [!NOTE]
> **secret 保護**: レビュー対象には Stripe key 等が混入し得る．`review-prep.sh material` の出力（全文＋diff）は **stdout から直接 `claude -p` にパイプ**し，plaintext の temp ファイルにも orchestrator の文脈にも残さない．`claude -p` には `--no-session-persistence` を付け，diff を含む session をディスクに残さない．データ経路は `claude -p`（＝既存の Claude Code 利用と同じ範囲）に限定し，web 等へ出さない．
>
> **read-only の強制**: これは review skill であって fix skill ではない．finder には `--disallowedTools` で編集系・コマンド実行・web 系を禁止する．あなた（orchestrator）もレビュー過程でコードを一切編集しない．

## 1. 引数の解釈と PR 番号の取得

`$ARGUMENTS` を次のように解釈する（順不同・すべて任意）：

- 数字トークン → **PR 番号**．
- `--scope merge-base|staged|working` → 差分の取り方（default `merge-base`）．`merge-base`=`<base>...HEAD`（通常はこれ）／`staged`=`git diff --staged`／`working`=`git diff`．
- `--base <branch>` → merge-base の基準ブランチ（default `main`）．

以降，決定した値を `<scope>` / `<base>` / `<PR>` と表記する．PR 番号の決定：

- 引数指定があればそれを使う．
- 指定がなく `scope=merge-base` の場合：

  ```sh
  gh pr list --head "$(git branch --show-current)" --json number --jq '.[0].number'
  ```

- PR 番号が得られなければ（未 push・PR 未作成，または `staged`/`working` のローカルレビュー） → **投稿はスキップしコンソール出力**モードで続行（手順 6）．

## 2. レビュー対象の有無を確認する

```sh
~/.claude/skills/review-claude-cli/review-prep.sh files <scope> <base>
```

- 出力が空ならレビュー対象なし．その旨を報告して停止する．
- 1 行以上あれば手順 3 へ．

## 3. 別セッションの `claude -p` に複数観点（lens）でレビューさせる

> [!WARNING]
> 生 diff を丸ごと finder に渡すと，diff のメタ行（`+++`/`---`/`@@`/`index`/見出し）をコードと誤読して幻覚を生む．`review-prep.sh material` は **変更後ファイルの全文を主素材**にし diff を参考として末尾に添える形で組み立て済みなので，これをそのまま使う．

lens は `correctness` / `security` / `spec` の 3 つ．**それぞれ独立した Bash コマンドとして実行**する（各コマンドは短く承認可能）．`<model>` は再現性のためピン留めする（既定 `claude-opus-4-8`．`opus` 等のエイリアスでも可）．`set -o pipefail` により prep か `claude -p` のどちらが失敗しても pipeline が非ゼロで終わる＝fail loud になる．

**correctness lens:**

```sh
set -o pipefail
~/.claude/skills/review-claude-cli/review-prep.sh material <scope> <base> \
| claude -p "$(cat ~/.claude/skills/review-claude-cli/prompts/common.md)

$(cat ~/.claude/skills/review-claude-cli/prompts/correctness.md)" \
  --model <model> --output-format text --no-session-persistence \
  --disallowedTools "Edit Write NotebookEdit Bash WebFetch WebSearch"
```

**security lens:**（上の `correctness.md` を `security.md` に変えるだけ）

```sh
set -o pipefail
~/.claude/skills/review-claude-cli/review-prep.sh material <scope> <base> \
| claude -p "$(cat ~/.claude/skills/review-claude-cli/prompts/common.md)

$(cat ~/.claude/skills/review-claude-cli/prompts/security.md)" \
  --model <model> --output-format text --no-session-persistence \
  --disallowedTools "Edit Write NotebookEdit Bash WebFetch WebSearch"
```

**spec lens:**（PR/仕様文脈と実装の両方を素材にする．`<PR>` は手順 1 の番号，無ければ空文字）

```sh
set -o pipefail
{ ~/.claude/skills/review-claude-cli/review-prep.sh context "<PR>"; \
  printf '\n===== 実装（変更後コード）=====\n'; \
  ~/.claude/skills/review-claude-cli/review-prep.sh material <scope> <base>; } \
| claude -p "$(cat ~/.claude/skills/review-claude-cli/prompts/common.md)

$(cat ~/.claude/skills/review-claude-cli/prompts/spec.md)" \
  --model <model> --output-format text --no-session-persistence \
  --disallowedTools "Edit Write NotebookEdit Bash WebFetch WebSearch"
```

各コマンドの **exit code を必ず確認する**．非ゼロなら finder の失敗として **fail loud（報告して停止）**．文脈内レビューへ fallback してはいけない．成功時の stdout が各 lens の finder JSON（コードフェンスや余分な文章が混じることがある）．

インラインコメント可能な行（変更後ファイル側 RIGHT）も取得しておく：

```sh
~/.claude/skills/review-claude-cli/review-prep.sh difflines <scope> <base>
```

出力は `path<TAB>line` の集合．

## 4. lens 横断で統合・重複排除し，各指摘を Subagent で「妥当性」だけ検証する

1. 3 lens の出力 JSON を解釈する（コードフェンスや余分な文章が混じっていれば最初の `{` から対応する最後の `}` までを採用）．JSON として解釈できない lens は欠落として扱い（最終報告に残す），残りで続行．
2. 全 findings を連結し **重複排除**：`path` が同じで `line` が同じ（または `rationale` が実質同一）の指摘は 1 件に統合し，最も具体的な `rationale`/`explanation` を残す．各 finding に由来 lens を `category` として付与し連番 `index` を振る．3 lens 分の `summary` は結合して保持（手順 6 で使う）．
3. 統合後が空なら検証不要．手順 6 で LGTM 投稿．

空でなければ各 finding を検証する：

> [!IMPORTANT]
> 検証層は precision（幻覚除去）のためにある．ここでは **severity を動かさず**，妥当性判定と較正材料の収集に徹する（severity は手順 5 で較正）．

各 finding に対し **`Task` ツールで `Explore` 型（read-only）の Subagent を 1 件 1 つ起動**する．**全 Subagent を 1 メッセージ内でまとめて起動して並列実行**すること．secret 保護のため finding を temp ファイルに書かず，finding の内容（`index`/`category`/`path`/`line`/`rationale`/`explanation`）を **Task のプロンプトに直接埋め込んで**渡す．各 Subagent への指示：

- finding の `path` が指す**実ファイルを現物として `Read`**（`spec` 由来で `line=null` の指摘は関連実装ファイルを探して読む），以下を判定：
  1. `rationale` の引用が実コードに対応するか（一字一句一致でなくとも可．**diff のメタ行の誤読**でないか）．
  2. 指摘がコード上**論理的に成立する**か．
- **severity は判定しない．** コードフェンス・前置きを付けず次の JSON のみを返す：

```json
{"index":3,"valid":true,"certainty":"高|中|低","exploitability":"yes|no|unknown","blast_radius":"broad|local|minimal","reason":"判定理由（日本語・簡潔。severity に言及しない）"}
```

- `valid`: 引用が実在し論理的に成立するなら `true`．幻覚・diff 誤読・誤りなら `false`．
- `certainty`: 現実に問題である確からしさ．`exploitability`: 悪用・誤動作が実際にトリガ可能か（該当外は `unknown`）．`blast_radius`: 影響範囲（`broad`=データ破壊/全体波及/外部公開，`local`=一機能内，`minimal`=軽微）．

## 5. 妥当性結果を集約し，severity をルーブリックで較正する

1. `valid == false` の finding は**投稿対象から除外**する．
2. 残った finding の severity を次のルーブリックで決定する．**finder の `severity_hint` は無視し，このルーブリックを正とする**（検証者の hedging が severity を歪めるのを防ぐ）：

| 条件 | severity |
|---|---|
| `certainty=低` | Low（`blast_radius=minimal` なら除外も検討） |
| `certainty=中` | Medium |
| `certainty=高` かつ `blast_radius` が `local`/`minimal` かつ `exploitability≠yes` | Medium |
| `certainty=高` かつ `exploitability=yes` かつ `blast_radius=local` | High |
| `certainty=高` かつ `blast_radius=broad` かつ `exploitability≠yes` | High |
| `certainty=高` かつ `exploitability=yes` かつ `blast_radius=broad` | Critical |

3. 較正後の severity を確定値として持たせる．**除外件数・各 finding の最終 severity と certainty** は手順 6 の全体コメント本文に「自動検証サマリ（除外 / 較正）」節として簡潔に記録する．

## 6. レビュー結果を投稿（PR あり）またはコンソール出力（PR なし）する

### PR がある場合: インライン + 全体コメントのハイブリッド投稿

`gh pr review` ではなく **GitHub Reviews API** を 1 リクエストで叩く．

1. 手順 3 の `difflines` 出力（`path<TAB>line` 集合）を把握する．
2. 各 finding を振り分ける：
   - `line` が `null` でなく `path<TAB>line` が集合に**存在する** → **インラインコメント**．
   - それ以外（`line=null`，または diff 外） → **全体コメント本文**の「diff 外の指摘」節に Markdown でまとめる．
3. インラインコメントの `body`（`<severity>` は手順 5 で較正した確定値）：

   ```
   **[<severity>]** <category>｜確信度:<certainty>｜<summary>

   根拠: `<rationale>`

   <explanation>
   ```

4. ペイロードを組み立てて投稿する．secret 保護のため payload は temp ファイルに書いたら投稿後ただちに `rm` する（rationale に機密行が引用され得る）．構造：

   ```json
   {
     "event": "COMMENT",
     "body": "<全体コメント本文>",
     "comments": [
       { "path": "<path>", "line": <line>, "side": "RIGHT", "body": "<インライン本文>" }
     ]
   }
   ```

   - `body` には：ヘッダ（下記）＋ 3 lens を結合した `summary` ＋「diff 外の指摘」節（無ければ「diff 外の指摘なし」）＋「自動検証サマリ（除外 / 較正）」節（手順 5）＋ フッタ（下記）．
   - インライン対象が 0 件なら `comments` は `[]`．

   ヘッダ／フッタ：

   ```
   🤖 AI Code Review

   > Generated by Claude Code: claude -p (independent reviewer / finder) + this session (orchestrator / verifier)
   > Model: <model>
   > Scope: <scope>（変更ファイル全文 + 参考 diff + PR/仕様文脈／correctness・security・spec の3観点）
   ```

   ```
   ---
   このレビューは自動生成されたものです．AI の指摘には誤検知が混じり得ます．逆に取りこぼし（recall）も残り得るため，最終判断は人間のレビュアーが行ってください．
   ```

   投稿（`<PR>` は手順 1 の番号．`{owner}/{repo}` は `gh` がカレントリポジトリから自動補完）：

   ```sh
   gh api repos/{owner}/{repo}/pulls/<PR>/reviews --method POST --input <payload.json>
   ```

   投稿後に `rm -f <payload.json>` する．

   > [!NOTE]
   > Reviews API は diff の hunk に含まれない行を `comments[].line` に指定すると `422 Unprocessable Entity` を返す．422 が出たら該当コメントを `comments` から外して全体コメント本文（「diff 外の指摘」節）へ移し，再投稿する．

### PR が無い場合（ローカルレビュー）

投稿せず，較正済み findings を上記と同じ書式（severity / category / 確信度 / 根拠 / 説明，および除外・較正サマリ）で **コンソールに Markdown で出力**する．

## 7. 完了報告

- PR に投稿した場合：

  ```sh
  gh pr view <PR> --json url --jq '.url'
  ```

  で URL を取得して表示する．
- ローカルレビューの場合はその旨と検出件数・除外件数を報告する．

---

## 付録: 承認プロンプトを減らす（任意）

分割後も `claude -p` と `review-prep.sh` は allowlist 外なので毎回承認を求められる．`~/.claude/settings.json` の `permissions.allow` に以下を加えると無確認で通る（`git`/`gh` は既に許可済み）：

```
"Bash(claude:*)",
"Bash(~/.claude/skills/review-claude-cli/review-prep.sh:*)"
```

---

引数: $ARGUMENTS
