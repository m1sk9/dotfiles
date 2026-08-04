#!/usr/bin/env fish

brew update
brew bundle --file ~/.Brewfile
brew bundle cleanup --file ~/.Brewfile
brew upgrade
brew cleanup
