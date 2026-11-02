# 005. Modules with explicit package lists, grouped into profiles

- **Status:** Accepted
- **Date:** 2026-11-03

## Context

The same codebase has to set up a laptop used in hand, a laptop that also serves SSH, a
desktop, and a headless box, without installing anything nobody asked for.

## Decision

- Features live in **modules**: `core`, `dev`, `desktop`, `laptop`, `server`. Each has
  `packages.txt` (pacman), `aur.txt` (paru), an idempotent `setup.sh`, and `stubs/`.
- **Profiles** are presets that seed the module list on first install: `laptop`,
  `laptop-server` (default), `desktop`, `server`. After that, `modules` in `config.toml`
  is the source of truth.
- A package goes in `packages.txt` only if it's in the official repos (an unknown name
  fails the whole pacman transaction); anything uncertain goes in `aur.txt`.

## Consequences

- Every installed package is traceable to a module and a line.
- The user's machine uses `laptop-server`: full desktop plus always-on remote access.
- CI installs every `packages.txt` in a real Arch container, catching renamed packages.
- AUR packages aren't covered by CI yet (makepkg won't run as root).

## Alternatives considered

- **One big install script:** simpler, but no way to opt out of parts.
- **Interactive installer menus:** friendlier, but harder to reproduce and to test.
