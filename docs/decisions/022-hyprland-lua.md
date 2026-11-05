# 022. Configure Hyprland in Lua

- **Status:** Accepted
- **Date:** 2026-11-05

## Context

Hyprland 0.57 removed support for `hyprland.conf`. On a real install, Hyprland 0.57.1 ignored
lazytam's starter file and generated its own `hyprland.lua`, so the desktop ran with stock
settings: no bar, no wallpaper, no theme colors, no lazytam keybinds. TUI apps still looked
right because they read their own rendered files.

## Decision

- Port `defaults/hypr/`, the Hyprland templates and the starter file to Lua, keeping the same
  layers: defaults, then theme colors, then the user's overrides.
- Load the layers with `require` and full paths. Defaults read app settings from a rendered
  `current/apps.lua`.
- Keep `hyprlock.conf` and `hypridle.conf`, since those tools still use the old format.
- Existing installs get the new starter file from a migration, which keeps any
  `hyprland.lua` it replaces as `hyprland.lua.pre-lazytam`.
- Add `~/.local/bin` to `PATH` from `env.lua`. In a uwsm session Hyprland didn't have it, so
  anything calling `lazytam` failed.

## Consequences

- lazytam now needs Hyprland 0.55 or later, the first release with Lua config.
- Overrides in an old `hyprland.conf` stop applying. The migration warns when it finds any,
  and they have to be ported by hand.
- Per-app `hyprland.conf` files shipped by older Omarchy themes are no longer used, because
  the rendered file they would replace is now `hyprland.lua`.

## Alternatives considered

- **Pin Hyprland to 0.56:** works for now, but holds back a rolling-release system and only
  delays the port.
