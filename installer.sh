# シンボリックリンク
link_symboliclink() {
    echo "--- シンボリックリンクの再リンク"
    ln -s ~/dotfiles/.zshrc ~/
    ln -s ~/dotfiles/.zshenv ~/
    ln -s ~/dotfiles/.zprofile ~/
    ln -s ~/dotfiles/.tmux.conf ~/
    ln -s ~/dotfiles/.gitconfig ~/
    ln -s ~/dotfiles/Brewfile ~/
    ln -s ~/dotfiles/.config ~/
    echo "--- シンボリックリンクの再リンクが完了しました。"
}

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
    brew bundle
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
        node -v
        npm -v
    fi

    if command -v rustc &>/dev/null; then
        echo "--- すでに Rust はインストールされています。"
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

        cargo --version
        rustup --version
        rustc --version
    fi

    if command -v deno &>/dev/null; then
        echo "--- すでに Deno はインストールされています。"
    else
        brew install deno
        deno --version
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
    link_symboliclink
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
