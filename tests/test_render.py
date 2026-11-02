"""Theme engine tests. Run: python3 -m unittest discover -s tests"""

import importlib
import os
import sys
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent


class RenderTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        root = Path(self.tmp.name)
        os.environ["LAZYTAM_PATH"] = str(REPO)
        os.environ["LAZYTAM_CONFIG"] = str(root / "config")
        os.environ["LAZYTAM_STATE"] = str(root / "state")
        sys.path.insert(0, str(REPO / "lib"))
        import lazytam
        self.lt = importlib.reload(lazytam)
        self.lt.init_config("laptop-server", None)
        self.themes = root / "config/themes"

    def tearDown(self):
        sys.path.remove(str(REPO / "lib"))
        self.tmp.cleanup()

    def add_theme(self, name, colors, files=None, backgrounds=0):
        d = self.themes / name
        d.mkdir(parents=True)
        (d / "colors.toml").write_text("\n".join(f'{k} = "{v}"' for k, v in colors.items()))
        for fname, content in (files or {}).items():
            (d / fname).write_text(content)
        if backgrounds:
            (d / "backgrounds").mkdir()
            for i in range(backgrounds):
                (d / "backgrounds" / f"{i}.png").write_bytes(b"")
        return d

    MINIMAL = {k: "#112233" for k in ["background", "foreground", "red", "green", "yellow", "blue", "magenta", "cyan"]}
    # Every colors.toml key, as in a complete Omarchy theme.
    FULL = {
        "accent": "#8fb8de", "selection": "#2a2f3a", "muted": "#5c6370",
        "background": "#14161b", "dark_background": "#0f1115", "darker_background": "#0a0b0e", "lighter_background": "#1d2028",
        "foreground": "#d4d7dd", "dark_foreground": "#a3a8b3", "light_foreground": "#e1e3e8", "bright_foreground": "#f0f1f4",
        "red": "#e5737a", "yellow": "#e8c07d", "orange": "#e39b6b", "green": "#9ccc8a", "cyan": "#7cc7c3",
        "blue": "#7fb0e0", "magenta": "#c49be8", "brown": "#a6785a",
        "bright_red": "#f08a90", "bright_yellow": "#f2d199", "bright_green": "#b2dca2",
        "bright_cyan": "#97d8d4", "bright_blue": "#9cc4ec", "bright_magenta": "#d4b4f0",
    }

    def test_full_theme_renders_every_template(self):
        self.add_theme("full", self.FULL)
        self.lt.render("full")
        current = self.lt.CURRENT
        for tpl in (REPO / "templates").glob("*.tpl"):
            out = current / tpl.name.removesuffix(".tpl")
            self.assertTrue(out.exists(), out)
            self.assertNotIn("{{", out.read_text(), out)
        self.assertEqual((current / "theme").read_text().strip(), "full")

    def test_color_formats(self):
        self.add_theme("full", self.FULL)
        self.lt.render("full")
        hypr = (self.lt.CURRENT / "hyprland.conf").read_text()
        self.assertIn("col.active_border = rgb(8fb8de)", hypr)
        self.assertEqual(self.lt.substitute("{{accent.rgb}}", {"accent": "#8fb8de"}, "t"), "143, 184, 222")

    def test_minimal_theme_uses_fallbacks(self):
        colors = dict(self.MINIMAL, blue="#0000ff")
        self.add_theme("mini", colors)
        resolved = self.lt.load_colors(self.themes / "mini")
        self.assertEqual(resolved["accent"], "#0000ff")
        self.assertEqual(resolved["bright_blue"], "#0000ff")
        self.assertEqual(resolved["muted"], "#112233")
        self.lt.render("mini")

    def test_missing_required_color_fails(self):
        colors = dict(self.MINIMAL)
        del colors["red"]
        self.add_theme("broken", colors)
        with self.assertRaisesRegex(self.lt.LazytamError, "missing red"):
            self.lt.load_colors(self.themes / "broken")

    def test_bad_hex_fails(self):
        self.add_theme("badhex", dict(self.MINIMAL, red="#12345"))
        with self.assertRaisesRegex(self.lt.LazytamError, "not a #rrggbb"):
            self.lt.load_colors(self.themes / "badhex")

    def test_unknown_placeholder_fails(self):
        with self.assertRaisesRegex(self.lt.LazytamError, "unknown placeholder 'nope'"):
            self.lt.substitute("{{nope}}", {}, "t")

    def test_legacy_theme_files_override_but_omarchy_paths_are_skipped(self):
        self.add_theme("legacy", self.MINIMAL, files={
            "kitty.conf": "background #000000\n",
            "mako.ini": "include=~/.local/share/omarchy/default/mako/core.ini\n",
        })
        warnings = self.lt.render("legacy")
        self.assertEqual((self.lt.CURRENT / "kitty.conf").read_text(), "background #000000\n")
        self.assertNotIn("omarchy", (self.lt.CURRENT / "mako.ini").read_text())
        self.assertEqual(len(warnings), 1)

    def test_backgrounds_cycle(self):
        self.add_theme("pics", self.MINIMAL, backgrounds=3)
        self.lt.render("pics")
        self.lt.set_config_line("theme", "pics")
        link = self.lt.CURRENT / "background"
        self.assertEqual(Path(os.readlink(link)).name, "0.png")
        self.lt.select_background(self.themes / "pics", 1)
        self.assertEqual(Path(os.readlink(link)).name, "1.png")
        self.lt.select_background(self.themes / "pics", 2)
        self.assertEqual(Path(os.readlink(link)).name, "0.png")
        lock = (self.lt.CURRENT / "hyprlock.conf").read_text()
        self.assertIn(f"path = {link}", lock)
        # Re-rendering keeps the position; switching themes starts over.
        self.lt.select_background(self.themes / "pics", 1)
        self.lt.render("pics")
        self.assertEqual(Path(os.readlink(link)).name, "1.png")
        self.add_theme("pics2", self.MINIMAL, backgrounds=2)
        self.lt.render("pics2")
        self.assertEqual(Path(os.readlink(link)).name, "0.png")

    def test_no_backgrounds_locks_on_screenshot(self):
        self.add_theme("full", self.FULL)
        self.lt.render("full")
        self.assertIn("path = screenshot", (self.lt.CURRENT / "hyprlock.conf").read_text())

    def test_default_theme_is_joypad(self):
        self.assertEqual(self.lt.config_get("theme"), "joypad")

    def test_builtin_themes_are_complete(self):
        for name in ("joypad", "paper"):
            raw = (REPO / "themes" / name / "colors.toml").read_text()
            for key in self.FULL:
                self.assertRegex(raw, rf'(?m)^{key} = "#[0-9a-f]{{6}}"$', f"{name}: {key}")
            self.lt.render(name)

    def test_light_theme_flips_terminal_black_and_white(self):
        self.lt.render("joypad")
        dark = (self.lt.CURRENT / "kitty.conf").read_text()
        self.assertIn("color0 #1e1e1e", dark)
        self.lt.render("paper")
        light = (self.lt.CURRENT / "kitty.conf").read_text()
        self.assertIn("color0 #2b2a28", light)   # black is the dark ink
        self.assertIn("color7 #ddd9d0", light)   # white is a paper gray

    def test_theme_set_rewrites_only_theme_line(self):
        before = self.lt.USER_CONFIG.read_text()
        self.lt.set_config_line("theme", "dusk")
        after = self.lt.USER_CONFIG.read_text()
        self.assertIn('theme = "dusk"', after)
        self.assertEqual(len(before.splitlines()), len(after.splitlines()))
        self.assertIn("# Apps.", after)

    def test_init_config_profile_and_modules(self):
        self.lt.USER_CONFIG.unlink()
        self.lt.init_config("server", None)
        self.assertEqual(self.lt.config_get("modules"), "core dev server")
        self.lt.USER_CONFIG.unlink()
        self.lt.init_config("desktop", ["core", "desktop"])
        self.assertEqual(self.lt.config_get("modules"), "core desktop")

    def test_derived_terminal_settings(self):
        self.assertEqual(self.lt.config_get("terminal_exec"), "kitty")
        self.lt.USER_CONFIG.write_text(self.lt.USER_CONFIG.read_text().replace('terminal = "kitty"', 'terminal = "ghostty"'))
        self.assertEqual(self.lt.config_get("terminal_exec"), "ghostty -e")
        self.assertEqual(self.lt.config_get("launcher_dmenu"), "fuzzel --dmenu")


if __name__ == "__main__":
    unittest.main()
