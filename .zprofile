# Added SSH AUTH SOCK
SSH_AUTH_SOCK="$(/opt/homebrew/bin/gpgconf --list-dirs agent-ssh-socket)"

# Added by Toolbox App
export PATH="$PATH:/Users/m2en/Library/Application Support/JetBrains/Toolbox/scripts"

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

# Added JAVA_HOME
export JAVA_HOME=`/usr/libexec/java_home -v "8"`
PATH=$JAVA_HOME/bin:$PATH

# Added Deno path
export DENO_INSTALL="/Users/m2en/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
export PATH="/Users/lis2a/.deno/bin:$PATH"

# Changed config path
export XDG_CONFIG_HOME="$HOME/.config"

# nvm
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
