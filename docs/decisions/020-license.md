# 020. Choose a license

- **Status:** **Open**. Needs the user's decision.
- **Date:** 2026-11-03

## Context

Friends will use and contribute to lazytam. Without a license, nobody else has the right
to use, change or share the code, and contributions arrive with unclear terms.
CONTRIBUTING.md currently says contributions may be relicensed with the project.

## Options

| License | Means | Fits if |
|---|---|---|
| **MIT** | Anyone can use, change and share, including in closed projects, with attribution | You want maximum reach and minimum friction (Omarchy uses MIT) |
| **Apache-2.0** | Like MIT, plus an explicit patent grant and change notices | You want MIT's openness with clearer legal terms |
| **GPL-3.0** | Anyone can use and change; shared changes must stay GPL | You want improvements to stay open |
| **No license (status quo)** | Only people you explicitly allow can use it | It stays a private project among friends |

## What has to happen either way

- The license covers lazytam's own code, docs and art. The unlicensed NES copy is gone from
  the repo ([021](021-remove-bundled-nes.md)) but still in early git history; clean that
  before any public release.
- Add `LICENSE`, update the README's last line and CONTRIBUTING's licensing section.
- Brand assets (logo, wallpapers) can be licensed separately if you want to keep the name
  and look yours while the code is open.
