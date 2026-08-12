# Disable adaptive thinking for Claude to speed up responses
#
# Why not chrome-devtools を user scope に置く: 既定の kitesurf と同じ
# chrome-devtools-mcp なので，両方を常時有効にするとツール定義が二重に載る．
# localhost を見るときだけ要るので --chrome を付けた起動でそのプロジェクトにだけ入れる．
#
# Why not 起動のたびに入れ直す: local scope の定義は ~/.claude.json のプロジェクト
# 配下に残るため，二度目以降は素の `claude` でも有効になる．外すのは
# `claude mcp remove chrome-devtools --scope local`．
function claude
    if contains -- --chrome $argv
        set -l i (contains -i -- --chrome $argv)
        set -e argv[$i]
        command claude mcp get chrome-devtools >/dev/null 2>&1
        or command claude mcp add chrome-devtools --scope local \
            -- bunx chrome-devtools-mcp --channel=dev
    end

    env CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1 command claude $argv
end
