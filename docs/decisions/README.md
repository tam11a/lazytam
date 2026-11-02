# Decisions

A record of every significant decision: what we chose, why, and what it rules out. When
you're about to change one of these, read it first; if you still want to change it, write
a new record that supersedes it.

| # | Decision | Area | Status |
|---|---|---|---|
| [001](001-arch-hyprland.md) | Arch Linux + Hyprland, not macOS | Platform | Accepted |
| [002](002-dedicated-coding-laptop.md) | The laptop is a dedicated coding box; gaming moves to the desktop | Platform | Accepted |
| [003](003-own-framework.md) | Build our own framework instead of using HyDE or Omarchy | Architecture | Accepted |
| [004](004-layered-config.md) | Three config layers; never write to user files after install | Architecture | Accepted |
| [005](005-modules-and-profiles.md) | Modules with explicit package lists, grouped into profiles | Architecture | Accepted |
| [006](006-bash-and-python.md) | Bash for the CLI and installer, Python stdlib for the theme engine | Architecture | Accepted |
| [007](007-theme-format.md) | Omarchy's `colors.toml` format, rendered through templates | Theming | Accepted |
| [008](008-default-apps.md) | TUI-first defaults, no Chromium; kitty, fuzzel, Zen, yazi | Desktop | Accepted |
| [009](009-session-and-idle.md) | Start Hyprland on demand with uwsm; lock but never suspend | Desktop | Accepted |
| [010](010-networking.md) | iwd + impala for Wi-Fi, unless NetworkManager is already in use | Hardware | Accepted |
| [011](011-remote-access.md) | Remote access through SSH keys and Tailscale; never sleep | Server | Accepted |
| [012](012-recovery.md) | btrfs snapshots around pacman; linux-lts as a fallback kernel | Reliability | Accepted (lts planned) |
| [013](013-default-themes.md) | joypad (dark, default) and paper (light) are lazytam's own themes | Theming | Accepted |
| [014](014-bundled-nes.md) | Bundle bjarneo's NES theme, for private use only | Theming / legal | Superseded by 021 |
| [015](015-brand.md) | Figma is the brand's source of truth; the logo is a dwindle layout | Brand | Accepted |
| [016](016-wallpapers.md) | Wallpapers are Figma components tied to theme variables | Brand | Accepted |
| [017](017-readme-header.md) | The README header is an animated SVG generated from outlined glyphs | Docs | Accepted |
| [018](018-testing-and-ci.md) | Unit + CLI tests anywhere, full install in an Arch container in CI | Quality | Accepted |
| [019](019-private-repo.md) | Host on GitHub as a private repo for now | Project | Accepted |
| [020](020-license.md) | Choose a license | Project | **Open** |
| [021](021-remove-bundled-nes.md) | Remove the bundled NES theme; install it like any other theme | Theming / legal | Accepted |

## Writing a new record

Copy this, number it next, and add a row above.

```markdown
# NNN. Title

- **Status:** Proposed | Accepted | Superseded by NNN | Rejected
- **Date:** YYYY-MM-DD

## Context
What made this a decision worth recording.

## Decision
What we chose.

## Consequences
What this makes easier, harder, or rules out.

## Alternatives considered
What else we looked at and why not.
```
