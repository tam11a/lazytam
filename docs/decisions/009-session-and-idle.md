# 009. Start Hyprland on demand with uwsm; lock but never suspend

- **Status:** Accepted (idle timing superseded by [024](024-idle-on-charger.md))
- **Date:** 2026-11-03

## Context

The laptop is mostly used over SSH ([002](002-dedicated-coding-laptop.md)), so a running
desktop session would waste memory most of the time. When it is used directly, it should
still lock when left alone, but it must never go to sleep and drop remote sessions.

## Decision

- Don't autostart Hyprland. Log in at the console and run `uwsm start hyprland.desktop`
  when you want the desktop.
- hypridle dims at 2.5 minutes, locks at 5, turns the screen off at 5.5, and never
  suspends. The server module also masks the sleep targets.

## Consequences

- Most of the RAM is free for builds and agents when nobody is at the laptop.
- Starting the desktop is one extra command; a login-manager option could come later.
- Remote sessions survive the user walking away.

## Alternatives considered

- **Autostart Hyprland on login / a display manager:** convenient, but wastes memory on a
  mostly headless box.
- **Suspend when idle:** better for battery, but breaks remote use.
