#!/usr/bin/env bash
# Runs the lazytam CLI in a throwaway HOME: config, every built-in theme, wallpapers,
# starter files and re-runs. Needs bash and Python 3.11+; never touches your real config.
set -euo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
export HOME=$WORK/home LAZYTAM_PATH=$REPO
unset LAZYTAM_CONFIG LAZYTAM_STATE
mkdir -p "$HOME"

CUR=$HOME/.config/lazytam/current
lt() { bash "$REPO/bin/lazytam" "$@"; }
fail() { echo "FAIL: $*" >&2; exit 1; }
ok() { echo "ok    $*"; }

python3 "$REPO/lib/lazytam.py" init-config --profile laptop-server
ln -s "$REPO/defaults" "$HOME/.config/lazytam/defaults"

[[ $(lt config theme) == joypad ]] || fail "default theme should be joypad"
[[ $(lt config modules) == "core dev desktop laptop server" ]] || fail "laptop-server modules"
ok "config defaults"

lt theme render >/dev/null
grep -q 'col.active_border = rgb(a3a5a1)' "$CUR/hyprland.conf" || fail "joypad accent not rendered"
ok "joypad renders"

for theme in joypad paper; do
  lt theme set "$theme" >/dev/null
  [[ -e $CUR/background ]] || fail "$theme has no wallpaper"
  grep -q "^theme = \"$theme\"" "$HOME/.config/lazytam/config.toml" || fail "$theme not saved to config"
done
ok "every built-in theme sets, with a wallpaper"

lt theme set paper >/dev/null
grep -q '^color0 #2b2a28' "$CUR/kitty.conf" || fail "paper should flip terminal black to ink"
lt theme list | grep -q '^\* paper' || fail "theme list should mark paper current"
ok "light theme flips terminal black/white"

first=$(readlink "$CUR/background")
lt bg next
[[ $(readlink "$CUR/background") != "$first" ]] || fail "bg next should change the wallpaper"
ok "bg next cycles"

# shellcheck source=../lib/common.sh
source "$REPO/lib/common.sh"
for m in core desktop; do place_stubs "$REPO/modules/$m/stubs" >/dev/null; done
grep -q lazytam "$HOME/.config/hypr/hyprland.conf" || fail "hyprland starter file"
echo "# my own line" >>"$HOME/.config/hypr/hyprland.conf"
for m in core desktop; do place_stubs "$REPO/modules/$m/stubs" >/dev/null; done
grep -q "my own line" "$HOME/.config/hypr/hyprland.conf" || fail "re-run overwrote a user file"
[[ -z $(find "$HOME/.config" -name '*.pre-lazytam') ]] || fail "re-run made backups"
ok "starter files are written once and left alone"

if command -v tmux >/dev/null; then
  tmux -L lazytam-test -f "$HOME/.config/tmux/tmux.conf" new-session -d
  [[ $(tmux -L lazytam-test show -gv prefix) == C-Space ]] || fail "tmux defaults not loaded"
  tmux -L lazytam-test kill-server
  ok "tmux loads the config"
fi

echo "cli: all good"
