# 013. joypad (dark, default) and paper (light) are lazytam's own themes

- **Status:** Accepted (supersedes the first "tam" slate theme)
- **Date:** 2026-11-03

## Context

The first version shipped a slate-blue theme called "tam", plus "dusk" and "paper"
variants. That was a mistake: the user had said they wanted the NES look. NES itself is
taken twice over: bjarneo publishes an Omarchy theme called `nes`, and NES is Nintendo's
trademark.

## Decision

- **joypad** is lazytam's default: charcoal (`#121212`), controller grays (accent
  `#a3a5a1`) and one red (`#e0453b`), inspired by NES but with its own values. Its other
  colors are tinted grays, so terminal output stays readable.
- **paper** is its light twin: ink on off-white (`#f2f0eb`) with the same single red
  (`#c8362d`).
- Both ship in `themes/` with all 25 keys (a test enforces it). "tam" and "dusk" are
  dropped.
- Names chosen from ink, cartridge, joypad and carbon; the user picked **joypad**.

## Consequences

- No dependency on anyone else's theme or trademark for the default look.
- Red is the brand's single pop of color ([015](015-brand.md)).
- Light themes needed the terminal black/white swap ([007](007-theme-format.md)).
- `muted` fails WCAG contrast for text in both themes (NFR-23); to fix.

## Alternatives considered

- **Use bjarneo's NES as the default:** depends on an unlicensed external repo and a
  trademark. It was bundled as an extra for a while ([014](014-bundled-nes.md)), then
  removed ([021](021-remove-bundled-nes.md)); it installs with `lazytam theme install`.
