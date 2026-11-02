# Contributing to lazytam

Thanks for helping. lazytam is small on purpose, so the best contributions are focused:
one fix, one module, one theme, one template.

## Set up

You don't need Arch for most work. Any Linux, macOS or WSL with Python 3.11+ and bash can
run the tests.

```bash
git clone https://github.com/tam11a/lazytam
```

```bash
cd lazytam && make test
```

To test the real installer, use `make arch` (needs Docker) or a spare Arch machine or VM.
Never test `install.sh` on a machine you depend on without a btrfs snapshot to roll back to.

## Make targets

| Target | What it does |
|---|---|
| `make test` | Unit tests (`tests/test_render.py`) and the CLI run (`tests/cli.sh`) in a throwaway HOME |
| `make lint` | `bash -n` on every script, plus shellcheck (local or via Docker) |
| `make arch` | Runs `install.sh --profile laptop-server` twice in an `archlinux` container |
| `make readme` | Rebuilds the animated README headers from `docs/assets/build.py` |

CI runs `lint`, `test` and the container install on every push and pull request.

## Ground rules

These keep lazytam trustworthy. A pull request that breaks one won't be merged.

1. **Don't write to the user's files after install.** Change `defaults/` or `templates/`.
2. **Keep setup idempotent.** Running `install.sh` twice must be harmless.
3. **No surprise packages.** Every package is listed in a module. No Chromium/Electron
   apps by default.
4. **Don't lock anyone out** of SSH, the network or their session.
5. **Stdlib Python, plain bash.** No new runtime dependencies without discussion.

[CLAUDE.md](CLAUDE.md) has the same rules plus the repo layout, if you work with Claude Code.

## What to work on

- **Bugs from real hardware.** Run lazytam on your machine and report or fix what breaks.
  Include your hardware, `lazytam doctor` output and `hyprctl version`.
- **Templates** for more apps (ghostty, foot, alacritty, yazi, lazygit, Zen). See
  [docs/themes.md](docs/themes.md).
- **Modules** for things people need (gaming, printing, a different shell).
  See [docs/modules.md](docs/modules.md).
- **Themes and wallpapers.** Keep them original or properly licensed.
- **`lazytam menu`**, a launcher menu for Wi-Fi, Bluetooth, power, themes and screenshots.

Open an issue first for anything big, so we can agree on the shape before you build it.

## Making a change

1. Branch from `main`: `git switch -c fix/waybar-battery`.
2. Make the change, with a test when it touches `lib/lazytam.py` or the CLI.
3. Run `make test lint`.
4. Commit in the imperative, explaining why: `Reload mako on theme change so colors apply live`.
5. Open a pull request and fill in the template, including what you couldn't test.

## Style

- **Shell:** bash, two-space indent, `set -euo pipefail` in entry points, quote variables,
  use the helpers in `lib/common.sh` instead of raw `sudo`/`systemctl`.
- **Python:** standard library, type hints where they help, small functions.
- **Configs:** a short comment at the top saying what the file is and where to override it.
- **Copy (README, messages, errors):** lowercase *lazytam*, short plain sentences, say what
  happened and what to do next, show the command. No emoji or exclamation marks in CLI
  output. See the voice section in [docs/brand.md](docs/brand.md).

## Licensing

lazytam doesn't have a license yet. Until it does, contributions are accepted on the
understanding that they can be relicensed with the project. Don't contribute anything you
didn't make or don't have the right to share.
