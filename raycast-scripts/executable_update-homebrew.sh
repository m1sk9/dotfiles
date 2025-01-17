#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Update Homebrew
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🩵

# Documentation:
# @raycast.description Update formula and casks, homebrew
# @raycast.author Sho Sakuma
# @raycast.authorURL https://github.com/m1sk9

brew update
brew bundle --file '~/.Brewfile'
brew bundle cleanup --force --file '~/.Brewfile'
brew upgrade
brew cleanup

