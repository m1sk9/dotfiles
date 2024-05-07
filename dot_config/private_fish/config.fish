# setting alias
alias clone='ghr clone'
alias lg='lazygit'
alias ld='lazydocker'
alias c='code-insiders'
alias v='vim'
alias z='zed-preview'

alias ls='eza'
alias l='eza -abghHliS'
alias cat='bat'
alias find='fd'
alias grep='rg'

# setting path
set -x PATH "$DENO_INSTALL/bin:$PATH"
set -x PATH "$HOME/.deno/bin:$PATH"
set -x PATH "$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
set -x PATH "$PATH:/usr/local/bin"

# setting environment variables
set -x SSH_AUTH_SOCK "$(/opt/homebrew/bin/gpgconf --list-dirs agent-ssh-socket)"
set -x DENO_INSTALL "$HOME/.deno"
set -x XDG_CONFIG_HOME "$HOME/.config"
set -x GHR_ROOT "$HOME/projects"
set -x STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"
set -U fish_user_paths $fish_user_paths $HOME/.cargo/bin

# setting fish

eval "$(/opt/homebrew/bin/brew shellenv)"
starship init fish | source
gpg-connect-agent /bye

## fish other settings
set -g fish_greeting # disable fish greeting (welcome message)

# display the current status of the system :) (easter eggs)
set -x RANDOM_NUMBER (random 1 100)
if test $RANDOM_NUMBER -lt 5
    fastfetch --color magenta --logo windows
else if test $RANDOM_NUMBER -lt 10
    fastfetch --color magenta --logo arch
else
    fastfetch --color magenta
end
alias fastfetch='fastfetch --config none' # change default config to none
