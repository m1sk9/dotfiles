#!/bin/sh
# get.chezmoi.io leaves a copy in ~/.local/bin, which precedes /opt/homebrew/bin
# in fish's PATH and would shadow the Homebrew build that `brew upgrade` updates.
set -eu

[ -x /opt/homebrew/bin/chezmoi ] && rm -f "$HOME/.local/bin/chezmoi"
exit 0
