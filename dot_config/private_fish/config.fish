alias lg='lazygit'
alias cat='bat'
alias ls='eza'
alias l='eza -abghHliS'
alias find='fd'
alias grep='rg'

set -x EDITOR "/usr/bin/vim"
set -x SSH_AUTH_SOCK "$(/opt/homebrew/bin/gpgconf --list-dirs agent-ssh-socket)"
set -x XDG_CONFIG_HOME "$HOME/.config"
set -x GHR_ROOT "$HOME/Projects"
set -x STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"

fish_add_path /opt/homebrew/bin
fish_add_path /usr/bin
fish_add_path /usr/local/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.deno/bin

# setting fish
starship init fish | source
eval "$(/opt/homebrew/bin/brew shellenv)"
ghr shell fish | source
mise activate fish | source
gpg-connect-agent /bye

export LANG=en_US.UTF-8

