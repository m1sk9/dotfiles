read -p "Are you sure? [y/N]" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

sudo apt update
sudo apt full-upgrade
sudo apt autoremove

sudo apt install bat
sudo apt install fish

export LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[0-35.]+')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit ; sudo install lazygit /usr/local/bin

curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

curl -sS https://starship.rs/install.sh | sh

ln -sfvn $PWD/config/fish/config.ssh.fish $HOME/.config/fish/config.fish
ln -sfv $PWD/config/git/.gitconfig $HOME/.gitconfig

sudo chsh -s /usr/bin/fish

fish
