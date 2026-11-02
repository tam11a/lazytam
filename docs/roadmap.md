# Roadmap

What lazytam does today, what's next, and everything it could grow into. Items have IDs
(`R-NN`) and link to the [requirements](requirements.md) they satisfy. Sizes are rough:
**S** an evening, **M** a weekend, **L** more.

## What you can do with lazytam today

- Install a themed Hyprland desktop and a dev toolchain on fresh Arch with one command.
- Use the laptop as an always-on box over SSH and Tailscale, lid closed, with Claude Code
  in tmux.
- Switch between joypad and paper (or any Omarchy theme, like bjarneo's NES) and have the whole desktop
  recolor, including the terminal, lock screen, bar, launcher and notifications.
- Swap your terminal, launcher, browser, editor or file manager in one config line.
- Update lazytam and the system with `lazytam update`, and check health with
  `lazytam doctor`.
- Develop lazytam itself from any Linux or WSL machine, with tests and CI.

## Where it's going

```
v0.1 Foundation        ████████████ done
v0.2 First real boot   ░░░░░░░░░░░░ next: make it solid on the actual laptop
v0.3 Daily driver      ░░░░░░░░░░░░ menu, more apps themed, desktop polish
v0.4 Remote coding box ░░░░░░░░░░░░ safe agents, remote workflow, security
v0.5 Friends & release ░░░░░░░░░░░░ license, releases, module management
Later                  ideas worth keeping
```

## v0.1 Foundation (Done)

Everything in the first two commits plus CI:

- Installer, profiles, modules (core, dev, desktop, laptop, server).
- Layered config with starter files written once ([D-004](decisions/004-layered-config.md)).
- Theme engine with Omarchy compatibility, templates for 8 apps, light-theme handling.
- joypad and paper themes with the afk and lives wallpapers.
- `lazytam` CLI: theme, bg, launch, update, doctor, config.
- Brand in Figma, animated README, docs, decision records, this roadmap.
- CI: lint, tests on Python 3.11/3.13, full install in an Arch container. All green.

## v0.2 First real boot (Next)

Goal: lazytam runs on the ASUS laptop every day without surprises.

| ID | Item | Size | Satisfies | Done when |
|---|---|---|---|---|
| R-01 | **Install Arch and lazytam on the laptop.** Back up, install Arch (btrfs, minimal), clone, `install.sh --profile laptop-server` | M | FR-INS-1 | The laptop boots, `lazytam doctor` is clean, the desktop starts, SSH over Tailscale works with the lid closed |
| R-02 | **Quiet re-runs.** Pass only missing packages to pacman (`pacman -T`); CI asserts the second install prints no "is up to date" lines. *Started, then paused at the user's request.* | S | FR-INS-7, NFR-3 | A second install prints only real warnings |
| R-03 | **linux-lts fallback.** Install `linux-lts` and its boot entry | S | FR-INS-8 | Both kernels appear in the boot menu |
| R-04 | **Network-safe laptop module.** Don't switch to iwd when systemd-networkd or another manager is active, or when running over SSH | M | NFR-4 | Installing over SSH on any network setup keeps the connection |
| R-05 | **Snapper on archinstall layouts.** Automate the Arch-wiki procedure safely when `/.snapshots` exists | M | NFR-5 | Snapshots work on a default archinstall btrfs layout with no manual steps |
| R-06 | **AUR in CI.** Create a non-root user in the container, build paru, install every `aur.txt` | M | FR-INS-5 | CI fails on a bad AUR package name |
| R-07 | **Validate Hyprland config in CI.** Run Hyprland's config check against the rendered files | S | NFR-13 | A syntax error in `defaults/hypr` fails CI |
| R-08 | **Fix what real hardware finds.** Track each bug as an issue; extend `doctor` (services running, battery limit applied, Wi-Fi quirk loaded) | M | FR-CLI-3 | No open bugs from the first week of daily use |
| R-09 | **Readable muted text.** Lighten `muted` or stop using it for text, in both themes and Figma | S | NFR-23 | Every text role is at least 4.5:1 |
| R-10 | **Measure.** Record idle RAM (headless and desktop) and install time on the laptop | S | NFR-6, NFR-8 | Numbers written into requirements.md |

## v0.3 Daily driver

Goal: the desktop feels finished when used in hand.

| ID | Item | Size | Satisfies | Done when |
|---|---|---|---|---|
| R-11 | **`lazytam menu`.** One fuzzel menu: Wi-Fi, Bluetooth, audio, power (lock, log out, reboot, shut down), theme, wallpaper, screenshot, clipboard | L | FR-DSK-6, FR-DSK-7 | Everything in the list works from `Super` `Alt` `Space` without touching a terminal |
| R-12 | **More templates.** ghostty, foot, alacritty, walker, yazi, lazygit, Neovim colors, Zen `userChrome.css` | M each | FR-THM-11 | Switching themes recolors each of these live |
| R-13 | **GTK, Qt and icons.** Dark/light preference follows the theme; apply `icons.theme` | M | FR-THM-12 | GTK and Qt apps match the theme's mode |
| R-14 | **Window rules.** Floating dialogs, picture-in-picture, pinned to the installed Hyprland syntax | S | FR-DSK-8 | Rules load with no config errors |
| R-15 | **Install chosen apps.** When `config.toml` names an app that isn't installed, offer to install it | S | FR-CFG-5 | Changing `terminal = "foot"` and re-rendering gets you foot |
| R-16 | **More wallpapers.** The user crafts new designs as Figma components; export for every theme | M | — | At least four wallpapers per theme |
| R-17 | **Optional login manager.** greetd + tuigreet as an opt-in module, for people who want to land in Hyprland | S | — | Opt-in works; default stays console login ([D-009](decisions/009-session-and-idle.md)) |

## v0.4 Remote coding box

Goal: the laptop is a safe, comfortable place for agents and remote work.

| ID | Item | Size | Satisfies | Done when |
|---|---|---|---|---|
| R-18 | **Agent user.** A dedicated user without sudo for Claude Code and other agents, with scoped GitHub tokens and its own SSH key | L | FR-SRV-6, NFR-20 | Agents run as that user and can't touch the main user's files or system config |
| R-19 | **Session layouts.** tmux layouts for agent work (agent, logs, shell), plus `lazytam remote` to print the SSH/Tailscale config for the desktop | M | FR-SRV-5, FR-SRV-7 | One command on the desktop opens a ready session on the laptop |
| R-20 | **Firewall.** nftables allowing only SSH over Tailscale and established traffic | S | NFR-19 | A port scan from the LAN shows nothing open |
| R-21 | **Headless health.** Battery charge and health, temperature and disk space in `doctor` and the tmux status line | S | FR-SRV-8 | Problems show up without opening the desktop |
| R-22 | **Desktop-side guide.** How to drive the laptop from the desktop: Claude desktop app SSH sessions, VS Code / Zed remote, Tailscale | S | — | A doc a friend can follow end to end |

## v0.5 Friends and release

Goal: friends can install, update and contribute with confidence.

| ID | Item | Size | Satisfies | Done when |
|---|---|---|---|---|
| R-23 | **Choose a license.** | S | FR-PRJ-5 | [D-020](decisions/020-license.md) is decided and `LICENSE` exists |
| R-24 | **Releases.** Version tags, a CHANGELOG, `lazytam update` following releases rather than `main` by default | M | FR-PRJ-6 | v0.5.0 is tagged with notes |
| R-25 | **Module management.** `lazytam module enable/disable` and `lazytam uninstall` | M | FR-CLI-5, FR-CLI-6 | Turning a module off removes its lazytam-owned files and leaves user files |
| R-26 | **Public-readiness checklist.** Remove the old NES copy from git history (or publish from a fresh repo), audit every asset's rights, add a license | S | NFR-26 | Checklist passes |
| R-27 | **Figma ↔ theme sync check.** A script that compares Figma variable values with `themes/*/colors.toml` | M | NFR-25 | CI or `make` flags a mismatch |
| R-28 | **Shell completions** for bash and zsh | S | FR-CLI-7 | Tab completes commands and theme names |

## Later: ideas worth keeping

| ID | Idea | Satisfies |
|---|---|---|
| R-29 | Switch between joypad and paper by time of day | FR-THM-13 |
| R-30 | Generate a theme from a wallpaper (matugen/wallust) | FR-THM-14 |
| R-31 | Saved monitor layouts for docking | FR-DSK-9 |
| R-32 | A ready-made archinstall config for the recommended base | FR-INS-9 |
| R-33 | A theme gallery page with previews of every theme and wallpaper | — |
| R-34 | Sync personal overrides across machines (a "your lazytam" dotfiles repo) | — |
| R-35 | More modules: printing, Bluetooth audio codecs, laptop fingerprint reader, gaming (non-goal today) | — |

## Dropped

Things we considered and decided against. See the linked decisions before reviving any.

| Idea | Why not |
|---|---|
| macOS on the laptop | No AMD laptop graphics support, unsupported Wi-Fi, no future Intel updates, license ([D-001](decisions/001-arch-hyprland.md)) |
| Dual boot Windows for Valorant | Gaming moved to the desktop ([D-002](decisions/002-dedicated-coding-laptop.md)) |
| Using HyDE or Omarchy | They take over your config ([D-003](decisions/003-own-framework.md)) |
| The slate "tam" theme and "dusk" | The look is NES-inspired: joypad and paper ([D-013](decisions/013-default-themes.md)) |
| Downloading NES at install time | Breaks if the repo goes private ([D-014](decisions/014-bundled-nes.md)) |
| Bundling the NES theme | Unlicensed and unneeded once joypad and paper were complete ([D-021](decisions/021-remove-bundled-nes.md)) |
| Glowing, gradient wallpapers | NES look is flat; the user removed all but afk and lives ([D-016](decisions/016-wallpapers.md)) |
| Testing in a VM | Hyprland needs GPU acceleration; too heavy for 8 GB ([D-018](decisions/018-testing-and-ci.md)) |
