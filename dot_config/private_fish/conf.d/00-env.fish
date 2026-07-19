# Why not `eval (brew shellenv)`: 出力は静的なのに起動毎に ~21ms かかるため展開して固定
set -gx HOMEBREW_PREFIX /opt/homebrew
set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
set -gx HOMEBREW_REPOSITORY /opt/homebrew
fish_add_path --global --move --path /opt/homebrew/bin /opt/homebrew/sbin
if not contains /opt/homebrew/share/info $INFOPATH
    set -gx INFOPATH /opt/homebrew/share/info $INFOPATH
end

fish_add_path --global $HOME/.local/bin $HOME/.cargo/bin $HOME/.deno/bin

set -gx EDITOR /usr/bin/vim
set -gx LANG en_US.UTF-8
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx GHR_ROOT $HOME/Repositories
# Colima の config dir を固定する (~/.colima の有無に関わらず最優先される)
set -gx COLIMA_HOME $HOME/.config/colima
set -gx DOCKER_HOST unix://$COLIMA_HOME/default/docker.sock
# Homebrew の tap trust は非推奨 (will be removed) で毎回警告が出るため無効化
set -gx HOMEBREW_NO_REQUIRE_TAP_TRUST 1
# Why not `gpgconf --list-dirs agent-ssh-socket`: コマンド置換で ~9ms かかり，
# GNUPGHOME 既定ではこの固定パスと同値のため
set -gx SSH_AUTH_SOCK $HOME/.gnupg/S.gpg-agent.ssh

# Why not vendor_conf.d の mise-activate.fish: 非対話シェルまで full activate (~150ms)
# されるため無効化し，自前の conf.d/mise-activate.fish で制御する
set -gx MISE_FISH_AUTO_ACTIVATE 0
