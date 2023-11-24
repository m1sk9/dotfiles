# .config
mkdir -p "$HOME"/.config/alacritty
ln -sfvn "$HOME"/dotfiles/common/config/alacritty/alacritty.yml "$HOME"/.config/alacritty/alacritty.yml

mkdir -p "$HOME"/.config/gh
ln -sfvn "$HOME"/dotfiles/common/config/gh/config.yml "$HOME"/.config/gh/config.yml
ln -sfvn "$HOME"/dotfiles/common/config/gh/hosts.yml "$HOME"/.config/gh/hosts.yml

mkdir -p "$HOME"/.config/lazygit
ln -sfvn "$HOME"/dotfiles/common/config/lazygit/config.yml "$HOME"/.config/lazygit/config.yml

ln -sfvn "$HOME"/dotfiles/common/config/git/ignore "$HOME"/.config/ignore

# .ssh
mkdir -p "$HOME"/.ssh
ln -sfvn "$HOME"/dotfiles/common/ssh/smartcard.pub "$HOME"/.ssh/smartcard.pub

# home
ln -sfvn "$HOME"/dotfiles/common/config/git/.gitconfig "$HOME"/.gitconfig
