#!/usr/bin/env bash
# Hyprland 0.57 only reads hyprland.lua, so give existing installs the Lua starter file.
# A hyprland.lua Hyprland generated itself is kept as hyprland.lua.pre-lazytam.
set -euo pipefail
source "$LAZYTAM_PATH/lib/common.sh"

module_enabled desktop || exit 0
place_stubs "$LAZYTAM_PATH/modules/desktop/stubs"

conf=$HOME/.config/hypr/hyprland.conf
if [[ -f $conf ]] && sed -n '/your overrides/,$p' "$conf" | sed 1d | grep -qvE '^[[:space:]]*(#|$)'; then
  warn "$conf has your overrides, but Hyprland no longer reads it. Port them to ~/.config/hypr/hyprland.lua"
fi
