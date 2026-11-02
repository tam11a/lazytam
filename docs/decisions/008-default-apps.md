# 008. TUI-first defaults, no Chromium

- **Status:** Accepted
- **Date:** 2026-11-03

## Context

The user prefers TUIs, uses Zen as their browser, and dislikes Chromium-based software,
including the many Electron apps Omarchy installs.

## Decision

| Role | Default | Why |
|---|---|---|
| Terminal | kitty | Fast, themeable with includes, live reload |
| Launcher | fuzzel | Light, dmenu mode for menus |
| Browser | Zen (`zen-browser-bin`, AUR) | User's browser; Firefox-based |
| Editor | Neovim | |
| Files | yazi | TUI |
| Git / containers | lazygit / lazydocker on podman | TUIs |
| Wi-Fi / Bluetooth / audio | impala / bluetui / wiremix | TUIs, opened from Waybar |
| Monitor | btop | |
| Notifications | mako | |
| Wallpaper | swww | Animated transitions |
| Bar | Waybar | |

Every app is swappable in `config.toml`. No Chromium or Electron app is installed by
default.

## Consequences

- A lighter desktop that fits 8 GB.
- Some apps people expect (VS Code, Discord, Obsidian, Spotify desktop) aren't included;
  users add them themselves. TUI alternatives: Neovim, obsidian.nvim, spotify_player.
- Several TUIs come from the AUR, so they're not covered by CI yet.

## Alternatives considered

- **Omarchy's defaults** (Alacritty, Walker, Chromium web apps): rejected for the reasons
  above. Walker and other terminals remain supported choices.
