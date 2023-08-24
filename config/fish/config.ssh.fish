# setting alias
alias lg='lazygit'
alias ld='lazydocker'
alias cat='bat'
alias d='docker'

# setting path
set -U fish_user_paths $fish_user_paths $HOME/.cargo/bin

# ------

starship init fish | source
