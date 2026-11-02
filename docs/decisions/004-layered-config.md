# 004. Three config layers; never write to user files after install

- **Status:** Accepted
- **Date:** 2026-11-03

## Context

The main complaint about existing frameworks ([003](003-own-framework.md)) is losing track
of which files are yours. lazytam needs a structure where updates are always safe and the
user's edits always win.

## Decision

Three layers, loaded in order, later ones winning:

1. **Defaults** in the repo (`defaults/`), reached through `~/.config/lazytam/defaults`.
2. **Rendered** files in `~/.config/lazytam/current/` (theme colors, the app list).
3. **Yours**: `~/.config/<app>/…` starter files and `config.toml`.

Starter files are copied from `modules/*/stubs/` once. After that lazytam never writes to
them. The only exceptions: `lazytam theme set` rewrites the `theme =` line of
`config.toml`, and `core` appends one `source` line to `~/.bashrc`.

## Consequences

- Updates (`git pull`) can never clobber user edits.
- New defaults reach existing installs automatically, because the user's files only
  include them.
- Apps must support including other files. Where they don't (btop), lazytam uses a symlink
  to a rendered file instead.
- Changing what a starter file looks like doesn't reach existing installs. If that's ever
  needed, it goes through a migration that asks or backs up first.

## Alternatives considered

- **Generate whole config files** (HyDE-style): simplest to build, but overwrites edits.
- **Patch user files in place:** fragile, and the exact thing users complained about.
