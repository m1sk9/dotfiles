read -p "Are you sure? [y/N]" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

echo

ln -sfvn $PWD/config/alacritty $HOME/.config/alacritty
ln -sfvn $PWD/config/fish/config.fish $HOME/.config/fish/config.fish
ln -sfvn $PWD/config/gh $HOME/.config/gh
ln -sfvn $PWD/config/lazygit $HOME/.config/lazygit
ln -sfvn $PWD/config/git/ignore $HOME/.config/ignore
ln -sfvn $PWD/config/nvim $HOME/.config/nvim
ln -sfvn $PWD/ssh/smartcard.pub $HOME/.ssh/smartcard.pub

ln -sfv $PWD/config/git/.gitconfig $HOME/.gitconfig
ln -sfv $PWD/config/Brewfile $HOME/Brewfile
ln -sfv $PWD/config/tmux/.tmux.conf $HOME/.tmux.conf
