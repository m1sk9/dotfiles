$HOME/dotfiles/common/symlink.sh

mkdir -p "$HOME"/.config/fish
ln -sfvn "$HOME"/dotfiles/macOS/config/fish/config.fish "$HOME"/.config/fish/config.fish
ln -sfvn "$HOME"/dotfiles/macOS/config/Brewfile "$HOME"/Brewfile

# notes: gpg/gpg-agent.conf の symlink はセットしない. 事故回避のために.
