# 023. Zen follows the theme through its profile's userChrome.css

- **Status:** Accepted
- **Date:** 2026-11-05

## Context

Zen is the default browser ([008](008-default-apps.md)), but it stayed white on joypad. Nothing
set the desktop's light/dark preference, so the portal reported "no preference" and Zen chose
light. Setting that preference fixes light and dark, but not the theme's actual colors. Zen
can only load custom interface colors from files inside its profile folder, which rule 1 of
[CLAUDE.md](../../CLAUDE.md) would normally keep lazytam out of.

## Decision

- `lazytam theme set`, `theme render`, `update` and `install.sh` set the desktop's
  `color-scheme` to `prefer-dark` or `prefer-light` from the theme's `mode`.
- `templates/zen.css.tpl` renders Zen's colors into `current/zen.css`.
- For each Zen profile, lazytam writes a one-line `chrome/userChrome.css` that imports that
  file, only if the file doesn't exist. It also appends one line to `user.js`, once, to turn on
  userChrome support, the same kind of exception as the `source` line in `~/.bashrc`.
- An existing `userChrome.css` is never changed. lazytam prints the line to add instead.

## Consequences

- Zen's interface matches joypad and paper, but it only picks up new colors when restarted.
  lazytam says so when Zen is running. Light/dark changes apply live.
- The colors use `!important`, so Zen's own workspace gradients and theme picker no longer
  change the interface while lazytam's file is loaded.
- A brand-new Zen profile gets the colors on the next render or update, because it doesn't
  exist until Zen's first launch.
- The variables are Zen internals and may change between releases, as Hyprland's config did.

## Alternatives considered

- **Light/dark preference only:** smaller, but gives Zen's own grays rather than the theme.
- **A generated Firefox theme add-on:** needs signing, and Zen's interface mostly ignores it.
