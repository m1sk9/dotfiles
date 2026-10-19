#!/opt/homebrew/bin/fish
# Why not a settings key: Claude Code has no setting for the base directory of
# --worktree / EnterWorktree worktrees. WorktreeCreate is the only override, and it
# replaces the default git logic, so .worktreeinclude is not processed.
# Layout is <root>/<repo>/<name>, the same as herdr, so wt-prune sees both alike.

set -l input (cat | string collect)
set -l name (echo $input | jq -r .name)
set -l cwd (echo $input | jq -r .cwd)

set -l common (git -C $cwd rev-parse --path-format=absolute --git-common-dir)
or exit 1

set -l dir ~/Repositories/claude.ai/(basename (dirname $common))/$name

if not test -e $dir
    mkdir -p (dirname $dir)
    git -C $cwd worktree add -b worktree-$name $dir HEAD >&2
    or exit 1
end

echo $dir
