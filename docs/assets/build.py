#!/usr/bin/env python3
"""Build the animated README header SVGs.

    python3 docs/assets/build.py

Writes header.svg, header-light.svg, header.m.svg and header-light.m.svg next to this
file. Don't edit those by hand; change this script and rebuild.

Text is drawn from outlined glyphs, so the headers look the same everywhere without
embedding fonts. The glyphs come from src/glyphs.svg: in the lazytam Figma file, page
"README", frame "readme/glyphs", exported as SVG. Every text layer in that frame is
flattened and named (lazy, tam, kicker, ...). To change the wording, edit the text in
Figma, flatten it again, re-export over src/glyphs.svg, and update BOX below if a
layer's position or width changed.
"""

import re
import xml.etree.ElementTree as ET
from pathlib import Path

HERE = Path(__file__).resolve().parent
SVG_NS = "{http://www.w3.org/2000/svg}"

# Top-left (x, y) of each text layer's box in the glyph sheet, and the box width.
BOX = {
    "lazy": (20, 20, 204), "tam": (20, 156, 154),
    "kicker": (20, 292, 354),
    "tag1": (20, 329, 388), "tag2": (20, 378, 228),
    "cmd": (20, 427, 235), "out": (20, 469, 153),
    "chip1": (20, 511, 32), "chip2": (20, 548, 63), "chip3": (20, 585, 71),
    "chip4": (20, 622, 110), "chip5": (20, 659, 203),
}

# joypad (dark) and paper (light), from themes/*/colors.toml
THEMES = {
    "dark": dict(card="#121212", surface="#1e1e1e", line="#2a2a2a", fg="#ebebe7", text="#d0d0cb",
                 dim="#a0a19a", muted="#5a5a58", red="#e0453b", grain=0.06),
    "light": dict(card="#f2f0eb", surface="#faf9f6", line="#dcd6ca", fg="#121211", text="#2b2a28",
                  dim="#57554f", muted="#9b978e", red="#c8362d", grain=0.05),
}

CMD_CHARS = len("lazytam theme set paper")
LOOP = 9          # seconds per typing loop
LOOP_START = 1.9  # when the first loop starts


def tidy(d):
    """One decimal is plenty at these sizes and keeps each header well under 100 KB."""
    return re.sub(r"-?\d+\.\d+", lambda m: f"{float(m.group()):.1f}".rstrip("0").rstrip("."), d)


def load_glyphs():
    root = ET.parse(HERE / "src" / "glyphs.svg").getroot()
    glyphs = {}
    for g in root.iter(f"{SVG_NS}g"):
        if g.get("id") in BOX:
            glyphs[g.get("id")] = [tidy(p.get("d")) for p in g.iter(f"{SVG_NS}path")]
    missing = set(BOX) - set(glyphs)
    if missing:
        raise SystemExit(f"src/glyphs.svg is missing layers: {', '.join(sorted(missing))}")
    return glyphs


