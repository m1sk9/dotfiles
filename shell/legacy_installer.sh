# 現在 Moria v0.2.0 で `exec` が正常に動作しないため、代替として用意しています。
# 今後非推奨になる予定です。

# Homebrew
download_homebrew() {
    echo "--- Homebrew のインストール ----"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    echo "--- Homebrew のインストールが完了しました。"
}

# Rosetta2
download_rosetta() {
    echo "--- Rosetta2 のインストール ----"
    sudo softwareupdate --install-rosetta
    echo "--- Rosetta2 のインストールが完了しました。"
}

# Brewfile
brew_bundle() {
    echo "--- Brewfile の同期 ----"
    brew bundle --file '~/Brewfile'
    echo "--- Brewfile の同期が完了しました。"
}

# tpm
clone_tmp() {
    echo "--- tpmのクローン ----"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "--- ヒント: .tmux.conf に記載されているプラグインを有効にするために tmux 起動後 【prefix+I】 を実行してください"
    echo "--- tpm のクローンが完了しました。"
}

# 開発環境
setup_development() {
    echo "--- 開発環境のセットアップ ----"
    if command -v node &>/dev/null; then
        echo "--- すでに Node.js はインストールされています。"
    else
        brew install nvm
        nvm install "lts/*" --reinstall-packages-from=current
    fi

    if command -v rustc &>/dev/null; then
        echo "--- すでに Rust はインストールされています。"
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    fi

    if command -v deno &>/dev/null; then
        echo "--- すでに Deno はインストールされています。"
    else
        brew install deno
    fi
    echo "--- 開発環境のセットアップが完了しました。"
}

reload_file() {
    source ~/dotfiles/.zshrc
}

# ---------------

echo "--- lis2a/dotfiles インストーラーへようこそ"

echo "--- 現在の環境:" "$(uname)"
echo "--- この環境にあったセットアップを実行します。"


if [ "$(uname)" == "Darwin" ] ; then # macOS - 全部実行
    download_homebrew
    download_rosetta
    reload_file
    if [ -n "$GITHUB_ACTIONS" ] ; then
        echo "--- Skip: GitHub Actions 上で実行されているため、 [Brewfile の同期] がスキップされました。"
    else
        brew_bundle
    fi
    clone_tmp
    setup_development
else
    link_symboliclink
    clone_tmp
fi

echo "--- Done! dotfilesのセットアップが完了しました。"
