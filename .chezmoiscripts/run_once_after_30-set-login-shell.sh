#!/bin/sh
set -eu

fish=/opt/homebrew/bin/fish
[ "$(dscl . -read "$HOME" UserShell | awk '{print $2}')" = "$fish" ] && exit 0

grep -qx "$fish" /etc/shells || echo "$fish" | sudo tee -a /etc/shells >/dev/null
sudo chsh -s "$fish" "$USER"
