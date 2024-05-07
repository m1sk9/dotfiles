function __ghr_repository_search -d 'Repository search'
    set -l selector
    [ -n "$GHR_SELECTOR" ]; and set selector $GHR_SELECTOR; or set selector fzf
    set -l selector_options
    [ -n "$GHR_SELECTOR_OPTS" ]; and set selector_options $GHR_SELECTOR_OPTS

    if not type -qf $selector
        printf "\nERROR: '$selector' not found.\n"
        return 1
    end

    set -l query (commandline -b)
    [ -n "$query" ]; and set flags --query="$query"; or set flags
    switch "$selector"
        case fzf fzf-tmux peco percol fzy sk
            ghr list -p | "$selector" $selector_options $flags | read select
        case \*
            printf "\nERROR: plugin-ghr is not support '$selector'.\n"
    end
    [ -n "$select" ]; and cd "$select"
    commandline -f repaint
end
