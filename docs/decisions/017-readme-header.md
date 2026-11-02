# 017. The README header is an animated SVG generated from outlined glyphs

- **Status:** Accepted
- **Date:** 2026-11-03

## Context

The user wanted a README like their GitHub profile ([tam11a/tam11a](https://github.com/tam11a/tam11a)):
full-width animated SVG panels with dark cards, grain, a glow and staggered motion, with
mobile variants.

## Decision

- `docs/assets/build.py` generates four headers: dark/light × wide/mobile. GitHub picks one
  with `<picture>` media queries.
- Text is **outlined glyphs** exported from Figma (README page, frame `readme/glyphs`) into
  `docs/assets/src/glyphs.svg`, so no fonts are embedded.
- Animation uses CSS (entrance) and SMIL (the typing loop), which both work in GitHub's
  image rendering. Reduced-motion settings turn off the CSS animations.
- Theme previews in the README are PNGs exported from the Figma theme cards.

## Consequences

- Each header is about 87 KB.
- Changing the wording means editing text in Figma, flattening, re-exporting the glyph sheet
  and rebuilding (documented in the script).
- The typing loop still runs under reduced motion, since SMIL ignores the media query.

## Alternatives considered

- **Embedded web fonts** (the profile's approach): more flexible text, bigger files and
  font licensing to check.
- **A static image:** no motion, no light/dark.
