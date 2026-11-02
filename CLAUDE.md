# CLAUDE.md

Guidance for Claude Code (and anyone new) working in this repo.

## What this is

lazytam is a Hyprland framework for Arch Linux: an installer, modules, default configs,
a theme engine and a `lazytam` CLI. It runs on the user's machine from
`~/.local/share/lazytam`. Read [docs/architecture.md](docs/architecture.md) for the full
picture before larger changes.

## Rules that must not break

1. **Never own the user's files.** Anything under `~/.config` that the user edits is
   written once, from `modules/*/stubs/`, by `place_stubs`, and never again. Changes to
   behavior go in `defaults/` (loaded first) or `templates/` (rendered into
   `~/.config/lazytam/current/`), never into the user's files. `lazytam theme set` may
   rewrite only the `theme =` line of `config.toml`.
2. **Every setup step is idempotent.** `install.sh` and each `modules/*/setup.sh` must be
   safe to run again on a working system. Check before changing; use `write_root_file`,
   which only writes when content differs.
3. **Nothing installs unless a module lists it.** Packages live in
   `modules/<name>/packages.txt` (pacman) and `aur.txt` (paru). No Chromium or Electron
   apps by default; prefer TUIs.
4. **Don't lock people out.** Server changes (SSH, sleep, networking) must keep a working
   way in. See how `modules/server/setup.sh` only disables password SSH once a key exists.
5. **Standard library only.** `lib/lazytam.py` and `docs/assets/build.py` use Python 3.11+
   stdlib. Shell is bash with `set -euo pipefail` in entry points.
6. **LF line endings** everywhere (`.gitattributes` enforces it; scripts break on CRLF).

## Layout

| Path | What |
|---|---|
| `install.sh` | Entry point: bootstraps, writes config, runs modules, renders the theme |
| `bin/lazytam` | The CLI (bash). Subcommands are `cmd_*` functions |
| `lib/common.sh` | Shared shell helpers: `log`, `warn`, `die`, `as_root`, `write_root_file`, `enable_service`, `install_packages`, `place_stubs`, `reload_desktop` |
| `lib/lazytam.py` | Config access and the theme engine (`render`, color fallbacks, backgrounds) |
| `modules/<name>/` | `packages.txt`, `aur.txt`, `setup.sh` (sourced, has the helpers), `stubs/` |
| `defaults/` | Configs loaded before the user's (Hyprland, Waybar, kitty, tmux, shell) |
| `templates/*.tpl` | Per-app files rendered from theme colors and config settings |
| `themes/<name>/` | Built-in themes: `colors.toml` + `backgrounds/` |
| `migrations/` | One-time fixes `lazytam update` runs on existing installs |
| `tests/` | `test_render.py` (unit), `cli.sh` (fake HOME), `arch-install.sh` (container) |
| `docs/` | Architecture, modules, themes, brand; `docs/assets/build.py` makes the README headers |

## Commands

```bash
make test     # unit tests + tests/cli.sh; run before every commit
make lint     # bash -n on every script, shellcheck when available
make arch     # install.sh in an archlinux container (Docker; slow, downloads packages)
make readme   # rebuild docs/assets/header*.svg after editing build.py
```

Tests work on any Linux or WSL with Python 3.11+. `tests/cli.sh` uses a temporary HOME, so
it never touches your real config. Nothing here needs root except `make arch`'s container.

## Common changes

- **New template:** add `templates/<file>.tpl` using `{{key}}`, `{{key.strip}}` (hex
  without `#`) or `{{key.rgb}}` (`r, g, b`). Unknown keys fail loudly. Then point the app's
  stub in `modules/desktop/stubs/` at `~/.config/lazytam/current/<file>` and add a reload in
  `reload_desktop` if the app can reload live. See [docs/themes.md](docs/themes.md).
- **New theme:** `themes/<name>/colors.toml` with all 25 keys (a test checks this) and
  optional `backgrounds/N-name.png`. Set `mode = "light"` for light themes.
- **New module:** see [docs/modules.md](docs/modules.md). Add it to `PROFILES` in
  `lib/lazytam.py` only if a profile should include it by default.
- **Changing a default:** edit `defaults/`. Existing installs pick it up on `lazytam update`.
- **Something existing installs need fixed once:** write a migration, don't special-case
  the installer.

## Things to know

- `themes/nes` is an unlicensed copy of bjarneo's theme kept for private use. Never add it
  to anything public; it must be removed before the repo is ever made public.
- The brand (logo, palettes, wallpapers, README glyphs) lives in the lazytam Figma file;
  see [docs/brand.md](docs/brand.md). Wallpapers are exported from Figma at 1920×1080.
- Hyprland's window-rule syntax changes between releases, which is why
  `defaults/hypr/rules.conf` is empty. Check `hyprctl version` before adding rules.
- Nothing has run on real hardware much yet. When you change module setup, say what you
  could and couldn't verify.
