# .config
mkdir -p "$HOME"/.config/alacritty
ln -sfvn "$HOME"/dotfiles/alacritty/alacritty.toml "$HOME"/.config/alacritty/alacritty.toml
ln -sfvn "$HOME"/dotfiles/alacritty/theme.toml "$HOME"/.config/alacritty/theme.toml

mkdir -p "$HOME"/.config/gh
ln -sfvn "$HOME"/dotfiles/gh/config.yml "$HOME"/.config/gh/config.yml
ln -sfvn "$HOME"/dotfiles/gh/hosts.yml "$HOME"/.config/gh/hosts.yml

mkdir -p "$HOME"/.config/lazygit
ln -sfvn "$HOME"/dotfiles/lazygit/config.yml "$HOME"/.config/lazygit/config.yml

mkdir -p "$HOME"/.config/git
ln -sfvn "$HOME"/dotfiles/git/ignore "$HOME"/.config/git/ignore

mkdir -p "$HOME"/.config/fish
ln -sfvn "$HOME"/dotfiles/fish/config.fish "$HOME"/.config/fish/config.fish

# home
ln -sfvn "$HOME"/dotfiles/git/.gitconfig "$HOME"/.gitconfig
ln -sfvn "$HOME"/dotfiles/Brewfile "$HOME"/Brewfile
