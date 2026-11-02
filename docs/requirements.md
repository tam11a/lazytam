# Requirements

What lazytam must do (functional) and how well (non-functional). Every requirement has an
ID so issues, pull requests and the [roadmap](roadmap.md) can point at it.

**Status:** Done · Partial · Planned · Idea. "Verified" says how we know: a unit test
(`unit`), the CLI test (`cli`), the Arch container install in CI (`arch`), on real
hardware (`hw`), or not yet (`—`).

> Nothing has run on real hardware yet. Anything marked Done is verified only as far as
> the "Verified" column says.

## Functional requirements

### Installation

| ID | Requirement | Status | Verified |
|---|---|---|---|
| FR-INS-1 | One command installs lazytam from a cloned repo on a fresh Arch system: `install.sh --profile <name>` | Done | arch |
| FR-INS-2 | Profiles `laptop`, `laptop-server` (default), `desktop`, `server` seed the module list on first install only | Done | unit, arch |
| FR-INS-3 | Running the installer again on a working system changes nothing | Done | arch |
| FR-INS-4 | The installer refuses non-Arch systems and running as root (`LAZYTAM_ALLOW_ROOT=1` for containers) | Done | — |
| FR-INS-5 | AUR packages install through paru, which the installer bootstraps if missing | Done | — |
| FR-INS-6 | `LAZYTAM_SKIP_AUR=1` and `LAZYTAM_SKIP_CLAUDE=1` skip the AUR and Claude Code (containers, CI) | Done | arch |
| FR-INS-7 | Only missing packages are passed to pacman, so re-runs don't print a warning per installed package | Planned | — |
| FR-INS-8 | Installs `linux-lts` as a fallback boot entry, so a bad kernel can't lock a remote box out | Planned | — |
| FR-INS-9 | A ready-made `archinstall` config for the recommended base install (btrfs, minimal profile) | Idea | — |

### Configuration

| ID | Requirement | Status | Verified |
|---|---|---|---|
| FR-CFG-1 | One file, `~/.config/lazytam/config.toml`, holds modules, theme, font, apps and laptop settings | Done | unit |
| FR-CFG-2 | Terminal, launcher, browser, editor and file manager are swappable in `config.toml`; keybindings and Waybar follow | Done | unit |
| FR-CFG-3 | Each app's user file is created once from a module's starter file; an existing non-lazytam file is backed up as `.pre-lazytam` | Done | cli |
| FR-CFG-4 | `lazytam config <key>` prints any setting, including derived ones (`terminal_exec`, `launcher_dmenu`) | Done | unit, cli |
| FR-CFG-5 | Choosing an app that isn't installed offers to install it, instead of only reporting it in `doctor` | Planned | — |

### Theming

| ID | Requirement | Status | Verified |
|---|---|---|---|
| FR-THM-1 | Themes use Omarchy's `colors.toml` format | Done | unit |
| FR-THM-2 | Missing color keys fall back to related keys; bad hex values and missing required keys fail with a clear message | Done | unit |
| FR-THM-3 | Themes render configs for Hyprland, hyprlock, Waybar, kitty, fuzzel, mako, btop and tmux | Done | unit, cli |
| FR-THM-4 | Switching themes reloads the running desktop (Hyprland, Waybar, mako, kitty, wallpaper) | Partial | — |
| FR-THM-5 | Light themes swap the terminal's black and white slots | Done | unit, cli |
| FR-THM-6 | Built-in themes: `joypad` (default) and `paper` (light), each with every color key and wallpapers | Done | unit, cli |
| FR-THM-7 | `lazytam theme install <git-url>` installs any Omarchy-format theme | Done | — |
| FR-THM-8 | Each theme's wallpapers cycle with `lazytam bg next`; the position resets when the theme changes | Done | unit, cli |
| FR-THM-9 | `lazytam theme pick` (`Super` `Ctrl` `T`) chooses a theme from the launcher | Done | — |
| FR-THM-10 | Older Omarchy themes' finished per-app files override rendered ones, except files pointing into Omarchy's install | Done | unit |
| FR-THM-11 | Templates for more apps: ghostty, foot, alacritty, walker, yazi, lazygit, neovim, Zen (`userChrome.css`) | Planned | — |
| FR-THM-12 | GTK and Qt apps follow the theme's light/dark mode; the theme's `icons.theme` is applied | Planned | — |
| FR-THM-13 | Switch between a dark and light theme automatically by time of day (joypad ↔ paper) | Idea | — |
| FR-THM-14 | Generate a theme from a wallpaper | Idea | — |

### Desktop

