#!/bin/sh
# The secret key lives only on the YubiKey, so a machine needs the public key and
# the card stubs that point at it before signing and SSH work.
#
# Why not run_once: the YubiKey may be absent on the first apply, and a run_once
# script that skips still counts as done. This exits early once the stubs exist.
#
# Why not `gpg --card-edit` -> fetch: the card has no public key URL set, so the
# key comes from GitHub and is checked against the pinned fingerprint.
set -eu

fpr=9700B737B52570D7B78394E52DF1A76B8DC2D6E3

gpg --list-secret-keys "$fpr" >/dev/null 2>&1 && exit 0

if ! gpg --card-status >/dev/null 2>&1; then
  echo "gpg: YubiKey not found; insert it and run chezmoi apply again" >&2
  exit 0
fi

imported=$(curl -fsSL https://github.com/m1sk9.gpg)
if ! printf '%s\n' "$imported" | gpg --with-colons --import-options show-only --import 2>/dev/null |
  grep -q "^fpr:::::::::$fpr:"; then
  echo "gpg: key from github.com/m1sk9.gpg does not match $fpr; not importing" >&2
  exit 1
fi
printf '%s\n' "$imported" | gpg --import
gpg --card-status >/dev/null
echo "$fpr:6:" | gpg --import-ownertrust
