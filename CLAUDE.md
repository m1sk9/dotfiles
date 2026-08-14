# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

このリポジトリは [chezmoi](https://github.com/twpayne/chezmoi) で管理する macOS 向け dotfiles の**ソースディレクトリ**である．`~/.local/share/chezmoi` に置かれ，`chezmoi apply` で実ファイル（`$HOME` 配下）に展開される．つまりここで編集するのはソースであって，反映先のファイルではない点に常に注意すること．

## よく使うコマンド

- `chezmoi diff` : ソースを変更した後，実際の展開結果との差分を確認する（apply 前に必ず確認）．
- `chezmoi apply` : ソースを `$HOME` に反映する．`git.autoCommit`/`autoPush` が有効なため，自動コミット・プッシュが走りうる点に注意（下記「自動コミットに関する注意」参照）．
- `chezmoi apply --dry-run --verbose` : 実ファイルを変更せずに適用結果だけを確認する．
- `chezmoi execute-template < file.tmpl` : `.tmpl` ファイルのテンプレート展開結果だけを確認する（`run_onchange_*.tmpl` などの動作検証に有用）．
- `chezmoi cd` : ソースディレクトリへ移動するサブシェルを開く．

## chezmoi のファイル命名規則（最重要）

ファイル名のプレフィックスがそのまま反映先のパス・属性を決める．ファイルを新規作成・リネームする際は規則に従うこと．

- `dot_foo` → `~/.foo`（`dot_config/` → `~/.config/`）
- `private_foo` → 権限 `0600` で展開（`private_dot_claude/` → `~/.claude/`）
- `executable_foo` → 実行ビットを付与して展開（`Scripts/executable_*.sh`）
- `encrypted_foo.age` → age で復号して展開（`dot_awseal/encrypted_config.json.age`）
- `*.tmpl` → Go テンプレートとして評価してから展開
- `run_once_*` → `chezmoi apply` 時に一度だけ実行されるスクリプト

管理対象外のファイルは `.chezmoiignore` に列挙されている．リポジトリにはあるが `$HOME` には展開されない．

## 自動コミットに関する注意

`.chezmoi.toml.tmpl` で `git.autoCommit` / `git.autoPush` が `true` のため，`chezmoi` 経由の変更は自動でコミット・プッシュされうる．手動で `git` 操作する場合は二重コミットに注意すること．

`chezmoi diff` で差分確認した後の `chezmoi apply` は，確認を取らずに実行してよい．ただしファイル削除を伴う変更・暗号化ファイルや秘密情報が絡む変更など，破壊的・不可逆な変更が伴う場合は事前に確認を取ること．

## 暗号化

- 暗号化方式は **age**．`encrypted_*.age` ファイルは復号鍵 `~/.config/chezmoi/key.txt` が無いと扱えない．
- `dot_awseal/encrypted_config.json.age` は [awseal](https://github.com/s6n-jp) の設定．**復号後の平文を誤って平文ファイルとしてコミットしないこと．**
- `$HOME` に平文を落としたくない秘密は `encrypted_*` ではなく，ドット始まりのソースファイル（例: `.obsidian-token.age`）に置き，テンプレート内で ``{{ joinPath .chezmoi.sourceDir `<file>` | include | decrypt }}`` として使う．ドット始まりは chezmoi が展開対象から外すため，復号値はレンダリング結果にしか現れない．

## Scripts/

`executable_*.sh` は **Raycast Script Commands**．先頭コメントの `@raycast.*` メタデータが Raycast から認識される．Raycast (bash) は fish の環境変数を継承しないため，`COLIMA_HOME` 等は各スクリプト内で明示的に `export` している点に注意．

## シェル環境

ログインシェルは **fish**（`dot_config/private_fish/config.fish`）．スクリプトを書く際の前提:
- エイリアスでコマンドが置き換わっている: `cat`→`bat`, `ls`→`eza`, `find`→`fd`, `grep`→`rg`, `cd`→`z`(zoxide)．スクリプト内でこれらの挙動に依存しないこと．
- `XDG_CONFIG_HOME=$HOME/.config` を前提に各ツールの設定パスが決まる．
- SSH 認証は GPG agent 経由（`SSH_AUTH_SOCK` を gpgconf で設定）．

## パッケージ管理

`dot_Brewfile`（→ `~/.Brewfile`）が唯一の Homebrew マニフェスト．パッケージの追加・削除はここを編集し，`brew bundle --file ~/.Brewfile` で反映する．`--zap` でマニフェスト外のものは削除されるため，手動 `brew install` したものは Brewfile に追記しないと消える．

## Claude Code 設定（private_dot_claude/）

`~/.claude` 配下の設定そのものをこのリポジトリで管理している．`private_dot_claude/CLAUDE.md` はユーザーのグローバル指示であって，このファイルとは別物である（プロジェクト固有の記述を書くと全プロジェクトに漏れる）．

agent と skill は対になっているものが多い（`fix-ci`, `fix-review`, `fix-dependabot` など）．片方を変更する際はもう片方との整合性を確認すること．

## MCP サーバー設定

user scope の MCP サーバー定義の source of truth は `.chezmoitemplates/mcp-servers.json` であり，`~/.claude.json` を直接編集・管理下には置いていない（`numStartups` や `projects` などの可変状態を含むため）．`run_onchange_configure-claude-mcp.fish.tmpl` がこの JSON を読み，`claude mcp remove` → `claude mcp add-json --scope user` で CLI 経由で注入する．MCP サーバーを追加・変更する際は `.chezmoitemplates/mcp-servers.json` を編集すること（詳細な理由は同スクリプト内の Why not コメントを参照）．

ただしここに置いたものは全プロジェクトに載る．用途が限られる MCP・plugin は `dot_config/private_fish/functions/claude.fish` の `optional_local` 表に `<flag>:<kind>:<name>:<payload>` を足し，`claude --chrome` のように起動時フラグで local scope に投入する．ブラウザ MCP は user scope の `browser` (Kitesurf) と同名を local scope に入れて隠す設計なので，ローカル Chrome を使う側も名前は `browser` にすること（別名にすると同じ chrome-devtools-mcp が 2 つ起動する）．

## 依存バージョンの自動更新（Renovate）

`.github/renovate.json` は `.chezmoiexternal.toml.tmpl` 内の `# renovate: datasource=... depName=...` コメントを正規表現で検出するカスタムマネージャーを持つ．外部ファイル（例: `statusbar` のダウンロード元バージョン）を追加・更新する際は，このコメント規約に従うことで Renovate の自動 PR 対象にできる．
