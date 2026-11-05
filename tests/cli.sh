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
# A fake HOME doesn't isolate the session: keep tests away from a real desktop's settings and apps.
gsettings() { :; }
pgrep() { return 1; }
export -f gsettings pgrep

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
grep -q 'active_border = "rgb(a3a5a1)"' "$CUR/hyprland.lua" || fail "joypad accent not rendered"
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
grep -q lazytam "$HOME/.config/hypr/hyprland.lua" || fail "hyprland starter file"
echo "-- my own line" >>"$HOME/.config/hypr/hyprland.lua"
for m in core desktop; do place_stubs "$REPO/modules/$m/stubs" >/dev/null; done
grep -q "my own line" "$HOME/.config/hypr/hyprland.lua" || fail "re-run overwrote a user file"
[[ -z $(find "$HOME/.config" -name '*.pre-lazytam') ]] || fail "re-run made backups"
ok "starter files are written once and left alone"

# An install from before the Lua port: Hyprland generated its own hyprland.lua.
echo "-- stock config" >"$HOME/.config/hypr/hyprland.lua"
bash "$REPO/migrations/202611051200-hyprland-lua.sh" >/dev/null 2>&1
grep -q lazytam "$HOME/.config/hypr/hyprland.lua" || fail "migration did not place the Lua starter file"
grep -q "stock config" "$HOME/.config/hypr/hyprland.lua.pre-lazytam" || fail "migration did not back up hyprland.lua"
ok "migration replaces a generated hyprland.lua and keeps a backup"

zen=$HOME/.config/zen/test.profile
mine=$HOME/.config/zen/mine.profile
mkdir -p "$zen" "$mine/chrome"
touch "$zen/prefs.js" "$mine/prefs.js"
echo "/* my own css */" >"$mine/chrome/userChrome.css"
lt theme render >/dev/null 2>&1
lt theme render >/dev/null 2>&1
grep -q "current/zen.css" "$zen/chrome/userChrome.css" || fail "Zen profile doesn't load the theme"
[[ $(wc -l <"$zen/user.js") -eq 1 ]] || fail "Zen user.js should get one line, once"
[[ $(cat "$mine/chrome/userChrome.css") == "/* my own css */" ]] || fail "overwrote a user's userChrome.css"
grep -q -- "--zen-branding-bg: #" "$CUR/zen.css" || fail "Zen colors not rendered"
ok "Zen profiles follow the theme and keep a user's own css"

if command -v tmux >/dev/null; then
  tmux -L lazytam-test -f "$HOME/.config/tmux/tmux.conf" new-session -d
  [[ $(tmux -L lazytam-test show -gv prefix) == C-Space ]] || fail "tmux defaults not loaded"
  tmux -L lazytam-test kill-server
  ok "tmux loads the config"
fi

echo "cli: all good"