| ID | Requirement | Status | Verified |
|---|---|---|---|
| FR-DSK-1 | Hyprland starts on demand with `uwsm start hyprland.desktop`, never automatically | Done | — |
| FR-DSK-2 | Default keybindings for apps, windows, workspaces, scratchpad, theme, wallpaper, clipboard, lock, screenshots, media keys | Done | — |
| FR-DSK-3 | Waybar shows workspaces, clock, network, Bluetooth, audio, CPU, memory, battery and tray; clicks open the matching TUI | Done | — |
| FR-DSK-4 | Idle: dim at 2.5 min, lock at 5, screen off at 5.5; never suspend | Done | — |
| FR-DSK-5 | Lock screen shows the theme's wallpaper, or a blurred screenshot when there's none | Done | unit |
| FR-DSK-6 | `lazytam menu`: one launcher menu for Wi-Fi, Bluetooth, audio, power, theme, wallpaper, screenshots | Planned | — |
| FR-DSK-7 | A power menu: lock, log out, reboot, shut down | Planned | — |
| FR-DSK-8 | Window rules for common apps (floating dialogs, picture-in-picture) | Planned | — |
| FR-DSK-9 | Saved monitor layouts for external displays | Idea | — |

### Laptop hardware

| ID | Requirement | Status | Verified |
|---|---|---|---|
| FR-LAP-1 | Power profiles via power-profiles-daemon | Done | arch |
| FR-LAP-2 | Battery stops charging at `battery_limit` (default 80%) where the hardware supports it | Done | — |
| FR-LAP-3 | Wi-Fi through iwd and impala with power saving off; NetworkManager is configured instead if it's already in use | Done | arch |
| FR-LAP-4 | Realtek RTL8821CE gets its stability quirks automatically | Done | — |
| FR-LAP-5 | Bluetooth through bluez and bluetui | Done | arch |
| FR-LAP-6 | Touchpad: natural scroll, tap-to-click behavior, three-finger workspace swipe | Done | — |

### Server and remote use

| ID | Requirement | Status | Verified |
|---|---|---|---|
| FR-SRV-1 | sshd and Tailscale are enabled | Done | arch |
| FR-SRV-2 | The machine never sleeps and ignores the lid | Done | arch |
| FR-SRV-3 | Password SSH is turned off only once `~/.ssh/authorized_keys` has a key | Done | arch |
| FR-SRV-4 | The built-in screen blanks after a minute at the console | Done | — |
| FR-SRV-5 | Claude Code runs in persistent tmux sessions reachable over SSH, including from the Claude desktop app | Partial | — |
| FR-SRV-6 | Coding agents run as a dedicated user without sudo, with scoped tokens | Planned | — |
| FR-SRV-7 | `lazytam remote` prints the SSH and Tailscale setup to paste on the desktop | Idea | — |
| FR-SRV-8 | A battery-health report when the box has been plugged in for weeks | Idea | — |

### Development tools

| ID | Requirement | Status | Verified |
|---|---|---|---|
| FR-DEV-1 | mise, lazygit, git-delta, GitHub CLI, podman, lazydocker, yazi | Done | arch (except AUR) |
| FR-DEV-2 | Claude Code installed with its native installer | Done | — |
| FR-DEV-3 | podman's user socket so docker-compatible tools work | Done | — |
| FR-DEV-4 | Shell defaults: PATH, mise, zoxide, fzf, eza/bat aliases, for bash and zsh | Done | — |

### CLI and lifecycle

| ID | Requirement | Status | Verified |
|---|---|---|---|
| FR-CLI-1 | `lazytam theme`, `bg`, `launch`, `update`, `doctor`, `config` | Done | cli |
| FR-CLI-2 | `lazytam update` pulls lazytam, runs migrations, upgrades the system, installs new packages, re-renders | Done | — |
| FR-CLI-3 | `lazytam doctor` checks config, rendered theme, packages, apps, starter files and Hyprland config errors | Done | arch |
| FR-CLI-4 | Migrations run once per machine; fresh installs skip existing ones | Done | — |
| FR-CLI-5 | `lazytam module enable/disable <name>` | Planned | — |
| FR-CLI-6 | `lazytam uninstall` removes lazytam-owned files and leaves the user's | Planned | — |
| FR-CLI-7 | Shell completions for `lazytam` | Idea | — |

### Project

| ID | Requirement | Status | Verified |
|---|---|---|---|
| FR-PRJ-1 | README with an animated, theme-aware header | Done | — |
| FR-PRJ-2 | CLAUDE.md, CONTRIBUTING.md and docs for architecture, modules, themes, brand and planning | Done | — |
| FR-PRJ-3 | CI: lint, tests on Python 3.11 and 3.13, full install in an Arch container | Done | CI |
| FR-PRJ-4 | Issue forms and a pull request template | Done | — |
| FR-PRJ-5 | A license | Planned (decision open: [D-020](decisions/020-license.md)) | — |
| FR-PRJ-6 | Versioned releases and a changelog | Planned | — |

