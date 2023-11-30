brew update
brew bundle --file '~/Brewfile'
brew bundle cleanup --force --file '~/Brewfile'
brew upgrade
brew cleanup
