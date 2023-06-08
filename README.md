# dotfiles

## Usage

### macOS

macOS の場合は通常のインストーラー [`./installer.sh`](./installer.sh) を実行してください。

`./installer.sh` は次のような作業を行います。

- シンボリックリンクの再リンク
- Homebrew のインストール
- Rosetta2 (異なるアーキテクチャの翻訳を行うツール) のインストール
- Brewfile の同期
- tmp (tmuxのプラグインマネージャー) のインストール
- 以下の開発環境の構築
  - Node.js
  - Rust
  - Deno

### Other OS (Not Windows)

macOS 以外の OS でかつ、 **Windows** 以外では縮小版のインストーラー [`./minimum_installer.sh`](./minimum_installer.sh) を実行してください。

`./minimum_installer.sh` は次のような作業を行います。

- 最小限のソフトウェアのインストール
- シンボリックリンクの再リンク
- tmp (tmuxのプラグインマネージャー) のインストール

### Windows

この dotfiles は Windows に対応していません。

## Homebrew Runner

Homebrew に関する一連の作業を自動化するため、 Homebrew Runner を用意しています。

Brewfile の更新など完了したら `./minimum_installer.sh` を実行してください。
