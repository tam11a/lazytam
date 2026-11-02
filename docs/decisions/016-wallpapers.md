# 016. Wallpapers are Figma components tied to theme variables

- **Status:** Accepted
- **Date:** 2026-11-03

## Context

Each theme needs wallpapers, and every design should exist for every theme without being
redrawn. The user shared references (a flame mascot, a flame skull, a speech bubble,
pixel icons) and asked for wallpapers in that style.

## Decision

- Each wallpaper is a 1920×1080 component on Figma's Wallpapers page, with fills bound to
  `lazytam/theme` variables; instances in each theme mode are exported as PNGs into
  `themes/<theme>/backgrounds/N-name.png`.
- Designs are **original**, inspired by references but not copied (the flame mascot
  reference is ©CAFONER).
- Current set: **afk** (bored speech bubble) and **lives** (pixel heart, prompt, sleepy
  block). Earlier designs (tiles, horizon, waves, prompt, ember, blaze) were removed at the
  user's request; the user will craft more.

## Consequences

- A new theme gets every wallpaper by adding a variable mode and exporting.
- Exports are PNG because swww doesn't take SVG.
- Binding a paint to a variable in Figma resets its opacity; put opacity on the layer
  instead. This caught us twice.

## Alternatives considered

- **Hand-made PNGs per theme:** no reuse, drift between themes.
