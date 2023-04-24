# Homebrew 自身のアップデート
homebrew_update() {
    echo "--- Homebrew 自身のアップデートを行います。"
    brew update
    echo "--- Homebrew のアップデートが完了しました。"
}

# Brewfile の同期
brewfile() {
    echo "--- Brewfile の同期を行います。"
    brew bundle --file '~/Brewfile'
    brew bundle cleanup --force --file '~/Brewfile'
    echo "--- Brewfile の同期が完了しました。"
}

# インストール済みのformulaの更新
brew_upgrade() {
    echo "--- インストール済みのformulaの更新を行います。"
    brew upgrade
    echo "--- 更新が完了しました。"
}

# インストール済みのformulaのクリーンアップ
# 同時にHomebrew prefix に存在するデッドシンボリックリンク(死んでしまったシンボリックリンク)を削除
brew_cleanup() {
    echo "--- インストール済みのformulaのクリーンアップを行います。"
    brew cleanup -n
    echo "--- 以上。これらのパッケージがクリーンアップされます。"
    brew cleanup
    echo "--- クリーンアップが完了しました。"
}

# -----------

brew --version

if [ ! command -v rustc &>/dev/null ]; then
    echo "--- Homebrew がインストールされていません。このランナーは Homebrew をインストールしていないと実行できません。"
    exit 1
fi

homebrew_update
brewfile
brew_upgrade
brew_cleanup

echo "--- Done! ランナーの実行が完了しました。"
