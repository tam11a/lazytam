#!/usr/bin/env bash
# lazytam installer. Safe to re-run: every step checks before it changes anything.
#
#   git clone <your-repo> ~/.local/share/lazytam
#   bash ~/.local/share/lazytam/install.sh --profile laptop-server
set -euo pipefail

LAZYTAM_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$LAZYTAM_PATH/lib/common.sh"

profile=laptop-server
modules=()

usage() {
  cat <<'EOF'
usage: install.sh [--profile NAME] [--modules "core dev ..."]

profiles:
  laptop          core dev desktop laptop
  laptop-server   core dev desktop laptop server   (default)
  desktop         core dev desktop
  server          core dev server

The profile only seeds ~/.config/lazytam/config.toml on first install.
After that, edit `modules` there and re-run this script.

env: LAZYTAM_SKIP_AUR=1  LAZYTAM_SKIP_CLAUDE=1  LAZYTAM_ALLOW_ROOT=1
EOF
}

while (($#)); do
  case $1 in
    --profile) profile=$2; shift 2 ;;
    --modules) read -ra modules <<<"$2"; shift 2 ;;
    -h | --help) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
  esac
done

[[ -f /etc/arch-release ]] || die "lazytam needs Arch Linux"
if [[ $EUID -eq 0 && ${LAZYTAM_ALLOW_ROOT:-0} != 1 ]]; then
  die "run as your normal user (it uses sudo where needed)"
fi

log "bootstrapping (git, python)"
as_root pacman -Syu --needed --noconfirm git python

log "config"
lt_py init-config --profile "$profile" ${modules[@]:+--modules "${modules[@]}"}
mkdir -p "$LAZYTAM_CONFIG/themes" "$LAZYTAM_STATE" "$HOME/.local/bin"
ln -sfn "$LAZYTAM_PATH/defaults" "$LAZYTAM_CONFIG/defaults"
chmod +x "$LAZYTAM_PATH/bin/lazytam"
ln -sfn "$LAZYTAM_PATH/bin/lazytam" "$HOME/.local/bin/lazytam"
log "modules: $(enabled_modules)"

for m in $(enabled_modules); do
  dir="$LAZYTAM_PATH/modules/$m"
  [[ -d $dir ]] || die "unknown module '$m' in $LAZYTAM_CONFIG/config.toml"
  log "module: $m"
  install_packages "$dir/packages.txt"
  install_aur_packages "$dir/aur.txt"
  place_stubs "$dir/stubs"
  if [[ -f $dir/setup.sh ]]; then
    # shellcheck source=/dev/null
    (source "$dir/setup.sh")
  fi
done

# A fresh install already matches the latest layout, so skip every migration.
if [[ ! -f $LAZYTAM_STATE/migrations.done ]]; then
  find "$LAZYTAM_PATH/migrations" -name '*.sh' -printf '%f\n' 2>/dev/null | sort >"$LAZYTAM_STATE/migrations.done"
fi

log "rendering theme"
lt_py theme-render

log "done"
cat <<EOF

  lazytam is installed. Next:
    - open a new shell (or: source ~/.bashrc) so ~/.local/bin is on PATH
    - lazytam doctor
EOF
if module_enabled desktop; then
  echo "    - start the desktop from a TTY: uwsm start hyprland.desktop"
fi
if module_enabled server; then
  echo "    - join your tailnet: sudo tailscale up"
fi
echo
