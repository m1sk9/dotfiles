#!/bin/sh
# Why not manage ~/.claude/hooks/herdr-agent-state.sh: herdr owns it and overwrites
# it on every reinstall. The hook entry in settings.json is already deployed, and
# `install` leaves an existing entry untouched, so this only lays the script.
set -eu

herdr integration install claude
