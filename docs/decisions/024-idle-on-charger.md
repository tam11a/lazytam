# 024. Skip idle actions on the charger

- **Status:** Accepted (supersedes the idle timing in [009](009-session-and-idle.md))
- **Date:** 2026-11-05

## Context

On real hardware, the idle settings from [009](009-session-and-idle.md) got in the way while
the laptop was plugged in. They also had two bugs. The dim used a raw brightness value of
`10`, which is about 0.05% on a panel with a maximum of 21333, so the screen looked like it had
gone to sleep. The screen-off step used `hyprctl dispatch dpms`, which Hyprland 0.57 rejects
([022](022-hyprland-lua.md)).

## Decision

- On battery: dim to 10% at 2.5 minutes, lock at 5, screen off at 5.5.
- On the charger: none of these. `systemd-ac-power` decides, each time a timer fires.
- Brightness is saved at the dim timer even on the charger, so resuming restores the current
  level rather than an old one.
- Still never suspend, as in [009](009-session-and-idle.md).

## Consequences

- A plugged-in laptop doesn't lock by itself. Lock it by hand with `Super` `Esc`.
- A desktop PC never locks by itself either, because `systemd-ac-power` treats a machine with
  no battery as being on AC power.
- Each timer fires once per idle period, so unplugging after a timer has passed doesn't apply
  that step until the next idle period.
- Starter files are written once, so existing installs keep their current `hypridle.conf` and
  its bugs until the user changes it.

## Alternatives considered

- **Keep locking on the charger and skip only dim and screen-off:** safer if the laptop is left
  unattended, but the user asked for none of these while charging.
- **Turn hypridle off entirely:** loses the battery savings and the lock when unplugged.
