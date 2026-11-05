# Themes

A theme is a folder with a `colors.toml`, in the same format as
[Omarchy](https://github.com/basecamp/omarchy) themes:

```
themes/<name>/
├── colors.toml        # required
├── backgrounds/       # optional: 1-name.png, 2-name.png … (first is the default)
└── <app files>        # optional: finished per-app files that replace rendered ones
```

Built-in themes live in `themes/`. Themes users install with
`lazytam theme install <git-url>` go to `~/.config/lazytam/themes/` and win over built-in
ones with the same name.

## colors.toml

```toml
mode = "dark"            # or "light"

accent = "#a3a5a1"       # focused window border, current workspace, cursor
selection = "#2a2a2a"
muted = "#5a5a58"

background = "#121212"
dark_background = "#0d0d0d"
darker_background = "#080808"
lighter_background = "#1e1e1e"

foreground = "#d0d0cb"
dark_foreground = "#a0a19a"
light_foreground = "#dcdcd7"
bright_foreground = "#ebebe7"

red = "#e0453b"          # plus orange yellow green cyan blue magenta brown
bright_red = "#f0473c"   # plus bright_yellow bright_green bright_cyan bright_blue bright_magenta
```

Only `background`, `foreground` and the six base colors (`red green yellow blue magenta
cyan`) are required. Everything else falls back to a related key: `accent` → `blue`,
`bright_*` → the base color, `muted` → `dark_foreground` → `foreground`, and so on (see
`COLOR_FALLBACKS` in `lib/lazytam.py`). Built-in themes define all 25 keys; a test checks
this.

### Light themes

Set `mode = "light"`. lazytam then swaps the terminal's black and white slots (`ansi_black`
becomes `foreground`, `ansi_white` becomes `darker_background`), so programs that print
"black" text stay readable on a light background.

## Templates

Each `templates/<file>.tpl` renders to `~/.config/lazytam/current/<file>`. Placeholders:

| Placeholder | Becomes |
|---|---|
| `{{red}}` | `#e0453b` |
| `{{red.strip}}` | `e0453b` (for Hyprland's `rgb(...)`, fuzzel) |
| `{{red.rgb}}` | `224, 69, 59` (for CSS `rgba(...)`) |
| `{{font}}`, `{{font_size}}`, `{{terminal}}`, … | Any setting in `config.toml` |
| `{{terminal_exec}}`, `{{launcher_cmd}}`, `{{launcher_dmenu}}` | Derived from `terminal` and `launcher` |
| `{{ansi_black}}`, `{{ansi_white}}`, … | Terminal slots, flipped on light themes |
| `{{wallpaper}}`, `{{lock_background}}` | Current wallpaper path, or `screenshot` for hyprlock |
| `{{theme_name}}`, `{{home}}` | The theme's name, the user's home |

An unknown placeholder stops rendering with an error that names the template.

### Adding an app

1. Write `templates/<app>.<ext>.tpl`.
2. Make the app load it: a stub in `modules/desktop/stubs/` that includes
   `@HOME@/.config/lazytam/current/<app>.<ext>`, or a symlink created in a module's
   `setup.sh` if the app can't include files.
3. If the app can reload live, add it to `reload_desktop` in `lib/common.sh`.
4. Run `make test`; the unit tests render every template for a full theme and fail on
   leftover `{{`.

### Zen Browser

Each Zen profile gets a one-line `chrome/userChrome.css` that imports `current/zen.css`, plus
one line in `user.js` to turn on userChrome support. An existing `userChrome.css` is left
alone, and lazytam prints the line to add yourself. Restart Zen after switching themes. The
theme's `mode` also sets the desktop's light/dark preference, which applies live. See
[D-023](decisions/023-zen-theme.md).

## Wallpapers

Name them `N-name.png` in `backgrounds/`; `lazytam bg next` (`Super` `Ctrl` `W`) cycles in
name order and remembers the position until the theme changes. lazytam's own wallpapers are
designed in Figma as components tied to the theme variables, so each design exists for
every theme. Export them at 1920×1080 into each theme's `backgrounds/`.

## Omarchy compatibility

Any theme with a `colors.toml` works. Older Omarchy themes that ship finished files
(`kitty.conf`, `waybar.css`, …) work too: those files replace the rendered ones. Files
that point into Omarchy's own install (`~/.local/share/omarchy/…`) are skipped with a
warning, since that folder doesn't exist on lazytam.
