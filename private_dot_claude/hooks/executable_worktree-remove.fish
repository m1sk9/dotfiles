#!/opt/homebrew/bin/fish
# Claude Code never deletes the branch of a hook-created worktree, so do it here.
# Why not `branch -D`: the user may have committed in it, and -d keeps unmerged work.

set -l path (cat | jq -r .worktree_path)

set -l common (git -C $path rev-parse --path-format=absolute --git-common-dir)
or exit 1
set -l branch (git -C $path rev-parse --abbrev-ref HEAD)

git -C $path worktree remove --force $path >&2
or exit 1

if string match -q 'worktree-*' -- $branch
    git -C $common branch -d $branch >&2
end
exit 0
