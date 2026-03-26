#!/bin/bash
set -euo pipefail

query=$(cat | jq -r '.query')
root="${CLAUDE_PROJECT_DIR:-.}"

fd --type f --hidden --exclude .git "$query" "$root" 2>/dev/null | head -15
