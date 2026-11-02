# 018. Unit + CLI tests anywhere, full install in an Arch container in CI

- **Status:** Accepted
- **Date:** 2026-11-03

## Context

lazytam was built on a Windows machine before Arch was installed, and friends may not run
Arch either. We need confidence without real hardware for most changes.

## Decision

- **Unit tests** (`tests/test_render.py`) for the theme engine and config.
- **CLI test** (`tests/cli.sh`) running the real CLI in a throwaway HOME.
- **Arch container install** (`tests/arch-install.sh`): `install.sh --profile laptop-server`
  twice in `archlinux:latest`, then `lazytam doctor`, skipping the AUR and Claude Code.
- **CI** (GitHub Actions) runs lint (bash -n, shellcheck), tests on Python 3.11 and 3.13,
  and the container install on every push and pull request.
- Local development on Windows uses WSL; a VM was ruled out (Hyprland needs GPU
  acceleration, and 4 GB of 8 GB is too much to give a VM).

## Consequences

- Package-name mistakes and broken setup steps are caught before reaching a machine.
  The first CI run passed all four jobs.
- Not covered: AUR packages, anything needing a running systemd, Hyprland actually
  starting, Wi-Fi and lid behavior. Real hardware is still the final test.
- Private-repo CI uses GitHub Actions minutes (a run is about two minutes).

## Alternatives considered

- **VM testing:** slow and unrepresentative for Hyprland.
- **Real hardware only:** too slow a feedback loop for contributors.
