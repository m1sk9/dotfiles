alias lg='lazygit'
alias vim='nvim'
alias cg='ghr cd'
alias cat='bat'
alias ls='eza'
alias l='eza -abghHliS'
alias find='fd'
alias grep='rg'
alias code='code-insiders'

set -x EDITOR "/opt/homebrew/bin/nvim"
set -x SSH_AUTH_SOCK "$(/opt/homebrew/bin/gpgconf --list-dirs agent-ssh-socket)"
set -x XDG_CONFIG_HOME "$HOME/.config"
set -x GHR_ROOT "$HOME/Projects"
set -x STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"

fish_add_path /opt/homebrew/bin # NOTE: /opt/homebrew/bin を先に設定しないと `git` などがシステム側を使うようになってしまう
fish_add_path /usr/bin
fish_add_path /usr/local/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.deno/bin

# setting fish

eval "$(/opt/homebrew/bin/brew shellenv)"
starship init fish | source
ghr shell fish | source
mise activate fish | source
gpg-connect-agent /bye
