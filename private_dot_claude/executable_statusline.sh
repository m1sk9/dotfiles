#!/usr/bin/env bash

# ref: https://zenn.dev/kawarimidoll/articles/00cfa200c12c5f

input=$(cat)

eval "$(echo "$input" | jq -r '
  @sh "MODEL_DISPLAY=\(.model.display_name)",
  @sh "CURRENT_DIR=\(.workspace.current_dir)",
  @sh "USED_PCT=\(.context_window.used_percentage // "")",
  @sh "TOTAL_INPUT=\(.context_window.total_input_tokens // 0)",
  @sh "TOTAL_OUTPUT=\(.context_window.total_output_tokens // 0)",
  @sh "COST_USD=\(.cost.total_cost_usd // 0)"
')"

# Git branch
GIT_BRANCH=""
if git rev-parse &>/dev/null; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  if [ -n "$BRANCH" ]; then
    GIT_BRANCH=" |  $BRANCH"
  else
    COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null)
    [ -n "$COMMIT_HASH" ] && GIT_BRANCH=" |  HEAD ($COMMIT_HASH)"
  fi
fi

# Token display
total_tokens=$((TOTAL_INPUT + TOTAL_OUTPUT))
if [ "$total_tokens" -ge 1000000 ]; then
  token_display="$(awk "BEGIN{printf \"%.1fM\", $total_tokens/1000000}")"
elif [ "$total_tokens" -ge 1000 ]; then
  token_display="$(awk "BEGIN{printf \"%.1fK\", $total_tokens/1000}")"
else
  token_display="$total_tokens"
fi

# Percentage with color
if [ -n "$USED_PCT" ]; then
  pct=${USED_PCT%.*}
  if [ "$pct" -ge 90 ]; then
    color="\033[31m"
  elif [ "$pct" -ge 70 ]; then
    color="\033[33m"
  else
    color="\033[32m"
  fi
  TOKEN_COUNT="${token_display} tkns. ($(echo -e "${color}${pct}%\033[0m"))"
else
  TOKEN_COUNT="${token_display} tkns."
fi

# Cost
if [ "$COST_USD" != "0" ]; then
  COST_DISPLAY=" | $(awk "BEGIN{printf \"$%.2f\", $COST_USD}")"
else
  COST_DISPLAY=""
fi

echo "󰚩 ${MODEL_DISPLAY} |  ${CURRENT_DIR##*/}${GIT_BRANCH} |  ${TOKEN_COUNT}${COST_DISPLAY}"
