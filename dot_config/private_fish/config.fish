# setting alias
alias lg='lazygit'
alias v='lvim'
alias ze='zed-preview'
alias co='code-insiders'
alias vim='lvim'

alias gr='ghr'
alias gc='ghr cd'
alias clone='ghr clone'

alias c='bat'
alias g='git'
alias ls='eza'
alias l='eza -abghHliS'
alias p='pbcopy'
alias cat='bat'
alias find='fd'
alias grep='rg'

# setting path
set -x PATH "$DENO_INSTALL/bin:$PATH"
set -x PATH "$HOME/.deno/bin:$PATH"
set -x PATH "$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
set -x PATH "$PATH:/opt/homebrew/bin"
set -x PATH "$PATH:/usr/local/bin"
set -x PATH "$PATH:$HOME/.local/bin"

# setting environment variables
set -x EDITOR "/opt/homebrew/bin/nvim"
set -x SSH_AUTH_SOCK "$(/opt/homebrew/bin/gpgconf --list-dirs agent-ssh-socket)"
set -x DENO_INSTALL "$HOME/.deno"
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
