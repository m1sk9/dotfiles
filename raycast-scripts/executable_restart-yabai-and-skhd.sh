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

yabai --restart-service
skhd --restart-service

echo "Restarting yabai and skhd!"
