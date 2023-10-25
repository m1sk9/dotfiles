# setting alias
alias clone='ghq get'
alias lg='lazygit'
alias ld='lazydocker'
alias v='code ./'
alias cat='bat'
alias g='git'
alias d='docker'

alias sbtss='sbt scalafixAll && sbt scalafmtAll'

alias jdk21='set -x JAVA_HOME "/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home"'
alias jdk17='set -x JAVA_HOME "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"'
alias jdk8='set -x JAVA_HOME "/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home"'

# setting path
set -x SSH_AUTH_SOCK "$(/opt/homebrew/bin/gpgconf --list-dirs agent-ssh-socket)"
set -x PATH "$DENO_INSTALL/bin:$PATH"
set -x PATH "$HOME/.deno/bin:$PATH"
set -x PATH "$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
set -x PATH "$PATH:/usr/local/bin"
set -x JAVA_HOME "/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home"
set -x DENO_INSTALL "$HOME/.deno"
set -x XDG_CONFIG_HOME "$HOME/.config"
set -U fish_user_paths $fish_user_paths $HOME/.cargo/bin

eval "$(/opt/homebrew/bin/brew shellenv)"

# ------

starship init fish | source

gpg-connect-agent /bye

# ------

function nvm
    bass source (brew --prefix nvm)/nvm.sh --no-use ';' nvm $argv
end

set -x NVM_DIR ~/.nvm
nvm use default --silent
