#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Restart yabai and skhd
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🍃

# Documentation:
# @raycast.description Restarting yabai and skhd, using command line.
# @raycast.author Sho Sakuma
# @raycast.authorURL https://github.com/m1sk9

#!/bin/sh

# Check if yabai is installed
if ! command -v yabai >/dev/null 2>&1; then
    echo "yabai is not installed"
    exit 1
fi

yabai --restart-service

# Check if skhd is installed
if ! command -v skhd >/dev/null 2>&1; then
    echo "skhd is not installed"
    exit 1
fi

skhd --restart-service

echo "Restarting yabai and skhd!"
