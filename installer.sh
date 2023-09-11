read -p "Are you sure? (During execution, you will be asked to enter your password and other information.) [y/N]" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

sudo softwareupdate --install-rosetta --agree-to-license

./symlink.sh

brew bundle --file '~/Brewfile'

brew autoupdate start

sudo chsh -s /opt/homebrew/bin/fish

fisher install decors/fish-ghq

fisher install jorgebucaran/fish-nvm

fish
