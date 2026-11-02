# 006. Bash for the CLI and installer, Python stdlib for the theme engine

- **Status:** Accepted
- **Date:** 2026-11-03

## Context

lazytam has to run on a fresh Arch install before anything else is set up, and be easy
for friends and Claude to read and change.

## Decision

- **Bash** for `install.sh`, `bin/lazytam`, `lib/common.sh` and module setup scripts.
- **Python 3.11+ standard library only** for `lib/lazytam.py` (TOML parsing with
  `tomllib`, template rendering) and `docs/assets/build.py`.
- No other runtime dependencies. The installer installs `git` and `python` first.

## Consequences

- Nothing to compile, no package manager beyond pacman, works on any Arch machine.
- TOML parsing and templating are done properly instead of with sed.
- The CLI shells out to Python for config and rendering, which costs a few tens of
  milliseconds per call. Fine for interactive use.
- Contributors can run the tests on any Linux, macOS or WSL with Python 3.11+.

## Alternatives considered

- **Go or Rust single binary:** faster and typed, but needs a build step and toolchain;
  revisit only if performance becomes a problem.
- **Pure bash:** no TOML parser, fragile templating.
