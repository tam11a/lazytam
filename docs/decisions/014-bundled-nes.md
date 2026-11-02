# 014. Bundle bjarneo's NES theme, for private use only

- **Status:** Accepted
- **Date:** 2026-11-03

## Context

The user wants the NES theme available even if its repo goes private, and doesn't want
installs to depend on an external repo. The repo
([bjarneo/omarchy-nes-theme](https://github.com/bjarneo/omarchy-nes-theme)) has no license
(GitHub reports `license: null`), so all rights stay with its author, and its controller
wallpaper depicts Nintendo's NES controller.

## Decision

- Copy `colors.toml`, `icons.theme` and `backgrounds/` into `themes/nes/`, pinned to
  upstream commit `4ab5a95` (2026-08-30). Skip its README and preview image.
- Record the source and terms in `themes/nes/SOURCE.md`.
- Keep the lazytam repo private while `themes/nes` is in it.
- The installer doesn't download any theme; joypad is the default.

## Consequences

- `lazytam theme set nes` works offline.
- **Before lazytam is made public or shared beyond trusted friends, `themes/nes` must be
  removed** (NFR-26), unless bjarneo adds a license that allows it.

## Alternatives considered

- **Download at install time:** breaks if the repo disappears; was briefly the approach.
- **Ask bjarneo to add a license:** still possible, and the clean long-term fix.
