# Why not `ghr shell fish | source`: 出力は静的な関数定義のみで起動毎の ~27ms が無駄なため
# (ghr 更新時は `ghr shell fish` の出力との diff を確認して再生成する)

function __ghr_remove
    for VAR in $argv[2..]
        if test "$VAR" = "$argv[1]"
            continue
        end

        echo "$VAR"
    end
end

function __ghr_cd
    cd "$(ghr path $argv)"
end

function ghr
    if contains -- "--help" $argv[1..]; or contains -- "-h" $argv[1..]
        command ghr $argv[1..]
        return 0
    end

    if test "$argv[1]" = "cd"
        __ghr_cd $argv[2..]
        return 0
    end

    if test "$argv[1]" = "clone" || test "$argv[1]" = "init"
        if contains -- "--cd" $argv[2..]
            command ghr "$argv[1]" $argv[2..] && __ghr_cd (__ghr_remove "--cd" $argv[2..])
            return 0
        end
    end

    command ghr $argv[1..]
end
