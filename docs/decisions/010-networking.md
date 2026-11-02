# 010. iwd + impala for Wi-Fi, unless NetworkManager is already in use

- **Status:** Accepted
- **Date:** 2026-11-03

## Context

The Wi-Fi TUI we want (impala) talks to iwd. The laptop's Realtek RTL8821CE is known to
drop connections because of power saving and ASPM. Users' base installs may already use
NetworkManager.

## Decision

- If NetworkManager is enabled, configure it (power saving off) and leave it in charge.
- Otherwise use iwd with its built-in DHCP and systemd-resolved, with power saving off.
- When an RTL8821CE is detected, add the rtw88 quirks
  (`disable_lps_deep`, `disable_aspm`).

## Consequences

- Stable Wi-Fi on the target hardware, at some battery cost.
- impala doesn't work on NetworkManager systems (use `nmtui` there); lazytam says so.
- Switching to iwd mid-install can drop a connection managed by systemd-networkd; this is
  why NFR-4 is Partial. A guard for that case is on the roadmap.
- A USB-C Ethernet adapter is the recommended fix if Wi-Fi is still unreliable for SSH.

## Alternatives considered

- **NetworkManager everywhere:** works, but no TUI we like and heavier.
