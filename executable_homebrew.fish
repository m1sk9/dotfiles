#!/usr/bin/env fish

brew update
brew bundle --file ~/.Brewfile
brew bundle cleanup --zap --force --file ~/.Brewfile
brew upgrade
brew cleanup
