# 021. Remove the bundled NES theme

- **Status:** Accepted (supersedes [014](014-bundled-nes.md))
- **Date:** 2026-11-03

## Context

[014](014-bundled-nes.md) bundled bjarneo's NES theme so installs wouldn't depend on an
external repo. By then joypad had already become the default ([013](013-default-themes.md)),
and joypad and paper are complete: all 25 color keys (enforced by a test) and their own
wallpapers. Nothing in lazytam used the NES files, while they carried the only licensing
problem in the repo (no upstream license, a Nintendo controller wallpaper) and 1.4 MB.

## Decision

- Delete `themes/nes/`. lazytam bundles only themes and art that are its own or clearly
  licensed.
- People who want NES install it with
  `lazytam theme install https://github.com/bjarneo/omarchy-nes-theme`. The copy lands in
  `~/.config/lazytam/themes/nes` and keeps working if the repo later goes private.

## Consequences

- No install path depends on bjarneo's repo; nothing in the repo is unlicensed.
- The NES files remain in the git history of the first commits (`7f33c4e` to `0560cd7`).
  Before lazytam is ever made public, rewrite that history or publish from a fresh repo
  (roadmap R-26, NFR-26).
- `tests/cli.sh` now covers joypad and paper only.

## Alternatives considered

- **Keep it while the repo is private:** works, but adds a legal task for later and
  serves no purpose lazytam needs.
