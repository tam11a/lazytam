# 002. The laptop is a dedicated coding box; gaming moves to the desktop

- **Status:** Accepted
- **Date:** 2026-11-03

## Context

The user had moved to Windows only to play Valorant. Valorant's Vanguard anti-cheat runs at
the kernel level and blocks Linux, Wine/Proton and virtual machines, and on Windows 11 it
expects Secure Boot and TPM 2.0. Keeping Valorant on the laptop meant dual booting and
signing our own bootloader with `sbctl`.

## Decision

Gaming moves to the desktop. The laptop runs Arch only and becomes a coding machine,
mostly driven over SSH from the desktop, often running Claude Code.

## Consequences

- No Windows partition, no dual boot, no Secure Boot or Vanguard constraints.
- The whole 512 GB disk and 8 GB of RAM go to development.
- The laptop needs a server profile: never sleep, ignore the lid, reachable remotely
  ([011](011-remote-access.md)).
- It should still look premium when used directly, so the desktop module stays.

## Alternatives considered

- **Dual boot Windows for Valorant.** Workable with `sbctl` and Microsoft's keys enrolled,
  but adds Secure Boot maintenance and splits a small disk. Unnecessary once gaming moved.
- **Windows with WSL2.** Rejected: WSL2 plus Windows plus Docker doesn't fit in 8 GB.
