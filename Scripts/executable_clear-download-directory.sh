#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Clear Download directory
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🗑️
# @raycast.needsConfirmation true

# Documentation:
# @raycast.author m1sk9
# @raycast.authorURL https://m1sk9.dev

DOWNLOADS_DIR="$HOME/Downloads"

if [ -d "$DOWNLOADS_DIR" ]; then
    # Count files excluding .DS_Store and .localized
    file_count=$(find "$DOWNLOADS_DIR" -maxdepth 1 -type f ! -name '.DS_Store' ! -name '.localized' | wc -l)
    dir_count=$(find "$DOWNLOADS_DIR" -maxdepth 1 -mindepth 1 -type d | wc -l)

    if [ "$file_count" -gt 0 ] || [ "$dir_count" -gt 0 ]; then
        # Remove all files and directories except .DS_Store and .localized
        find "$DOWNLOADS_DIR" -maxdepth 1 -mindepth 1 ! -name '.DS_Store' ! -name '.localized' -exec rm -rf {} +
        echo "Downloads directory cleared"
    else
        echo "Downloads directory is already empty"
    fi
else
    echo "Downloads directory does not exist"
fi
