# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

このリポジトリは [chezmoi](https://github.com/twpayne/chezmoi) で管理する macOS 向け dotfiles の**ソースディレクトリ**である．`~/.local/share/chezmoi` に置かれ，`chezmoi apply` で実ファイル（`$HOME` 配下）に展開される．つまりここで編集するのはソースであって，反映先のファイルではない点に常に注意すること．

## chezmoi のファイル命名規則（最重要）

ファイル名のプレフィックスがそのまま反映先のパス・属性を決める．ファイルを新規作成・リネームする際は規則に従うこと．

- `dot_foo` → `~/.foo`（`dot_config/` → `~/.config/`）
- `private_foo` → 権限 `0600` で展開（`private_dot_claude/` → `~/.claude/`）
- `executable_foo` → 実行ビットを付与して展開（`Scripts/executable_*.sh`）
- `encrypted_foo.age` → age で復号して展開（`dot_awseal/encrypted_config.json.age`）
- `*.tmpl` → Go テンプレートとして評価してから展開
- `run_once_*` → `chezmoi apply` 時に一度だけ実行されるスクリプト

`.chezmoiignore` に列挙されたファイル（`README.md`, `LICENSE`, `.zed`, `key.txt` など）は管理対象外で，リポジトリにはあるが `$HOME` には展開されない．

## 編集後のワークフロー

1. このリポジトリ内のソースファイルを編集する．
2. `chezmoi diff` で反映先との差分を確認する．
3. `chezmoi apply` で実ファイルに反映する（`--force` で確認をスキップ）．

`.chezmoi.toml.tmpl` で `git.autoCommit` / `git.autoPush` が `true` のため，`chezmoi` 経由の変更は自動でコミット・プッシュされうる．手動で `git` 操作する場合は二重コミットに注意すること．

## 暗号化

- 暗号化方式は **age**．`encrypted_*.age` ファイルは復号鍵 `~/.config/chezmoi/key.txt` が無いと扱えない．
- `dot_awseal/encrypted_config.json.age` は [awseal](https://github.com/s6n-jp) の設定．**復号後の平文を誤って平文ファイルとしてコミットしないこと．**

## Scripts/

`executable_*.sh` は **Raycast Script Commands**．先頭コメントの `@raycast.*` メタデータが Raycast から認識される．Raycast (bash) は fish の環境変数を継承しないため，`COLIMA_HOME` 等は各スクリプト内で明示的に `export` している点に注意．

主要スクリプト:
- `executable_update-homebrew.sh` — `chezmoi apply` → `brew update`/`bundle`/`cleanup`/`upgrade` を一括実行．
- `executable_start--stop-colima-runtime.sh` — Colima ランタイムのトグル．
- `executable_cleanup_claude.sh` — `~/.claude` の残留データ整理（`--dry-run` 対応）．

## シェル環境

ログインシェルは **fish**（`dot_config/private_fish/config.fish`）．スクリプトを書く際の前提:
- エイリアスでコマンドが置き換わっている: `cat`→`bat`, `ls`→`eza`, `find`→`fd`, `grep`→`rg`, `cd`→`z`(zoxide)．スクリプト内でこれらの挙動に依存しないこと．
- `XDG_CONFIG_HOME=$HOME/.config` を前提に各ツールの設定パスが決まる．
- SSH 認証は GPG agent 経由（`SSH_AUTH_SOCK` を gpgconf で設定）．

## パッケージ管理

`dot_Brewfile`（→ `~/.Brewfile`）が唯一の Homebrew マニフェスト．パッケージの追加・削除はここを編集し，`brew bundle --file ~/.Brewfile` で反映する．`--zap` でマニフェスト外のものは削除されるため，手動 `brew install` したものは Brewfile に追記しないと消える．

## Claude Code 設定（private_dot_claude/）

`~/.claude` 配下の設定そのものをこのリポジトリで管理している．
- `settings.json` — Claude Code のグローバル設定．
- `agents/` — カスタムサブエージェント定義（`.md`）．
- `skills/` — カスタムスキル定義（各ディレクトリの `SKILL.md`）．
- `CLAUDE.md`（このファイルとは別物）— ユーザーのグローバル指示．

agent と skill は対になっているものが多い（`fix-ci`, `fix-review`, `commit-msg` など）．片方を変更する際はもう片方との整合性を確認すること．
