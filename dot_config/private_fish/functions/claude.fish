# Disable adaptive thinking for Claude to speed up responses
#
# Why not 全部 user scope に置く: stripe plugin は skill を常時 ~1.5k tok 積み，
# ブラウザは要るプロジェクトが限られるので，フラグを付けた起動でそのプロジェクト
# (local scope) にだけ入れる．
#
# Why not chrome を別名で入れる: user scope の browser (Kitesurf) と名前を揃えると
# local が user を隠すため，ブラウザ MCP は常に 1 つしか起動しない．別名にすると
# 同じ chrome-devtools-mcp が 2 つ立ち，同じツールが 2 セット見えて選べなくなる．
# 代償として `claude mcp list` に [Conflicting scopes] 警告が出るが動作に影響はない．
#
# Why not 起動のたびに入れ直す: local scope の定義はプロジェクト側
# (~/.claude.json / .claude/settings.local.json) に残るので，二度目以降は素の
# `claude` でも有効になる．外すのは `claude mcp remove <name> --scope local` /
# `claude plugin disable <name> --scope local`．
function claude
    # --<flag> を付けた起動でだけ local scope に入れるもの．
    # 増やすときは `<flag>:<kind>:<name>:<payload>` の行を足す．
    # kind=mcp は payload を `mcp add-json` に渡す JSON，kind=plugin は payload なし．
    # JSON 側の ':' は `string split -m 3` が 4 要素目に残すので割れない．
    set -l optional_local \
        'chrome:mcp:browser:{"type":"stdio","command":"bunx","args":["chrome-devtools-mcp","--channel=dev"]}' \
        'stripe:plugin:stripe@claude-plugins-official:'

    for entry in $optional_local
        set -l spec (string split -m 3 ':' -- $entry)
        set -l flag "--$spec[1]"
        contains -- $flag $argv; or continue

        set -l i (contains -i -- $flag $argv)
        set -e argv[$i[1]]

        # Why not 事前に入っているか調べる: `mcp get` は user scope の同名も拾うので，
        # browser を local に入れる場面で「既にある」と誤判定して投入を飛ばす．
        # どちらの投入コマンドも二重投入なら stderr に出して exit 1 するだけなので，
        # それを捨てて投入側に判定を任せる．初回だけ stdout に結果が出る．
        switch $spec[2]
            case mcp
                command claude mcp add-json $spec[3] $spec[4] --scope local 2>/dev/null
            case plugin
                command claude plugin enable $spec[3] --scope local 2>/dev/null
        end
    end

    env CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1 command claude $argv
end
