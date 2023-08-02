gpg-connect-agent --quiet /bye

# setting alias
alias clone='ghq get'
alias lg='lazygit'
alias v='code'
alias cat='bat'

alias sbtss='sbt scalafixAll && sbt scalafmtAll'

alias jdk17='export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home" && PATH=$JAVA_HOME/bin:$PATH'
alias jdk8='export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home" && PATH=$JAVA_HOME/bin:$PATH'

# setting path
set -x SSH_AUTH_SOCK "$(/opt/homebrew/bin/gpgconf --list-dirs agent-ssh-socket)"
set -x PATH "$DENO_INSTALL/bin:$PATH"
set -x PATH "$HOME/.deno/bin:$PATH"
set -x PATH "$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
set -x JAVA_HOME "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
set -x DENO_INSTALL "$HOME/.deno"
set -x XDG_CONFIG_HOME "$HOME/.config"

eval "$(/opt/homebrew/bin/brew shellenv)"

fish_add_path $HOME/.cargo/env

# ------
starship init fish | source
