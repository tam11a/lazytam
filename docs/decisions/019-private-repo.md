# 019. Host on GitHub as a private repo for now

- **Status:** Accepted
- **Date:** 2026-11-03

## Context

The user wants to share lazytam with friends to use and contribute, and to keep
developing it with Claude. It has no license of its own yet ([020](020-license.md)), and
its early history contains an unlicensed theme that has since been removed
([021](021-remove-bundled-nes.md)).

## Decision

- Host at [tam11a/lazytam](https://github.com/tam11a/lazytam), **private**, default branch
  `main`. Friends are added as collaborators.
- Work happens on branches with pull requests once others contribute; CI runs on both.

## Consequences

- Cloning needs a GitHub login (`gh auth login`) or SSH key; the README says so.
- Raw GitHub URLs don't work for private repos, so the README uses relative paths for
  images.
- Going public requires: a license, cleaning the old NES copy out of git history (or a
  fresh repo), and checking every asset's rights.

## Alternatives considered

- **Public now:** blocked by the missing license and the NES copy in early history.
