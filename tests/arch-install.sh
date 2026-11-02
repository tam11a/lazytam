#!/usr/bin/env bash
# Installs lazytam twice in a clean Arch container, then runs `lazytam doctor`.
#
#   tests/arch-install.sh [profile]     # default: laptop-server; needs Docker
#
# CI runs this directly inside an archlinux container (LAZYTAM_IN_CONTAINER=1).
# AUR packages and Claude Code are skipped: makepkg won't run as root.
set -euo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PROFILE=${1:-laptop-server}

if [[ ${LAZYTAM_IN_CONTAINER:-0} != 1 ]]; then
  exec docker run --rm -v "$REPO:/src:ro" -e LAZYTAM_IN_CONTAINER=1 archlinux:latest \
    bash /src/tests/arch-install.sh "$PROFILE"
fi

export LAZYTAM_ALLOW_ROOT=1 LAZYTAM_SKIP_AUR=1 LAZYTAM_SKIP_CLAUDE=1
mkdir -p "$HOME/.local/share"
cp -r "$REPO" "$HOME/.local/share/lazytam"
rm -rf "$HOME/.local/share/lazytam/.git"

echo "== install ($PROFILE)"
bash "$HOME/.local/share/lazytam/install.sh" --profile "$PROFILE"

echo "== install again (must be a no-op)"
bash "$HOME/.local/share/lazytam/install.sh" --profile "$PROFILE"

echo "== doctor"
export PATH=$HOME/.local/bin:$PATH
report=$(lazytam doctor 2>&1 || true)
echo "$report"
# The browser comes from the AUR, which is skipped here.
unexpected=$(grep 'FAIL' <<<"$report" | grep -v "browser: 'zen-browser'" || true)
if [[ -n $unexpected ]]; then
  echo "unexpected doctor failures:" >&2
  echo "$unexpected" >&2
  exit 1
fi
echo "arch-install: all good"
