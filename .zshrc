gpg-connect-agent --quiet /bye

if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light mollifier/anyframe
zinit light sindresorhus/pure

bindkey '^r' anyframe-widget-execute-history
bindkey '^g' anyframe-widget-cd-ghq-repository
bindkey '^t' anyframe-widget-tmux-attach
bindkey '^b' anyframe-widget-checkout-git-branch

alias clone='ghq get'
alias lg='lazygit'
alias g='lazygit'
alias vsc='code ./'
alias v='code ./'
alias cat='bat'

alias sbtss='sbt scalafixAll && sbt scalafmtAll'

alias jdk17='export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home" && PATH=$JAVA_HOME/bin:$PATH'
alias jdk8='export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home" && PATH=$JAVA_HOME/bin:$PATH'

HISTFILE=~/.zsh-history
HISTSIZE=100000
SAVEHIST=1000000

setopt AUTO_CD

setopt AUTO_PARAM_KEYS
