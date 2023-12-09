# .config
mkdir -p "$HOME"/.config/alacritty
ln -sfvn "$HOME"/dotfiles/config/alacritty/alacritty.yml "$HOME"/.config/alacritty/alacritty.yml
ln -sfvn "$HOME"/dotfiles/config/alacritty/theme.yml "$HOME"/.config/alacritty/theme.yml

mkdir -p "$HOME"/.config/gh
ln -sfvn "$HOME"/dotfiles/config/gh/config.yml "$HOME"/.config/gh/config.yml
ln -sfvn "$HOME"/dotfiles/config/gh/hosts.yml "$HOME"/.config/gh/hosts.yml

mkdir -p "$HOME"/.config/lazygit
ln -sfvn "$HOME"/dotfiles/config/lazygit/config.yml "$HOME"/.config/lazygit/config.yml

mkdir -p "$HOME"/.config/git
ln -sfvn "$HOME"/dotfiles/config/git/ignore "$HOME"/.config/git/ignore

# .ssh
mkdir -p "$HOME"/.ssh
ln -sfvn "$HOME"/dotfiles/ssh/smartcard.pub "$HOME"/.ssh/smartcard.pub

# home
ln -sfvn "$HOME"/dotfiles/config/git/.gitconfig "$HOME"/.gitconfig
ln -sfvn "$HOME"/dotfiles/config/tmux/.tmux.conf "$HOME"/.tmux.conf
