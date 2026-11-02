# 011. Remote access through SSH keys and Tailscale; never sleep

- **Status:** Accepted
- **Date:** 2026-11-03

## Context

The laptop is driven from the desktop, including Claude Code sessions, often with the lid
closed. Remote access has to be reliable and safe, and it must be impossible to lock
ourselves out with a bad change.

## Decision

The `server` module:

- Enables sshd and Tailscale (no port forwarding, no public ports).
- Ignores the lid, masks all sleep targets, blanks the console after a minute.
- Turns off password and keyboard-interactive SSH, and root login, **only once**
  `~/.ssh/authorized_keys` has a key. Until then it warns.
- Work runs in tmux so sessions survive disconnects. Claude Code runs there, or through
  the Claude desktop app's SSH sessions.

## Consequences

- Safe to apply over SSH.
- Battery health needs care when the laptop stays plugged in: the laptop module caps
  charging at 80%.
- Coding agents still run as the main user; a dedicated low-privilege user is planned
  (FR-SRV-6, NFR-20).

## Alternatives considered

- **Port forwarding / public SSH:** unnecessary with Tailscale, and riskier.
- **Wake-on-LAN and sleep:** the Realtek card's wake support is unreliable, and there's no
  Ethernet port.
