# .config
mkdir -p "$HOME"/.config/alacritty
ln -sfvn "$HOME"/dotfiles/config/alacritty/alacritty.toml "$HOME"/.config/alacritty/alacritty.toml
ln -sfvn "$HOME"/dotfiles/config/alacritty/theme.toml "$HOME"/.config/alacritty/theme.toml

mkdir -p "$HOME"/.config/gh
ln -sfvn "$HOME"/dotfiles/config/gh/config.yml "$HOME"/.config/gh/config.yml
ln -sfvn "$HOME"/dotfiles/config/gh/hosts.yml "$HOME"/.config/gh/hosts.yml

mkdir -p "$HOME"/.config/lazygit
ln -sfvn "$HOME"/dotfiles/config/lazygit/config.yml "$HOME"/.config/lazygit/config.yml

mkdir -p "$HOME"/.config/git
ln -sfvn "$HOME"/dotfiles/config/git/ignore "$HOME"/.config/git/ignore

mkdir -p "$HOME"/.config/fish
ln -sfvn "$HOME"/dotfiles/config/fish/config.fish "$HOME"/.config/fish/config.fish

# home
ln -sfvn "$HOME"/dotfiles/config/git/.gitconfig "$HOME"/.gitconfig
ln -sfvn "$HOME"/dotfiles/config/tmux/.tmux.conf "$HOME"/.tmux.conf
ln -sfvn "$HOME"/dotfiles/config/Brewfile "$HOME"/Brewfile
