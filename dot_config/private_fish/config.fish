# setting alias
alias clone='ghr clone'
alias lg='lazygit'
alias ld='lazydocker'
alias cat='bat'
alias find='fd'

alias c='code-insiders'
alias v='nvim'

alias jdk21='set -x JAVA_HOME "/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home"'
alias jdk17='set -x JAVA_HOME "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"'
alias jdk8='set -x JAVA_HOME "/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home"'

# setting path
set -x PATH "$DENO_INSTALL/bin:$PATH"
set -x PATH "$HOME/.deno/bin:$PATH"
set -x PATH "$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
set -x PATH "$PATH:/usr/local/bin"

# setting environment variables
set -x SSH_AUTH_SOCK "$(/opt/homebrew/bin/gpgconf --list-dirs agent-ssh-socket)"
## Fucking Gradle
set -x JAVA_HOME "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
set -x DENO_INSTALL "$HOME/.deno"
set -x XDG_CONFIG_HOME "$HOME/.config"
set -x GHR_ROOT "$HOME/projects"
set -x STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"
set -U fish_user_paths $fish_user_paths $HOME/.cargo/bin

eval "$(/opt/homebrew/bin/brew shellenv)"

starship init fish | source

gpg-connect-agent /bye