class Header:
    def __init__(self, glyphs, theme, width, height, title):
        self.g, self.t, self.w, self.h = glyphs, THEMES[theme], width, height
        self.title = title
        self.body = []

    def add(self, s):
        self.body.append(s)

    def text(self, name, x, y, color, scale=1.0, delay=0.0, per_letter=False, step=0.045):
        """Place a glyph layer with its box's top-left at (x, y)."""
        bx, by, _ = BOX[name]
        inner = []
        for i, d in enumerate(self.g[name]):
            path = f'<path d="{d}"/>'
            if per_letter:
                path = f'<g class="fu" style="animation-delay:{delay + i * step:.2f}s">{path}</g>'
            inner.append(path)
        body = "".join(inner)
        if not per_letter:
            body = f'<g class="fu" style="animation-delay:{delay:.2f}s">{body}</g>'
        self.add(f'<g transform="translate({x} {y}) scale({scale}) translate({-bx} {-by})" fill="{color}">{body}</g>')

    def mark(self, x, y, size, delay):
        """The lazytam mark: a dwindle layout whose active window holds the prompt."""
        t, s = self.t, size / 96
        tiles = [(6, 6, 40, 84, t["red"]), (52, 6, 38, 48, t["text"]), (52, 60, 38, 30, t["muted"])]
        parts = [f'<rect class="pop" style="animation-delay:{delay + i * 0.1:.2f}s" x="{tx}" y="{ty}" '
                 f'width="{tw}" height="{th}" rx="11" fill="{c}"/>' for i, (tx, ty, tw, th, c) in enumerate(tiles)]
        parts.append(f'<path class="draw" style="animation-delay:{delay + 0.4:.2f}s" d="M15 33 L26 45 L15 57" '
                     f'stroke="{t["card"]}" stroke-width="6.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/>')
        self.add(f'<g transform="translate({x} {y}) scale({s:.4f})">{"".join(parts)}</g>')

    def terminal(self, x, y, w, delay):
        """A prompt that types the command, prints the result, and loops."""
        t = self.t
        self.add(f'<g class="fu" style="animation-delay:{delay:.2f}s">'
                 f'<rect x="{x}" y="{y}" width="{w}" height="52" rx="12" fill="{t["surface"]}" stroke="{t["line"]}"/>'
                 f'<path d="M{x + 24} {y + 19} L{x + 31} {y + 26} L{x + 24} {y + 33}" stroke="{t["red"]}" '
                 f'stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/></g>')

        cx, cmd_w = x + 46, BOX["cmd"][2]
        per_char = cmd_w / CMD_CHARS
        # Typing occupies the first 25% of the loop, then the line holds until 92%.
        times, widths = [0.0], [0.0]
        for i in range(1, CMD_CHARS + 1):
            times.append(0.03 + 0.22 * i / CMD_CHARS)
            widths.append(per_char * i)
        times += [0.92, 1.0]
        widths += [cmd_w, 0.0]
        kt = ";".join(f"{v:.4f}" for v in times)
        anim = f'dur="{LOOP}s" begin="{LOOP_START}s" repeatCount="indefinite" calcMode="discrete" keyTimes="{kt}"'
        self.add(f'<clipPath id="typed"><rect x="{cx - 2}" y="{y}" height="52" width="0">'
                 f'<animate attributeName="width" {anim} values="{";".join(f"{v + 2:.1f}" for v in widths)}"/>'
                 f'</rect></clipPath>')
        self.add(f'<g clip-path="url(#typed)">')
        self.text("cmd", cx, y + 15, t["fg"])
        self.add("</g>")
        self.add(f'<g class="blink"><rect x="{cx}" y="{y + 16}" width="9" height="19" rx="1.5" fill="{t["red"]}" opacity="0">'
                 f'<animate attributeName="x" {anim} values="{";".join(f"{cx + v + 2:.1f}" for v in widths)}"/>'
                 f'<set attributeName="opacity" to="1" begin="{LOOP_START}s"/></rect></g>')

        out_x = x + w - 24 - BOX["out"][2]
        self.add(f'<g opacity="0"><animate attributeName="opacity" dur="{LOOP}s" begin="{LOOP_START}s" '
                 f'repeatCount="indefinite" values="0;0;1;1;0;0" keyTimes="0;0.29;0.33;0.9;0.93;1"/>')
        self.text("out", out_x, y + 15, t["dim"])
        self.add("</g>")

    def chips(self, names, x, y, max_x, delay):
        t, cx, cy = self.t, x, y
        for i, name in enumerate(names):
            w = BOX[name][2] + 28
            if cx + w > max_x:
                cx, cy = x, cy + 40
            d = delay + i * 0.07
            self.add(f'<g class="fu" style="animation-delay:{d:.2f}s"><rect x="{cx}" y="{cy}" width="{w}" height="30" '
                     f'rx="15" fill="none" stroke="{t["line"]}"/></g>')
            self.text(name, cx + 14, cy + 8, t["dim"], delay=d)
            cx += w + 10

    def render(self):
        t, w, h = self.t, self.w, self.h
        return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" role="img" aria-labelledby="t d">
<!-- Generated by docs/assets/build.py. Edit the script, not this file. -->
<title id="t">{self.title}</title>
<desc id="d">lazytam: a calm Hyprland framework that never takes over your config. A terminal types: lazytam theme set paper.</desc>
<defs>
  <clipPath id="frame"><rect width="{w}" height="{h}" rx="20"/></clipPath>
  <filter id="grain" x="0" y="0" width="100%" height="100%">
    <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="2" stitchTiles="stitch"/>
    <feColorMatrix values="0 0 0 0 0.5  0 0 0 0 0.5  0 0 0 0 0.5  0 0 0 1 0"/>
  </filter>
  <radialGradient id="glow"><stop offset="0" stop-color="{t["red"]}" stop-opacity=".22"/><stop offset="1" stop-color="{t["red"]}" stop-opacity="0"/></radialGradient>
