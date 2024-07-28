echo ">>> Setup yay"

git clone https://aur.archlinux.org/yay-bin.git ~/yay-bin
cd ~/yay-bin
makepkg -si --noconfirm
cd ..
rm -rf ~/yay-bin

echo ">>> Install packages..."

pacman -Syu --noconfirm
pacman -S --noconfirm \
  bat \
  btop \
  exa \
  fastfetch \
  fd \
  fish \
  fzf \
  git \
  gpg \
  lazygit \
  neovim \
  ripgrep \
  starship

yay -S --noconfirm \
  topgrade-bin  \
  1password \
  alacritty-git \
  discord-canary \
  jetbrains-toolbox \
  spotify \
  tailscale-git \
  firefox-nightly \
  thunderbird-nightly-bin

echo ">>> Install mise..."

curl https://mise.run | sh

echo ">>> Install Docker..."

pacman -S docker --noconfirm
sudo systemctl enable docker
sudo systemctl restart docker

docker info


