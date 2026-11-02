#!/usr/bin/env python3
"""lazytam helper: config access and theme rendering.

Called by bin/lazytam and install.sh. Kept to the standard library so it runs
on a fresh Arch install with nothing but `python`.

Themes use the Omarchy colors.toml format, so any Omarchy theme repo works.
Templates live in templates/*.tpl and use {{key}}, {{key.strip}} (no '#')
and {{key.rgb}} ("r, g, b") placeholders.
"""

import argparse
import os
import re
import shutil
import sys
import tomllib
from pathlib import Path

HOME = Path.home()
FRAMEWORK = Path(os.environ.get("LAZYTAM_PATH", Path(__file__).resolve().parent.parent))
CONFIG_DIR = Path(os.environ.get("LAZYTAM_CONFIG", HOME / ".config/lazytam"))
STATE_DIR = Path(os.environ.get("LAZYTAM_STATE", HOME / ".local/state/lazytam"))
CURRENT = CONFIG_DIR / "current"
USER_CONFIG = CONFIG_DIR / "config.toml"
DEFAULT_CONFIG = FRAMEWORK / "defaults/config.toml"

PROFILES = {
    "laptop": ["core", "dev", "desktop", "laptop"],
    "laptop-server": ["core", "dev", "desktop", "laptop", "server"],
    "desktop": ["core", "dev", "desktop"],
    "server": ["core", "dev", "server"],
}

REQUIRED_COLORS = ["background", "foreground", "red", "green", "yellow", "blue", "magenta", "cyan"]

# Missing keys borrow from the next key in the chain, so minimal themes still render.
COLOR_FALLBACKS = {
    "dark_background": "background",
    "darker_background": "dark_background",
    "lighter_background": "background",
    "selection": "lighter_background",
    "dark_foreground": "foreground",
    "light_foreground": "foreground",
    "bright_foreground": "light_foreground",
    "muted": "dark_foreground",
    "accent": "blue",
    "orange": "yellow",
    "brown": "orange",
    "bright_red": "red",
    "bright_green": "green",
    "bright_yellow": "yellow",
    "bright_blue": "blue",
    "bright_magenta": "magenta",
    "bright_cyan": "cyan",
}

# How each terminal runs a command, and how each launcher is opened.
TERMINAL_EXEC = {
    "kitty": "kitty",
    "foot": "foot",
    "ghostty": "ghostty -e",
    "alacritty": "alacritty -e",
    "wezterm": "wezterm start --",
}
LAUNCHERS = {
    "fuzzel": ("fuzzel", "fuzzel --dmenu"),
    "walker": ("walker", "walker --dmenu"),
    "rofi": ("rofi -show drun", "rofi -dmenu"),
}

# Files an Omarchy theme may ship that we render ourselves; never copied as overrides.
THEME_META = {"colors.toml", "icons.theme", "preview.png", "README.md", "LICENSE"}

HEX = re.compile(r"^#[0-9a-fA-F]{6}$")
PLACEHOLDER = re.compile(r"\{\{\s*([a-z_]+)(?:\.(strip|rgb))?\s*\}\}")


class LazytamError(Exception):
    pass


# ---------- config ----------

def load_settings() -> dict:
    with open(DEFAULT_CONFIG, "rb") as f:
        settings = tomllib.load(f)
    if USER_CONFIG.exists():
        with open(USER_CONFIG, "rb") as f:
            try:
                settings.update(tomllib.load(f))
            except tomllib.TOMLDecodeError as e:
                raise LazytamError(f"{USER_CONFIG}: {e}") from e
    return settings


def derived_settings(settings: dict) -> dict:
    terminal = settings["terminal"]
    launcher = settings["launcher"]
    if launcher not in LAUNCHERS:
        raise LazytamError(f"unknown launcher '{launcher}' (supported: {', '.join(LAUNCHERS)})")
    return {
        "terminal_exec": TERMINAL_EXEC.get(terminal, f"{terminal} -e"),
        "launcher_cmd": LAUNCHERS[launcher][0],
        "launcher_dmenu": LAUNCHERS[launcher][1],
    }


def config_get(key: str) -> str:
    settings = load_settings()
    settings.update(derived_settings(settings))
    if key not in settings:
        raise LazytamError(f"no config key '{key}'")
    value = settings[key]
    return " ".join(map(str, value)) if isinstance(value, list) else str(value)


