# CLAUDE.md

Guidance for Claude Code (and anyone new) working in this repo.

## What this is

lazytam is a Hyprland framework for Arch Linux: an installer, modules, default configs,
a theme engine and a `lazytam` CLI. It runs on the user's machine from
`~/.local/share/lazytam`. Read [docs/architecture.md](docs/architecture.md) for the full
picture before larger changes.

## Plan and decisions

[docs/README.md](docs/README.md) indexes the plan. Before larger work, read the
[roadmap](docs/roadmap.md) item you're working on and any [decision](docs/decisions/README.md)
it touches. Then keep them current, in the same change:

- Finished or started a roadmap item → update its status there and the matching
  requirement's status in [docs/requirements.md](docs/requirements.md).
- Made or changed a decision → add a record in `docs/decisions/` (template in its README).
  Don't silently contradict an accepted decision; supersede it with a new record.
- Found a new idea or gap → add it to the roadmap (and a requirement if it's a must).

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
| `docs/` | Plan (vision, requirements, roadmap, decisions) and how-it-works docs; `docs/assets/build.py` makes the README headers |

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

- Only bundle themes and art that are ours or clearly licensed. Third-party themes are
  installed with `lazytam theme install`, not copied into `themes/`. Git history before
  the removal commit still contains an unlicensed NES copy; clean the history (or start a
  fresh repo) before ever making lazytam public. See [D-021](docs/decisions/021-remove-bundled-nes.md).
- Code and docs are MIT. The name, logo, wallpapers and `docs/assets/` images are not
  ([docs/brand.md](docs/brand.md#using-the-brand), [D-020](docs/decisions/020-license.md)).
- The brand (logo, palettes, wallpapers, README glyphs) lives in the lazytam Figma file;
  see [docs/brand.md](docs/brand.md). Wallpapers are exported from Figma at 1920×1080.
- Hyprland 0.57+ reads only Lua, so `defaults/hypr/` and its templates are Lua
  ([D-022](docs/decisions/022-hyprland-lua.md)); hyprlock and hypridle still use `.conf`.
  After changing them, run `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`.
- Hyprland's window-rule syntax changes between releases, which is why
  `defaults/hypr/rules.lua` is empty. Check `hyprctl version` before adding rules.
- Nothing has run on real hardware much yet. When you change module setup, say what you
  could and couldn't verify.
