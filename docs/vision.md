# Vision

## The problem

Hyprland frameworks like Omarchy and HyDE make Arch look finished in minutes, but they
take over your config. After years of hand-written dotfiles you no longer know which file
is yours, what the next update will overwrite, or how to remove the apps they chose for
you (often Chromium- and Electron-based). The alternative, writing everything yourself,
costs a weekend every time and never quite looks as polished.

## The idea

lazytam is a small framework that gives you the polish without the takeover:

- **Defaults load first, your files load last.** Updates only touch lazytam's own folder.
- **Every app is a setting.** Terminal, launcher, browser, editor and file manager are one
  line each.
- **Only what you asked for.** Modules list every package. TUIs first, no Chromium.
- **Themes are just colors.** One `colors.toml` recolors the whole desktop, and Omarchy
  themes work as-is.

The name is the point: lazytam does the boring parts so you can be lazy about them, and
it's tam's.

## Who it's for

1. **tam (primary user).** Years on Arch + Hyprland, prefers TUIs and Zen, wants the
   laptop to feel premium in hand and to be a reliable remote coding box the rest of the
   time.
2. **Friends (contributors and users).** Comfortable with Linux, want a good-looking
   Hyprland setup they can understand and change, and may contribute modules, templates,
   themes or wallpapers.
3. **Claude Code.** Develops lazytam alongside tam and runs on the laptop as a coding
   agent. Needs clear rules ([CLAUDE.md](../CLAUDE.md)) and a safe place to work.

## The target machine

lazytam is designed first for one real laptop, and should work on similar ones.

| | |
|---|---|
| Model | ASUS VivoBook S15 (M533IA) |
| CPU / GPU | AMD Ryzen 7 4700U (8 cores), integrated Radeon (Renoir) |
| RAM | 8 GB, the main constraint |
| Storage | 512 GB NVMe (Kingston) |
| Wi-Fi | Realtek RTL8821CE (rtw88 driver, known to drop without quirks) |
| Display | 15.6" 1920×1080 |

How it's used:

- **Mostly headless.** Driven from tam's desktop over SSH and Tailscale, with Claude Code
  sessions in tmux, and the lid usually closed.
- **Sometimes in hand.** Used directly, it should look and feel finished: the joypad
  theme, smooth animations, the afk/lives wallpapers.
- **No gaming.** Gaming (Valorant) moved to the desktop, so there's no Windows dual boot
  and no Secure Boot/Vanguard constraint.

## Goals

1. Fresh Arch to finished desktop and coding box with one command.
2. Never overwrite a user's file after install; updates are always safe.
3. Look premium out of the box: a coherent brand, theme and wallpapers.
4. Run well in 8 GB of RAM, including when nobody is logged into the desktop.
5. Be easy for friends to read, run, test and contribute to without owning Arch.
6. Be easy for Claude Code to develop safely: written rules, tests, CI.

## Non-goals

- **Not a distro.** No ISO, no custom repos. It runs on stock Arch.
- **Not for beginners.** It assumes you can install Arch and read a config file.
- **Not cross-distro.** Arch (and pacman/AUR) only, at least for now.
- **Not a desktop environment.** No settings GUI; config is text, tools are TUIs.
- **Not Omarchy-compatible in full.** Only the theme format is shared, not Omarchy's
  scripts, menus or install layout.
- **Not for gaming.** No Steam/Proton tuning, no anti-cheat workarounds.

## What success looks like

- tam's laptop runs lazytam daily, and `lazytam update` has never broken its config.
- A friend can go from a fresh Arch install to the joypad desktop in under 30 minutes.
- A friend's first pull request (a template, theme or fix) is merged without needing a
  call to explain the codebase.
- CI catches a bad package name or broken setup step before it reaches anyone's machine.
