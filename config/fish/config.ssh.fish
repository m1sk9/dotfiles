# setting alias
alias lg='lazygit'
alias ld='lazydocker'
alias cat='bat'
alias d='docker'

# setting path
set -U fish_user_paths $fish_user_paths $HOME/.cargo/bin
set -x PATH "$HOME/.local/bin"
set -x PATH "/usr/bin:/bin"

# ------

starship init fish | source
