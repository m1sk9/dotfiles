if status is-interactive
    alias lg='lazygit'
    alias cat='bat'
    alias ls='eza'
    alias l='eza -abghHliS'
    alias find='fd'
    alias grep='rg'
    alias c='claude'
    alias h='herdr'
    alias cd='z'

    zoxide init fish | source

    # Why not 同期実行: agent はプロンプト表示前に起動している必要がなく ~14ms 待つ理由がないため
    gpg-connect-agent /bye >/dev/null 2>&1 &
    disown

    # Display fastfetch
    fastfetch --structure Title:Separator:OS:Host:Kernel:Uptime:Packages:Shell:CPU:GPU:Memory:Swap:Disk:LocalIp:Battery:PowerAdapter:Locale:Break:Break --logo none
end
