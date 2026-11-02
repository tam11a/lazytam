# 001. Arch Linux + Hyprland, not macOS

- **Status:** Accepted
- **Date:** 2026-11-03

## Context

The machine is an ASUS VivoBook S15 (M533IA): Ryzen 7 4700U, integrated Radeon, 8 GB RAM,
Realtek RTL8821CE Wi-Fi. The question was which OS makes it the best software engineering
machine: macOS (a Hackintosh) or Arch Linux with Hyprland.

## Decision

Arch Linux with Hyprland.

## Consequences

- AMD graphics work out of the box (Mesa is in the kernel and repos), which is exactly
  what Hyprland runs best on.
- A tiling Wayland session idles around 1 GB, leaving most of the 8 GB for builds and agents.
- Native Docker/podman, current toolchains and the AUR.
- We carry the maintenance of a rolling distro; see [012](012-recovery.md) for how we
  limit the risk.

## Alternatives considered

- **macOS (Hackintosh).** Rejected: no supported driver for AMD laptop graphics, the
  Realtek card is unsupported, Apple announced macOS 26 Tahoe as the last Intel release
  (so no future updates), and it breaks Apple's license.
- **Fedora (KDE/GNOME).** A lower-maintenance option, but the user has years of Arch +
  Hyprland and wanted to keep it.
