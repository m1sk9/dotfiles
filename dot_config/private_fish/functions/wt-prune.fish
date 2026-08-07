# Why not `git worktree prune`: それはメタデータの整合性を取るだけで，
# checkout 先ディレクトリ自体は消さない．ここでは herdr の worktree 置き場
# (~/Repositories/claude.ai) を走査し，upstream が削除済み
# (= PR merge 後に remote branch が消えた) な checkout を実体ごと片付ける．
function wt-prune --description "merge 済み・upstream 削除済みブランチの herdr worktree checkout を一括削除する"
    set -l root ~/Repositories/claude.ai

    if not test -d "$root"
        echo "wt-prune: $root が存在しません"
        return 1
    end

    for repo_dir in $root/*/
        set -l worktrees $repo_dir*/
        if test (count $worktrees) -eq 0
            continue
        end

        git -C "$worktrees[1]" fetch --prune --quiet 2>/dev/null

        for wt_dir in $worktrees
            set -l branch (git -C "$wt_dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
            if test -z "$branch"; or test "$branch" = HEAD
                continue
            end

            set -l track (git -C "$wt_dir" for-each-ref --format='%(upstream:track)' refs/heads/"$branch")
            if test "$track" = "[gone]"
                set -l err (git -C "$wt_dir" worktree remove "$wt_dir" 2>&1)
                if test $status -eq 0
                    echo "removed: $wt_dir ($branch)"
                else
                    echo "skip (uncommitted changes?): $wt_dir ($branch) -- $err"
                end
            end
        end
    end
end
