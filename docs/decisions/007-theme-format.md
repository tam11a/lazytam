# 007. Omarchy's colors.toml format, rendered through templates

- **Status:** Accepted
- **Date:** 2026-11-03

## Context

The user liked Omarchy themes, especially NES. Inspecting it showed that newer Omarchy
themes are just a palette (`colors.toml`), wallpapers and an icon theme name; Omarchy
generates every app's config from the palette.

## Decision

- Use the same `colors.toml` format and keys.
- Render per-app files from `templates/*.tpl` with `{{key}}`, `{{key.strip}}` and
  `{{key.rgb}}` placeholders. Unknown placeholders are errors.
- Missing keys fall back to related keys, so minimal themes still work.
- Older Omarchy themes' finished per-app files override rendered ones, unless they point
  into Omarchy's own install.
- Light themes (`mode = "light"`) swap the terminal's black and white slots.

## Consequences

- Any Omarchy theme installs with `lazytam theme install <git-url>`.
- Adding an app means writing one template, not touching every theme.
- We depend on Omarchy keeping its format stable; if it changes, we keep ours.
- `icons.theme` is read by no one yet ([roadmap](../roadmap.md)).

## Alternatives considered

- **Our own format:** no ecosystem, more work for theme authors.
- **matugen/wallust colors from the wallpaper:** nice, but not reproducible; kept as an idea.
