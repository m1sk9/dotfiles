#!/bin/bash

if [ "$(uname)" != "Darwin" ]; then
    exit 1
fi

command -v brew >/dev/null 2>&1 ||
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew bundle --file="$HOME/dotfiles/macOS/config/Brewfile"
brew autoupdate start

if [ "$(sysctl hw.optional.arm64)" == "hw.optional.arm64: 0" ]; then
    sudo softwareupdate --install-rosetta --agree-to-license
fi

if [ "$(echo $SHELL)" != "/opt/homebrew/bin/fish" ]; then
    sudo chsh -s /opt/homebrew/bin/fish
fi

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

fisher install decors/fish-ghq
