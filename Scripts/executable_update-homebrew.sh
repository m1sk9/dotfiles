#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Update homebrew
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🍺

# Documentation:
# @raycast.author m1sk9
# @raycast.authorURL https://m1sk9.dev

brew update
brew bundle --zap --file '~/.Brewfile'
brew bundle cleanup --zap --force --file '~/.Brewfile'
brew upgrade
brew cleanup
