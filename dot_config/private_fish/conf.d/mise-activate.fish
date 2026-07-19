# Why not shims 常用: 対話シェルでは cd フックによる env/バージョン切替が必要なため
if status is-interactive
    /opt/homebrew/opt/mise/bin/mise activate fish | source
else
    # Why not activate: 非対話はツール解決さえできればよく，shims 追加は ~0ms のため
    fish_add_path --global --path $HOME/.local/share/mise/shims
end