## Non-functional requirements

### Safety and ownership

| ID | Requirement | Status | Verified |
|---|---|---|---|
| NFR-1 | lazytam never writes to a user's own config files after install | Done | cli |
| NFR-2 | Every setup step is idempotent; a second install changes nothing | Done | arch |
| NFR-3 | A second install prints only real warnings | Planned | — |
| NFR-4 | No change can lock the user out of SSH, the network or their session | Partial | arch |
| NFR-5 | System changes are reversible: btrfs snapshots around pacman, lazytam's system files named `90-lazytam-*` | Partial | — |

NFR-4 is Partial because the laptop module switches Wi-Fi to iwd when NetworkManager isn't
enabled; on a box set up with systemd-networkd that could drop the connection mid-install.
NFR-5 is Partial because snapper needs manual setup when `/.snapshots` already exists.

### Performance

| ID | Requirement | Status | Verified |
|---|---|---|---|
| NFR-6 | Idle memory: under 600 MB used with no desktop session, under 1.5 GB with Hyprland idle (8 GB machine) | Planned | — |
| NFR-7 | `lazytam theme set` renders in under a second | Partial | unit |
| NFR-8 | A full install takes under 30 minutes on a home connection | Planned | — |

### Reliability

| ID | Requirement | Status | Verified |
|---|---|---|---|
| NFR-9 | `lazytam update` never breaks a working config; fixes for old installs go through migrations | Partial | — |
| NFR-10 | CI runs on every push and pull request | Done | CI |
| NFR-11 | Errors say what went wrong and what to do (unknown placeholder, missing colors, missing theme) | Done | unit |

### Compatibility

| ID | Requirement | Status | Verified |
|---|---|---|---|
| NFR-12 | Arch Linux x86_64 with current packages | Done | arch |
| NFR-13 | Defaults avoid Hyprland syntax that changes between releases (no window rules until pinned) | Done | — |
| NFR-14 | Omarchy-format themes work unchanged | Done | unit, cli |
| NFR-15 | Python 3.11+ standard library, bash 5 | Done | CI |

### Maintainability

| ID | Requirement | Status | Verified |
|---|---|---|---|
| NFR-16 | shellcheck clean at warning level; the theme engine and CLI have tests | Done | CI |
| NFR-17 | LF line endings, EditorConfig | Done | cli |
| NFR-18 | Generated files are reproducible from source (`make readme`) | Done | — |

### Security

| ID | Requirement | Status | Verified |
|---|---|---|---|
| NFR-19 | Remote access only over SSH keys and Tailscale; no ports opened to the internet | Partial | — |
| NFR-20 | Coding agents run with least privilege | Planned | — |
| NFR-21 | Software comes only from the Arch repos, the AUR and Claude Code's official installer | Done | — |

NFR-19 is Partial because there's no firewall configuration yet.

### Usability and accessibility

| ID | Requirement | Status | Verified |
|---|---|---|---|
| NFR-22 | Keyboard first: everything reachable without a mouse | Partial | — |
| NFR-23 | Text colors meet WCAG AA contrast (4.5:1) on the theme background | Partial | measured |
| NFR-24 | Animated README headers respect reduced-motion settings | Done | — |

NFR-23 measurements (against `background`):

| Role | joypad | paper |
|---|---|---|
| foreground | 12.1 ✅ | 12.6 ✅ |
| dark_foreground | 7.2 ✅ | 6.5 ✅ |
| accent | 7.5 ✅ | 5.8 ✅ |
| red | 4.5 ✅ (barely) | 4.6 ✅ (barely) |
| muted | 2.7 ❌ | 2.6 ❌ |

`muted` is used for secondary text (inactive workspaces, comments, labels), so either
lighten it or stop using it for text. Tracked in the [roadmap](roadmap.md).

### Brand and legal

| ID | Requirement | Status | Verified |
|---|---|---|---|
| NFR-25 | The Figma variables and `themes/*/colors.toml` stay in sync | Partial | — |
| NFR-26 | Nothing unlicensed ships: no third-party themes or art are bundled | Partial | — |
| NFR-27 | Wallpapers and artwork are original or properly licensed | Done | — |

NFR-26 is Partial: the bundled NES copy was removed from the working tree
([D-021](decisions/021-remove-bundled-nes.md)), but it's still in the git history of the
first commits. Clean the history before any public release.