def set_config_line(key: str, value: str) -> None:
    """Rewrite one `key = "value"` line in the user's config, keeping comments."""
    text = USER_CONFIG.read_text()
    line = f'{key} = "{value}"'
    pattern = re.compile(rf"^{re.escape(key)}\s*=.*$", re.MULTILINE)
    text = pattern.sub(line, text, count=1) if pattern.search(text) else text.rstrip("\n") + f"\n{line}\n"
    USER_CONFIG.write_text(text)


def init_config(profile: str, modules: list[str] | None) -> None:
    if USER_CONFIG.exists():
        return
    if profile not in PROFILES:
        raise LazytamError(f"unknown profile '{profile}' (choose: {', '.join(PROFILES)})")
    mods = modules or PROFILES[profile]
    text = DEFAULT_CONFIG.read_text()
    text = re.sub(r"^profile\s*=.*$", f'profile = "{profile}"', text, count=1, flags=re.MULTILINE)
    text = re.sub(r"^modules\s*=.*$", "modules = [" + ", ".join(f'"{m}"' for m in mods) + "]",
                  text, count=1, flags=re.MULTILINE)
    USER_CONFIG.parent.mkdir(parents=True, exist_ok=True)
    USER_CONFIG.write_text(text)


# ---------- themes ----------

def theme_roots() -> list[Path]:
    return [CONFIG_DIR / "themes", FRAMEWORK / "themes"]


def find_theme(name: str) -> Path:
    for root in theme_roots():
        if (root / name / "colors.toml").exists():
            return root / name
    raise LazytamError(f"theme '{name}' not found (try `lazytam theme list`)")


def list_themes() -> list[str]:
    names = set()
    for root in theme_roots():
        if root.is_dir():
            names.update(p.parent.name for p in root.glob("*/colors.toml"))
    return sorted(names)


def load_colors(theme_dir: Path) -> dict:
    with open(theme_dir / "colors.toml", "rb") as f:
        raw = tomllib.load(f)
    colors = {}
    for key, value in raw.items():
        if isinstance(value, str) and value.startswith("#"):
            if not HEX.match(value):
                raise LazytamError(f"{theme_dir.name}: '{key}' is not a #rrggbb color: {value}")
            colors[key] = value.lower()
    missing = [k for k in REQUIRED_COLORS if k not in colors]
    if missing:
        raise LazytamError(f"{theme_dir.name}: colors.toml is missing {', '.join(missing)}")

    def resolve(key: str, seen: tuple = ()) -> str:
        if key in colors:
            return colors[key]
        if key in seen or key not in COLOR_FALLBACKS:
            raise LazytamError(f"{theme_dir.name}: cannot derive color '{key}'")
        return resolve(COLOR_FALLBACKS[key], seen + (key,))

    for key in COLOR_FALLBACKS:
        colors[key] = resolve(key)
    colors["mode"] = raw.get("mode", "dark")

    # Terminal black/white slots flip on light themes so "black" text stays readable.
    if colors["mode"] == "light":
        colors.update(ansi_black=colors["foreground"], ansi_white=colors["darker_background"],
                      ansi_bright_white=colors["lighter_background"])
    else:
        colors.update(ansi_black=colors["lighter_background"], ansi_white=colors["dark_foreground"],
                      ansi_bright_white=colors["bright_foreground"])
    colors["ansi_bright_black"] = colors["muted"]
    return colors


def backgrounds(theme_dir: Path) -> list[Path]:
    exts = {".png", ".jpg", ".jpeg", ".webp", ".gif"}
    folder = theme_dir / "backgrounds"
    return sorted(p for p in folder.iterdir() if p.suffix.lower() in exts) if folder.is_dir() else []


def substitute(template: str, context: dict, source: str) -> str:
    def repl(m: re.Match) -> str:
        key, fmt = m.group(1), m.group(2)
        if key not in context:
            raise LazytamError(f"{source}: unknown placeholder '{key}'")
        value = str(context[key])
        if fmt is None:
            return value
        if not HEX.match(value):
            raise LazytamError(f"{source}: '.{fmt}' used on non-color '{key}'")
        if fmt == "strip":
            return value[1:]
        return ", ".join(str(int(value[i:i + 2], 16)) for i in (1, 3, 5))

    return PLACEHOLDER.sub(repl, template)


