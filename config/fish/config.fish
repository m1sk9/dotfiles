# setting alias
alias clone='ghr clone'
alias lg='lazygit'
alias ld='lazydocker'
alias v='code ./'
alias cat='bat'
alias find='fd'
alias g='git'
alias d='docker'

alias c='cargo'

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
set -x GHR_ROOT "$HOME/project"
set -x STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"
set -U fish_user_paths $fish_user_paths $HOME/.cargo/bin

set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH

starship init fish | source
gpg-connect-agent /bye
