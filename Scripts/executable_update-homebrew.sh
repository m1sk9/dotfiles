#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Update homebrew
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🍺
# @raycast.needsConfirmation true

# Documentation:
# @raycast.author m1sk9
# @raycast.authorURL https://m1sk9.dev

chezmoi apply --force

brew update
brew bundle --file '~/.Brewfile'
brew bundle cleanup --zap --force --file '~/.Brewfile'
brew upgrade
brew cleanup
