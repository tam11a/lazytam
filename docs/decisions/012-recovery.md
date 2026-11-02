# 012. btrfs snapshots around pacman; linux-lts as a fallback kernel

- **Status:** Accepted (snapshots implemented; linux-lts planned)
- **Date:** 2026-11-03

## Context

Arch is rolling. On a box that's mostly reached remotely, a bad update has to be easy to
undo, and a bad kernel must not leave it unbootable.

## Decision

- Recommend btrfs for the base install. `core` installs snapper and snap-pac, so every
  pacman transaction is wrapped in pre/post snapshots, and enables the timeline and
  cleanup timers.
- If `/.snapshots` already exists (archinstall's layout), lazytam doesn't force snapper's
  config; it warns and links to the Arch wiki.
- Install `linux-lts` as a second boot entry (planned, FR-INS-8).

## Consequences

- Updates can be rolled back.
- Snapper may need one manual step on archinstall layouts (why NFR-5 is Partial).
- Until linux-lts is installed by lazytam, users should add it themselves.

## Alternatives considered

- **Timeshift:** more GUI-oriented; snapper + snap-pac is the Arch standard.
- **No snapshots:** unacceptable for a remote box.
