# How lazytam works

lazytam has three layers, loaded in this order. Later layers win.

| Layer | Lives in | Owned by | Changes when |
|---|---|---|---|
| **Defaults** | `~/.local/share/lazytam/defaults` (this repo) | lazytam | `lazytam update` |
| **Rendered** | `~/.config/lazytam/current/` | lazytam | `lazytam theme set/render` |
| **Yours** | `~/.config/<app>/…`, `~/.config/lazytam/config.toml` | you | only when you edit them |

Each app's file in `~/.config` is a small starter file that loads the first two layers and
then leaves room for your overrides. For Hyprland:

```ini
# ~/.config/hypr/hyprland.conf  (yours)
source = ~/.config/lazytam/current/apps.conf        # $terminal, $launcher… from config.toml
source = ~/.config/lazytam/defaults/hypr/hyprland.conf
source = ~/.config/lazytam/current/hyprland.conf    # theme colors
monitor = , preferred, auto, 1
# --- your overrides ---
```

`~/.config/lazytam/defaults` is a symlink into the repo, so starter files can use one
stable path.

## Install

`install.sh --profile <name>`:

1. Checks it's on Arch and not running as root (`LAZYTAM_ALLOW_ROOT=1` overrides, for containers).
2. Upgrades the system and installs `git` and `python`.
3. Writes `~/.config/lazytam/config.toml` from `defaults/config.toml` **only if it doesn't
   exist**, with `modules` set from the profile.
4. Links `~/.config/lazytam/defaults` and `~/.local/bin/lazytam` into the repo.
5. For each module in `config.toml`, in order: install `packages.txt` with pacman, install
   `aur.txt` with paru, copy `stubs/` into `~/.config` (once), then source `setup.sh`.
6. On a fresh install, marks every migration as already applied.
7. Renders the theme.

Running it again re-checks every step and changes only what's missing.

## Themes and rendering

`lib/lazytam.py render <theme>`:

1. Finds the theme in `~/.config/lazytam/themes/` (installed) or `themes/` (built in).
2. Loads `colors.toml`, checks the hex values, and fills in any missing keys from related
   ones (for example `bright_red` falls back to `red`). On light themes it swaps the
   terminal's black and white slots.
3. Builds a context: all colors, all `config.toml` settings, and derived values like
   `terminal_exec` and `launcher_dmenu`.
4. Renders every `templates/*.tpl` into a staging folder, copies in any finished per-app
   files the theme ships (unless they point at Omarchy's install paths), then swaps the
   staging folder in as `~/.config/lazytam/current/` in one rename.
5. Points `current/background` at the theme's first wallpaper.

`bin/lazytam` then reloads whatever is running: `hyprctl reload`, Waybar (`SIGUSR2`),
`makoctl reload`, kitty (`SIGUSR1`) and the wallpaper through swww.

Details and the color keys are in [themes.md](themes.md).

## Updates

`lazytam update`:

1. `git pull --ff-only` in the repo.
2. Runs any new scripts in `migrations/`, once each, recording them in
   `~/.local/state/lazytam/migrations.done`.
3. Upgrades the system (paru if present, otherwise pacman). On btrfs, `snap-pac` takes
   snapshots before and after.
4. Installs packages that enabled modules have gained since the last update.
5. Re-renders the theme and reloads the desktop.

## Where state lives

| Path | Contents |
|---|---|
| `~/.config/lazytam/config.toml` | Your settings |
| `~/.config/lazytam/themes/` | Themes from `lazytam theme install` |
| `~/.config/lazytam/current/` | Rendered files, safe to delete (re-render recreates it) |
| `~/.local/state/lazytam/` | Wallpaper position, applied migrations |
| `~/.local/share/lazytam/` | The repo |

## Files the installer writes outside your home

All are lazytam-owned and safe to delete if you remove a module.

| File | Module |
|---|---|
| `/etc/systemd/zram-generator.conf` (only if missing) | core |
| `/etc/udev/rules.d/90-lazytam-battery.rules` | laptop |
| `/etc/iwd/main.conf` or `/etc/NetworkManager/conf.d/90-lazytam-wifi.conf` | laptop |
| `/etc/modprobe.d/90-lazytam-rtw88.conf` (Realtek 8821CE only) | laptop |
| `/etc/systemd/logind.conf.d/90-lazytam-server.conf` | server |
| `/etc/tmpfiles.d/90-lazytam-consoleblank.conf` | server |
| `/etc/ssh/sshd_config.d/90-lazytam.conf` (only once a key exists) | server |
