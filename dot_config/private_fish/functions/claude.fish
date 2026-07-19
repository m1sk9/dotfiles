# Disable adaptive thinking for Claude to speed up responses
function claude
    env CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1 command claude $argv
end
