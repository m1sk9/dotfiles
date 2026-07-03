#!/usr/bin/env fish

chezmoi apply --force

brew update
brew bundle --file ~/.Brewfile
brew bundle cleanup --zap --force --file ~/.Brewfile
brew upgrade
brew cleanup
