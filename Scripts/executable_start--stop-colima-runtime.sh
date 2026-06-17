#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Start/Stop Colima runtime
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🐳
# @raycast.needsConfirmation true

# Documentation:
# @raycast.author m1sk9
# @raycast.authorURL https://m1sk9.dev

# Raycast (bash) は fish の環境変数を継承しないため、ここで明示する。
# これがないと colima が ~/.colima を作成し XDG/chezmoi 管理設定が無視される。
export COLIMA_HOME="$HOME/.config/colima"

if colima status > /dev/null 2>&1; then
    # Colima が稼働中の場合は停止
    echo "Colima is running. Stopping..."
    colima stop
    if [ $? -eq 0 ]; then
        echo "Colima stopped successfully"
    else
        echo "Failed to stop Colima"
        exit 1
    fi
else
    echo "Colima is stopped. Starting..."
    colima start
    if [ $? -eq 0 ]; then
        echo "Colima started successfully"
    else
        echo "Failed to start Colima"
        exit 1
    fi
fi
