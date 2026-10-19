#!/bin/bash
set -uo pipefail

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_INSTALL_CLEANUP=1

LOCK_DIR="${TMPDIR:-/tmp}/brew-autoupdate.lock"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  echo "$(date '+%F %T') another run is in progress, skipping"
  exit 0
fi
trap 'rmdir "$LOCK_DIR"' EXIT

status=0
run() {
  echo "$(date '+%F %T') >>> $*"
  "$@"
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    echo "$(date '+%F %T') !!! failed (exit $rc): $*"
    status=1
  fi
}

run brew update
run brew upgrade --formula
run brew upgrade --cask
run brew cleanup

echo "$(date '+%F %T') done (status=$status)"
exit "$status"