</defs>
<style>
  :root{{--e:cubic-bezier(.16,1,.3,1)}}
  .fu,.pop{{transform-box:fill-box}}
  .fu{{opacity:0;animation:fu .9s var(--e) forwards}}
  .pop{{opacity:0;transform-origin:center;animation:pop .7s var(--e) forwards}}
  .draw{{stroke-dasharray:40;stroke-dashoffset:40;animation:draw .7s var(--e) forwards}}
  .glow{{animation:breathe 6s ease-in-out infinite}}
  .blink{{animation:blink 1.05s infinite}}
  @keyframes fu{{from{{opacity:0;transform:translateY(10px)}}to{{opacity:1;transform:none}}}}
  @keyframes pop{{from{{opacity:0;transform:scale(.55)}}to{{opacity:1;transform:none}}}}
  @keyframes draw{{to{{stroke-dashoffset:0}}}}
  @keyframes breathe{{0%,100%{{opacity:.5}}50%{{opacity:1}}}}
  @keyframes blink{{0%,49%{{opacity:1}}50%,100%{{opacity:0}}}}
  @media (prefers-reduced-motion:reduce){{.fu,.pop{{animation:none;opacity:1}}.draw{{animation:none;stroke-dashoffset:0}}.glow,.blink{{animation:none}}}}
</style>
<g clip-path="url(#frame)">
<rect width="{w}" height="{h}" fill="{t["card"]}"/>
{chr(10).join(self.body)}
<rect width="{w}" height="{h}" filter="url(#grain)" opacity="{t["grain"]}"/>
</g>
</svg>
"""


def wide(glyphs, theme):
    h = Header(glyphs, theme, 1000, 420, "lazytam")
    t = h.t
    h.add(f'<circle class="glow" cx="124" cy="130" r="230" fill="url(#glow)"/>')
    h.mark(64, 70, 120, delay=0.1)
    h.text("kicker", 216, 66, t["red"], delay=0.5)
    h.text("lazy", 210, 74, t["fg"], delay=0.6, per_letter=True)
    h.text("tam", 210 + BOX["lazy"][2], 74, t["red"], delay=0.8, per_letter=True)
    h.text("tag1", 216, 206, t["dim"], delay=1.05)
    h.text("tag2", 216, 236, t["dim"], delay=1.15)
    h.terminal(64, 292, 872, delay=1.3)
    h.chips(["chip1", "chip2", "chip3", "chip4", "chip5"], 64, 366, 936, delay=1.45)
    return h.render()


def narrow(glyphs, theme):
    h = Header(glyphs, theme, 600, 470, "lazytam")
    t = h.t
    h.add(f'<circle class="glow" cx="88" cy="92" r="190" fill="url(#glow)"/>')
    h.mark(40, 44, 96, delay=0.1)
    s = 0.72
    h.text("lazy", 154, 58, t["fg"], scale=s, delay=0.6, per_letter=True)
    h.text("tam", 154 + BOX["lazy"][2] * s, 58, t["red"], scale=s, delay=0.8, per_letter=True)
    h.text("kicker", 40, 172, t["red"], delay=0.5)
    h.text("tag1", 40, 198, t["dim"], delay=1.05)
    h.text("tag2", 40, 228, t["dim"], delay=1.15)
    h.terminal(40, 278, 520, delay=1.3)
    h.chips(["chip1", "chip2", "chip3", "chip4", "chip5"], 40, 352, 560, delay=1.45)
    return h.render()


def main():
    glyphs = load_glyphs()
    outputs = {
        "header.svg": wide(glyphs, "dark"),
        "header-light.svg": wide(glyphs, "light"),
        "header.m.svg": narrow(glyphs, "dark"),
        "header-light.m.svg": narrow(glyphs, "light"),
    }
    for name, svg in outputs.items():
        (HERE / name).write_text(svg)
        print(f"wrote docs/assets/{name} ({len(svg) // 1024} KB)")


if __name__ == "__main__":
    main()