def select_background(theme_dir: Path, step: int = 0) -> Path | None:
    """Point current/background at the theme's wallpaper; step=1 picks the next one."""
    images = backgrounds(theme_dir)
    link = CURRENT / "background"
    if not images:
        link.unlink(missing_ok=True)
        return None
    index_file = STATE_DIR / "background-index"
    try:
        index = int(index_file.read_text())
    except (FileNotFoundError, ValueError):
        index = 0
    index = (index + step) % len(images)
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    index_file.write_text(str(index))
    link.unlink(missing_ok=True)
    link.symlink_to(images[index])
    return link


def render(theme_name: str) -> list[str]:
    """Render every template for theme_name into ~/.config/lazytam/current. Returns warnings."""
    theme_dir = find_theme(theme_name)
    settings = load_settings()
    has_backgrounds = bool(backgrounds(theme_dir))
    wallpaper = str(CURRENT / "background") if has_backgrounds else ""
    context = {
        **{k: v for k, v in settings.items() if not isinstance(v, (list, dict))},
        **derived_settings(settings),
        **load_colors(theme_dir),
        "theme_name": theme_name,
        "home": str(HOME),
        "wallpaper": wallpaper,
        "lock_background": wallpaper or "screenshot",
    }

    staging = CONFIG_DIR / ".current.new"
    shutil.rmtree(staging, ignore_errors=True)
    staging.mkdir(parents=True)
    for tpl in sorted((FRAMEWORK / "templates").glob("*.tpl")):
        out = staging / tpl.name.removesuffix(".tpl")
        out.write_text(substitute(tpl.read_text(), context, tpl.name))

    # Older Omarchy themes ship finished per-app files; let those win over ours,
    # unless they point into Omarchy's own install, which doesn't exist here.
    warnings = []
    for extra in sorted(theme_dir.iterdir()):
        if not extra.is_file() or extra.name in THEME_META or not (staging / extra.name).exists():
            continue
        if "omarchy/" in extra.read_text(errors="ignore"):
            warnings.append(f"skipped {extra.name}: it references Omarchy's install paths")
            continue
        shutil.copyfile(extra, staging / extra.name)

    (staging / "theme").write_text(theme_name + "\n")
    previous = (CURRENT / "theme").read_text().strip() if (CURRENT / "theme").exists() else None
    if previous != theme_name:
        (STATE_DIR / "background-index").unlink(missing_ok=True)
    shutil.rmtree(CURRENT, ignore_errors=True)
    staging.rename(CURRENT)
    if has_backgrounds:
        select_background(theme_dir)
    return warnings


# ---------- cli ----------

def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(prog="lazytam.py")
    sub = parser.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("config-get"); p.add_argument("key")
    p = sub.add_parser("init-config"); p.add_argument("--profile", required=True); p.add_argument("--modules", nargs="*")
    sub.add_parser("profiles")
    sub.add_parser("theme-list")
    p = sub.add_parser("theme-set"); p.add_argument("name")
    sub.add_parser("theme-render")
    p = sub.add_parser("color"); p.add_argument("key")
    p = sub.add_parser("background"); p.add_argument("step", type=int, nargs="?", default=0)
    args = parser.parse_args(argv)

    try:
        if args.cmd == "config-get":
            print(config_get(args.key))
        elif args.cmd == "init-config":
            init_config(args.profile, args.modules)
        elif args.cmd == "profiles":
            for name, mods in PROFILES.items():
                print(f"{name}: {' '.join(mods)}")
        elif args.cmd == "theme-list":
            current = (CURRENT / "theme").read_text().strip() if (CURRENT / "theme").exists() else ""
            for name in list_themes():
                print(f"{'*' if name == current else ' '} {name}")
        elif args.cmd in ("theme-set", "theme-render"):
            name = args.name if args.cmd == "theme-set" else load_settings()["theme"]
            for w in render(name):
                print(f"warning: {w}", file=sys.stderr)
            if args.cmd == "theme-set":
                set_config_line("theme", name)
        elif args.cmd == "color":
            print(load_colors(find_theme(load_settings()["theme"]))[args.key])
        elif args.cmd == "background":
            link = select_background(find_theme(load_settings()["theme"]), args.step)
            print(link or "")
    except LazytamError as e:
        print(f"lazytam: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
