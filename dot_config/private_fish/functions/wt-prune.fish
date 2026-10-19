# Why not `git worktree prune`: それはメタデータの整合性を取るだけで，
# checkout 先ディレクトリ自体は消さない．ここでは worktree の置き場所に依存せず，
# 各リポジトリの `git worktree list` から (herdr / Claude Code / 旧 .claude/worktrees
# を問わず) メイン以外の全 worktree を走査し，upstream が削除済み
# (= PR merge 後に remote branch が消えた) な checkout を実体ごと片付ける．
# upstream を持たない (未 push の) ブランチは [gone] にならないので対象外．
function wt-prune --description "upstream 削除済みブランチの worktree checkout を全リポジトリから一括削除する"
    set -l dry_run 0
    if contains -- --dry-run $argv
        set dry_run 1
    end

    set -l root ~/Repositories/claude.ai

    if not test -d "$root"
        echo "wt-prune: $root が存在しません"
        return 1
    end

    # worktree 側と通常 checkout 側の両方から main repo (git common dir) を集める．
    # 旧 .claude/worktrees しか残っていないリポジトリも拾うため．
    set -l repos
    for dir in $root/*/*/ ~/Repositories/github.com/*/*/
        set -l common (git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
        and set -a repos $common
    end
    set repos (printf '%s\n' $repos | sort -u)

    for common in $repos
        git -C "$common" fetch --prune --quiet 2>/dev/null

        set -l idx 0
        set -l wt_dir
        for line in (git -C "$common" worktree list --porcelain)
            if string match -q 'worktree *' -- $line
                set idx (math $idx + 1)
                set wt_dir (string replace 'worktree ' '' -- $line)
                continue
            end

            # 1 件目はメイン checkout
            test $idx -gt 1; or continue
            string match -q 'branch refs/heads/*' -- $line; or continue

            set -l branch (string replace 'branch refs/heads/' '' -- $line)
            set -l track (git -C "$common" for-each-ref --format='%(upstream:track)' refs/heads/"$branch")
            if test "$track" = "[gone]"
                if test $dry_run -eq 1
                    echo "would remove: $wt_dir ($branch)"
                    continue
                end

                set -l err (git -C "$common" worktree remove "$wt_dir" 2>&1)
                if test $status -eq 0
                    echo "removed: $wt_dir ($branch)"
                else
                    echo "skip (uncommitted changes?): $wt_dir ($branch) -- $err"
                end
            end
        end
    end
end
