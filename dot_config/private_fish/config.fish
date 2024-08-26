alias lg='lazygit'
alias vim='nvim'
alias cg='ghr cd'
alias cat='bat'
alias ls='eza'
alias ll='eza -abghHliS'
alias find='fd'
alias grep='rg'

set -x PATH "$PATH:/opt/homebrew/bin"
set -x PATH "$PATH:/usr/bin"
set -x PATH "$PATH:/usr/local/bin"
set -x PATH "$PATH:$HOME/.local/bin"
set -x PATH "$PATH:$HOME/.cargo/bin" # Rust
set -x PATH "$PATH:$HOME/.deno/bin" # Deno

set -x EDITOR "/opt/homebrew/bin/nvim"
set -x SSH_AUTH_SOCK "$(/opt/homebrew/bin/gpgconf --list-dirs agent-ssh-socket)"
set -x XDG_CONFIG_HOME "$HOME/.config"
set -x GHR_ROOT "$HOME/Projects"
set -x STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"
set -U fish_user_paths $fish_user_paths $HOME/.cargo/bin

# setting fish

eval "$(/opt/homebrew/bin/brew shellenv)"
starship init fish | source
ghr shell fish | source
mise activate fish | source
gpg-connect-agent /bye
