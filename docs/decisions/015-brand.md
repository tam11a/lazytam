# 015. Figma is the brand's source of truth; the logo is a dwindle layout

- **Status:** Accepted
- **Date:** 2026-11-03

## Context

lazytam should feel premium and consistent across the desktop, README and docs, and be
shareable with friends. Brand assets need one home.

## Decision

- The **lazytam Figma file** holds the brand: pages Brand, Themes, Wallpapers and README.
  Every color is a variable in `lazytam/theme`, with one mode per theme; Hyprland's look
  values are in `lazytam/ui`.
- **Logo:** a Hyprland dwindle layout of three tiles; the active tile is red and holds the
  `>` prompt. Wordmark: lowercase `lazytam` in JetBrains Mono Bold, `tam` in red.
- **Type:** JetBrains Mono for brand, labels and code; Geist for body text.
- **Voice:** calm, short, specific. Say what happened and what to do. No emoji or
  exclamation marks in CLI output.
- Summary for contributors: [docs/brand.md](../brand.md).

## Consequences

- One edit in Figma updates every brand surface that uses the variables.
- Colors exist twice (Figma variables and `themes/*/colors.toml`); they're synced by hand
  for now (NFR-25).
- Contributors without Figma access rely on `docs/brand.md`.

## Alternatives considered

- **Brand only in the repo (SVG files):** no shared design workspace, harder to iterate.
