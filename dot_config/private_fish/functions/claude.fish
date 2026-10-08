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
#
# Why not Lua に移す: optional_local の文字列分割や jq のフィルタは Lua の表と
# statusline の json.lua で書いたほうが読みやすいが，fish から呼ぶ入口は残るので
# fzf の対話や `command claude` への引数渡しが二層をまたぐ．optional_local が
# 増えて文字列表現が破綻し始めたら移行を考え直す．
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

    # --plan は Fable で計画だけを作り，--impl はその計画を Opus の新しいセッションで実装する．
    # Why not optional_local に入れる: あちらは local scope への投入で，こちらは起動引数の
    # 書き換えなので表の形に合わない．
    # Why not 計画を承認して同じセッションで /model を切り替える: キャッシュはモデルごとに
    # 別なので，計画中に積んだ文脈を Opus がキャッシュなしで読み直すことになる．
    if set -l i (contains -i -- --plan $argv)
        set -e argv[$i[1]]
        __claude_warn_fable_usage
        set -p argv --model fable --permission-mode plan --append-system-prompt \
            'このセッションでは計画だけを作る．実装は別のセッションがこの計画ファイルだけを読んで行うので，変更対象のファイル，手順，検証に使うテストやコマンド，判断とその理由を，会話を読まなくても実装できる粒度で計画に書き切ること．'
    else if set -l i (contains -i -- --impl $argv)
        set -e argv[$i[1]]
        # Why not 最新の計画を自動で選ぶ: ~/.claude/plans は全プロジェクト共通なので，
        # 最新のものが別プロジェクトの計画であることがある．
        set -l plans ~/.claude/plans/*.md
        if test (count $plans) -eq 0
            echo 'claude: ~/.claude/plans に計画ファイルがありません' >&2
            return 1
        end
        set -l plan (command ls -t -- $plans | fzf --prompt 'plan> ' --preview 'bat --color=always --style=plain {}')
        or return 1
        # Why not settings.json の advisorModel: 全セッションで Fable の枠を消費し得るので，
        # 実装セッションにだけ起動引数で付ける．
        __claude_warn_fable_usage
        set -p argv --model opus --advisor fable
        set -a argv "計画ファイル $plan は承認済みです．この計画に沿って実装してください．"
    end

    command claude $argv
end

# Fable の週次枠が 80% / 95% に達していたら警告する．閾値は Mod usage-alert の
# THRESHOLDS (~/.claude/mods/usage-alert/hooks/alerts.ts) と揃えている．
# 数値はその Mod が書く使用量キャッシュから読むだけで，認証情報には触れない．
function __claude_warn_fable_usage
    set -l cache ~/.claude/.usage-cache
    test -r $cache; or return 0
    read -l fetched json <$cache

    set -l fable (printf '%s' $json | jq -r 'first(.limits[]? | select(.kind == "weekly_scoped" and .scope.model.display_name == "Fable")) | "\(.percent | floor) \(try (.resets_at | sub("[.][0-9]+"; "") | sub("[+]00:00$"; "Z") | fromdateiso8601) catch 0)"' 2>/dev/null)
    test -n "$fable"; or return 0
    set -l pct (string split ' ' -- $fable)[1]
    set -l resets (string split ' ' -- $fable)[2]
    set -l now (date +%s)

    # Why not 古いキャッシュを捨てる: Mod は Claude Code の起動中にしか取得しないので，
    # 起動前のここではたいてい古い．捨てると警告が最も要る起動時に出せないため，枠が
    # リセットされる前なら取得時刻を添えて最後の値を使う．
    test $resets -gt 0 -a $resets -le $now; and return 0

    set -l warn 80
    set -l crit 95

    set -l color
    if test $pct -ge $crit
        set color red
    else if test $pct -ge $warn
        set color yellow
    else
        return 0
    end

    set -l age ''
    set -l hours (math -s0 "($now - $fetched) / 3600")
    test $hours -ge 1; and set age "（$hours 時間前の値）"
    set_color $color >&2
    echo "⚠ Fable の週次枠を $pct% 使用しています$age．" >&2
    if test $color = red
        echo '  Opus で計画するなら: claude --model opus --effort xhigh --permission-mode plan' >&2
    end
    set_color normal >&2
end
