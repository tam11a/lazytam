# 020. Code and docs under MIT; the brand stays reserved

- **Status:** Accepted
- **Date:** 2026-11-03

## Context

Friends will use and contribute to lazytam. Without a license, nobody else has the right
to use, change or share the code, and contributions arrive with unclear terms. The repo
also holds brand assets (the logo, the README headers, the wallpapers) that make lazytam
recognizable, and those are a different kind of thing from the code.

## Decision

- **Code and docs are MIT**, in [`LICENSE`](../../LICENSE):
  `Copyright (c) 2026 tam11a and lazytam contributors`. Contributions come in under the
  same license, so friends' work is covered without a separate agreement.
- **The brand is not covered by MIT.** The lazytam name, the logo and wordmark, the
  wallpapers in `themes/*/backgrounds/` and the images in `docs/assets/` (`header*.svg`,
  `src/glyphs.svg`, `theme-*.png`) stay with tam11a. People may use them with lazytam,
  including as wallpapers and in screenshots, but not to brand another project.
  `docs/assets/build.py` is code and is MIT. The terms are in
  [docs/brand.md](../brand.md#using-the-brand).
- Theme palettes (`colors.toml`) and templates are code and are MIT.
- Contributed wallpapers stay their author's, who lets lazytam ship them on the same terms
  as its own; the pull request says so.

## Consequences

- Anyone with access can use, fork and share the code; forks keep the notice and use their
  own name and art.
- `LICENSE` is the plain MIT text, so GitHub detects it. The brand carve-out lives in the
  README and brand doc, not in `LICENSE`.
- Going public still needs the NES copy cleaned out of early history
  ([021](021-remove-bundled-nes.md), R-26). The license is no longer a blocker.

## Alternatives considered

| License | Means | Why not |
|---|---|---|
| **Apache-2.0** | Like MIT, plus an explicit patent grant and change notices | More text and process than a dotfiles-style project needs |
| **GPL-3.0** | Shared changes must stay GPL | Friction for people mixing lazytam into their own configs |
| **No license** | Only people explicitly allowed can use it | Friends couldn't legally fork or reuse the code |
| **One license for everything** | Logo and wallpapers under MIT too | Anyone could ship a fork that looks like lazytam |
| **CC BY 4.0 for the art** | Anyone can reuse the art with credit | Same problem, softer; can still be chosen later |
