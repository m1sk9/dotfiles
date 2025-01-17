#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Apply dotfiles
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🧡

# Documentation:
# @raycast.author Sho Sakuma
# @raycast.authorURL https://github.com/m1sk9

if ! command -v chezmoi >/dev/null 2>&1; then
    echo "chezmoi is not installed"
    exit 1
fi

chezmoi update
chezmoi apply
echo "The latest dotfiles have been applied!"
