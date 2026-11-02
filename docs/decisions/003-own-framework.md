# 003. Build our own framework instead of using HyDE or Omarchy

- **Status:** Accepted
- **Date:** 2026-11-03

## Context

The user loves Hyprland but kept getting lost between HyDE and Omarchy. Both take over the
Hyprland config, so it's unclear which files are yours and what an update will overwrite.
Omarchy also installs many apps the user doesn't want, a lot of them Chromium- or
Electron-based, and is hard to customise. HyDE is mostly about looks. The user still
wanted the premium look these frameworks give, and liked Omarchy's theme ecosystem
(especially the NES theme).

## Decision

Build lazytam: a small framework of our own that borrows the good ideas (one-command
install, themes, an update command, a menu) and avoids the takeover.

## Consequences

- We own the maintenance, so lazytam stays small on purpose.
- We can enforce our own rules: never write user files ([004](004-layered-config.md)),
  explicit packages ([005](005-modules-and-profiles.md)), TUI-first apps ([008](008-default-apps.md)).
- Reusing Omarchy's theme format keeps its theme ecosystem available ([007](007-theme-format.md)).

## Alternatives considered

- **Omarchy.** Polished and well maintained, but owns your config and ships apps we'd
  have to remove.
- **HyDE.** Great theming, but its scripts regenerate configs and it's heavier than
  needed for a mostly-headless box.
- **Plain dotfiles, no framework.** Full control, but no themes, no update path, and every
  friend would have to start over.
