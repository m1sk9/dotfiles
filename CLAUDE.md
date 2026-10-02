# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

このリポジトリは [chezmoi](https://github.com/twpayne/chezmoi) で管理する macOS 向け dotfiles の**ソースディレクトリ**である．`~/dotfiles` に置かれ（`.chezmoi.toml.tmpl` の `sourceDir`），`chezmoi apply` で実ファイル（`$HOME` 配下）に展開される．つまりここで編集するのはソースであって，反映先のファイルではない点に常に注意すること．

## よく使うコマンド

- `chezmoi diff` : ソースを変更した後，実際の展開結果との差分を確認する（apply 前に必ず確認）．
- `chezmoi apply` : ソースを `$HOME` に反映する．自動コミット・プッシュはされない点に注意（下記「自動コミットに関する注意」参照）．
- `chezmoi apply --dry-run --verbose` : 実ファイルを変更せずに適用結果だけを確認する．
- `chezmoi execute-template < file.tmpl` : `.tmpl` ファイルのテンプレート展開結果だけを確認する（`run_onchange_*.tmpl` などの動作検証に有用）．
- `chezmoi cd` : ソースディレクトリへ移動するサブシェルを開く．

## chezmoi のファイル命名規則（最重要）

ファイル名のプレフィックスがそのまま反映先のパス・属性を決める．ファイルを新規作成・リネームする際は規則に従うこと．

- `dot_foo` → `~/.foo`（`dot_config/` → `~/.config/`）
- `private_foo` → 権限 `0600` で展開（`private_dot_claude/` → `~/.claude/`）
- `executable_foo` → 実行ビットを付与して展開（`executable_homebrew.fish`）
- `encrypted_foo.age` → age で復号して展開（`dot_awseal/encrypted_config.json.age`）
- `*.tmpl` → Go テンプレートとして評価してから展開
- `run_once_*` → `chezmoi apply` 時に一度だけ実行されるスクリプト

管理対象外のファイルは `.chezmoiignore` に列挙されている．リポジトリにはあるが `$HOME` には展開されない．

## 自動コミットに関する注意

`.chezmoi.toml.tmpl` で `git.autoCommit` / `git.autoPush` が `true` になっている．ただしこれが発火するのは `chezmoi add` / `chezmoi re-add` のようにソースディレクトリ自体を書き換えるコマンドの後だけで，`chezmoi apply` 単体では（ソース側に変更が無い限り）何もコミットされない．Edit/Write でソースファイルを直接編集した場合は，`chezmoi apply` を実行しても自動コミットは走らないので，`git add` → `git commit` → `git push` は都度手動で行うこと．

Edit/Write でソースファイルを変更したら，`chezmoi diff` で差分確認したうえで `chezmoi apply` まで毎回実行すること．ただしファイル削除を伴う変更・暗号化ファイルや秘密情報が絡む変更など，破壊的・不可逆な変更が伴う場合は事前に確認を取ること．

通常の `git add` → `git commit` → `git push`（現在のブランチを origin へ通常 push）も，確認を取らずに毎回実行すること．ただし force push や履歴を書き換える操作は対象外で，別途確認を取ること．

## 暗号化

- 暗号化方式は **age**．`encrypted_*.age` ファイルは復号鍵 `~/.config/chezmoi/key.txt` が無いと扱えない．復号鍵そのものはパスフレーズで暗号化して `.chezmoi-key.age` に置き，鍵が無いマシンでは `run_onchange_before_00-decrypt-age-key.sh.tmpl` が apply の最初に復号する（パスフレーズ入力を求められる）．
- `dot_awseal/encrypted_config.json.age` は [awseal](https://github.com/s6n-jp) の設定．**復号後の平文を誤って平文ファイルとしてコミットしないこと．**
- `$HOME` に平文を落としたくない秘密は `encrypted_*` ではなく，ドット始まりのソースファイル（例: `.obsidian-token.age`）に置き，テンプレート内で ``{{ joinPath .chezmoi.sourceDir `<file>` | include | decrypt }}`` として使う．ドット始まりは chezmoi が展開対象から外すため，復号値はレンダリング結果にしか現れない．

## Neovim（dot_config/nvim/）

開発環境（LSP・補完・Treesitter・ファイルツリー・ファジーファインダー等）としては使わず，Vim の代替として使える程度の設定（options / keymaps / colorscheme / autopairs / which-key）だけを残している．開発用途は Zed が担うので，IDE 化するプラグインを戻さないこと．

`init.lua` は `options.lua` → `keymaps.lua` → lazy.nvim の順で読み込む（`keymaps.lua` が `vim.g.mapleader` を設定するため，これより後に lazy.nvim を読み込むとプラグイン側の `<leader>` マッピングが素の `<Space>` として登録されてしまう）．lazy.nvim 自体は `.chezmoiexternal.toml` 経由ではなく `init.lua` 内で git clone して自己管理する（バージョン固定は lazy.nvim 自身の `lazy-lock.json` に任せ，chezmoi external との二重管理を避けるため）．`lua/plugins/` 配下の全ファイルがプラグイン定義として読み込まれる．

## Hammerspoon（dot_hammerspoon/）

ウィンドウ管理は Hammerspoon（`~/.hammerspoon/init.lua`）が担う（2026-10-02 に Rectangle から移行）．ショートカットは Rectangle 時代の割り当てを引き継いでいる．`init.lua` は `hs.pathwatcher` で監視しているので，`chezmoi apply` するだけで自動リロードされる．

## macOS のシステム設定

Dock・Finder・キーボードなどの `defaults` は `run_onchange_after_configure-macos-defaults.lua`（LuaJIT）の `settings` 表で管理する．項目の追加はドメインとキーを表に足すだけで，値の Lua 型から `-bool` / `-int` / `-float` / `-string` が決まる．現在値と異なる項目だけを書き込み，変更があったドメインに対応するプロセス（Dock / Finder など）だけを再起動する．GUI で設定を変えたら表にも反映すること（表と食い違うと次に表を変更して apply したときに巻き戻る）．

## シェル環境

ログインシェルは **fish**（`dot_config/private_fish/config.fish`）．スクリプトを書く際の前提:
- エイリアスでコマンドが置き換わっている: `cat`→`bat`, `ls`→`eza`, `find`→`fd`, `grep`→`rg`, `cd`→`z`(zoxide)．スクリプト内でこれらの挙動に依存しないこと．
- `XDG_CONFIG_HOME=$HOME/.config` を前提に各ツールの設定パスが決まる．
- SSH 認証は GPG agent 経由（`SSH_AUTH_SOCK` を gpgconf で設定）．

## 新規マシンのセットアップ（bootstrap）

README の 1 行（`get.chezmoi.io` → `init --apply`）で完結させる．その前提として:
- `run_*_before_*` と `run_*_after_<数字>-*` の bootstrap スクリプトは **POSIX sh** で書く（fish はまだ入っていない／fish に依存させないため）．fish 前提の原則の例外はこれらだけ．
- スクリプトの PATH は `.chezmoi.toml.tmpl` の `[scriptEnv]` で固定している．Homebrew 未導入のシェルから起動されても，before スクリプトが入れた fish / luajit / herdr / claude を後続スクリプトが見つけられるようにするため．新しく PATH に依存するツールの置き場所が増えたらここに足すこと．`.chezmoi.toml.tmpl` を変えたら `chezmoi init` で設定を再生成すること．
- 一度しか成功しない前提を置けない処理（YubiKey が挿さっていないと終われない GPG の取り込みなど）は `run_once_` にせず，冪等な `run_after_` にして早期 return する（`run_once_` はスキップして exit 0 しても実行済みになる）．

## パッケージ管理

`dot_Brewfile`（→ `~/.Brewfile`）が唯一の Homebrew マニフェスト．パッケージの追加・削除はここを編集し，`chezmoi apply` で反映する（`run_onchange_before_10-install-packages.sh.tmpl` が Brewfile のハッシュを埋め込んでいるので，Brewfile を変えた次の apply で `brew bundle --no-upgrade` が走る）．削除と upgrade は apply では行わず `homebrew.fish` が担う．`--zap` でマニフェスト外のものは削除されるため，手動 `brew install` したものは Brewfile に追記しないと消える．App Store のアプリも `mas "<名前>", id: <ID>` で同じ Brewfile に載せる（ID は `mdls -raw -name kMDItemAppStoreAdamID <app>` で取れる）．

## Claude Code 設定（private_dot_claude/）

`~/.claude` 配下の設定そのものをこのリポジトリで管理している．`private_dot_claude/CLAUDE.md` はユーザーのグローバル指示であって，このファイルとは別物である（プロジェクト固有の記述を書くと全プロジェクトに漏れる）．

agent と skill は対になっているものが多い（`fix-ci`, `fix-review`, `fix-dependabot` など）．片方を変更する際はもう片方との整合性を確認すること．

## MCP サーバー設定

user scope の MCP サーバー定義の source of truth は `.chezmoitemplates/mcp-servers.json` であり，`~/.claude.json` を直接編集・管理下には置いていない（`numStartups` や `projects` などの可変状態を含むため）．`run_onchange_configure-claude-mcp.fish.tmpl` がこの JSON を読み，`claude mcp remove` → `claude mcp add-json --scope user` で CLI 経由で注入する．MCP サーバーを追加・変更する際は `.chezmoitemplates/mcp-servers.json` を編集すること（詳細な理由は同スクリプト内の Why not コメントを参照）．

ただしここに置いたものは全プロジェクトに載る．用途が限られる MCP・plugin は `dot_config/private_fish/functions/claude.fish` の `optional_local` 表に `<flag>:<kind>:<name>:<payload>` を足し，`claude --chrome` のように起動時フラグで local scope に投入する．ブラウザ MCP は user scope の `browser` (Kitesurf) と同名を local scope に入れて隠す設計なので，ローカル Chrome を使う側も名前は `browser` にすること（別名にすると同じ chrome-devtools-mcp が 2 つ起動する）．

## 依存バージョンの自動更新（Renovate）

`.github/renovate.json` は herdr-lazy の `plugins.list`（`owner/repo@vX.Y.Z`）を正規表現で検出するカスタムマネージャーを持つ．herdr のプラグインを追加・更新する際はこの書式に従うことで Renovate の自動 PR 対象にできる．

## Claude Code のステータスラインと使用量の通知

- **ステータスライン**（`private_dot_claude/statusline/`）: `statusLine` から `luajit ~/.claude/statusline/statusline.lua` で呼ぶ自作の 1 行．Claude Code が stdin に渡す JSON を自前の `json.lua` で読み，`render.lua` が整形する．git は `branch --show-current` しか叩かない（`git status` は大きなリポジトリで描画のたびに CPU を食うため入れない）．テストは `luajit private_dot_claude/statusline/.tests/run.lua`（ドット始まりなので展開されない）．
- **使用量の通知**（`private_dot_claude/mods/usage-alert/`）: Claude Code の Mod．5 時間枠・週次枠・Fable の週次枠が 80% / 95% を超えたときだけ toast を出す．`settings.json` の `env.CLAUDE_CODE_PLUGIN_DIRS` で読み込ませている．Fable の枠は `$.session.usage()` に来ないため，`$.session.authorize()` のハンドルで内部 API（`api.anthropic.com/api/oauth/usage`）を 10 分ごとに叩き，結果を `~/.claude/.usage-cache` にも書く（fish の `claude --plan` の起動前警告が読む）．
  - chezmoi はドット始まりのソースを展開しないので，マニフェストのディレクトリは `dot_claude-plugin/` と書く．同じ理由で `claude plugin validate` / `claude plugin test` はソースではなく apply 後の `~/.claude/mods/usage-alert` に対して実行すること．
  - ソース側の `tsconfig.json` は apply 後のディレクトリに Claude Code が書き出す型（`.claude-plugin/types/`）を `extends` で参照する．エディタや `tsc -p` で `'claude-code'` が解決できないときは，Mod が一度読み込まれて型が書き出されているかを確認すること．このファイルは `.chezmoiignore` で展開対象から外している（展開先には Claude Code 自身の `tsconfig.json` があるため）．
