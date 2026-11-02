# Modules

A module is a folder in `modules/`. Users turn modules on in the `modules` list of
`~/.config/lazytam/config.toml`, and `install.sh` runs them in that order.

| Module | Installs and sets up |
|---|---|
| `core` | Shell tools (ripgrep, fd, fzf, bat, eza, zoxide, btop, tmux, neovim), zram swap, snapper on btrfs, weekly pacman cache cleanup, shell defaults, btop theme |
| `dev` | mise, lazygit, git-delta, GitHub CLI, podman + lazydocker, yazi, Claude Code |
| `desktop` | Hyprland with hyprlock/hypridle/uwsm, Waybar, mako, fuzzel, kitty, swww, PipeWire, fonts, Zen browser |
| `laptop` | power-profiles-daemon, battery charge limit, iwd + impala, Bluetooth + bluetui, Realtek 8821CE Wi-Fi fix |
| `server` | sshd + Tailscale, no sleep, lid ignored, console blanking, key-only SSH once a key exists |

## Anatomy

```
modules/<name>/
├── packages.txt   # pacman packages, one per line, # comments allowed
├── aur.txt        # packages installed with paru (also fine for repo packages)
├── setup.sh       # sourced by install.sh; must be idempotent
└── stubs/         # starter files copied to ~/.config/<same path>, once
```

Every file is optional.

### packages.txt and aur.txt

Put a package in `packages.txt` only if it's in the official repos, because pacman fails
the whole install on an unknown name. When unsure, use `aur.txt`; paru installs repo
packages too. CI installs every `packages.txt` in a real Arch container, so a wrong name
fails there first.

### setup.sh

`setup.sh` is sourced in a subshell with `lib/common.sh` loaded. Use these helpers:

| Helper | Use it to |
|---|---|
| `log`, `warn`, `die` | Print progress, warnings, fatal errors |
| `as_root cmd…` | Run as root (sudo, or directly in containers) |
| `write_root_file PATH <<EOF` | Write a system file only if its content changed |
| `enable_service unit…` | `systemctl enable` (with `--now` when systemd is running) |
| `systemd_running` | Skip things that need a live systemd (containers) |
| `lt_config key` | Read a value from `config.toml` |
| `module_enabled name` | Check whether another module is on |

Rules:

- **Idempotent.** Check before you change. Running twice must be a no-op.
- **Name system files** `90-lazytam-<what>` so people can find and remove them.
- **Only write your own system files.** If another tool already manages something
  (NetworkManager, say), configure that tool instead of replacing it, like
  `modules/laptop/setup.sh` does.
- **Never lock people out.** Anything touching SSH, networking or login needs a safe path,
  and a `warn` that says what's left for the user to do.
- **No user files.** Starter files go in `stubs/`; don't write to `~/.config/<app>` from
  `setup.sh`. (Appending one `source` line to `~/.bashrc`, as `core` does, is the exception.)

### stubs/

Files here are copied to `~/.config/<same path>` the first time a module runs, with
`@HOME@` replaced by the user's home. A stub must contain the word `lazytam`, which is how
`place_stubs` and `lazytam doctor` recognise it. If a non-lazytam file already exists, it's
moved to `<file>.pre-lazytam` first.

A good stub loads lazytam's layers, then leaves a clearly marked place for overrides:

```ini
# Your kitty config (lazytam). Defaults and theme load first; add overrides below.
include @HOME@/.config/lazytam/defaults/kitty/kitty.conf
include @HOME@/.config/lazytam/current/kitty.conf

# --- your overrides ---
```

## Adding a module

1. Create `modules/<name>/` with whatever files it needs.
2. Test with `make arch`, adding the module to the profile in `tests/arch-install.sh` if it
   should be covered in CI.
3. Add it to a profile in `PROFILES` (`lib/lazytam.py`) only if most people on that profile
   want it. Otherwise users add it to their `modules` list themselves.
4. Add a row to the table at the top of this file.
