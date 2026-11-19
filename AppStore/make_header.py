#!/usr/bin/env python3
"""Product page header. One word on a field, like the App Store examples."""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
CREAM = (246, 241, 232)
NY = "/System/Library/Fonts/NewYork.ttf"

# Header tab: 21:9. Search Results tab does not accept this size.
HEADER = (3840, 1646, (1097, 493, 1646, 661), ROOT / "header" / "Header 3840x1646.png")
# Search Results tab, the box that is open: 3:2, up to this size.
SEARCH = (3840, 2560, (836, 765, 2168, 1030), ROOT / "header" / "Search 3840x2560.png")


def font(size):
    face = ImageFont.truetype(NY, size)
    face.set_variation_by_axes([256, 620, 0])
    return face


def field(width, height):
    """Sambal, a little deeper at the top, the way a plain header still has depth."""
    top = (158, 48, 22)
    bottom = (214, 86, 46)
    column = Image.new("RGB", (1, height))
    pix = column.load()
    for y in range(height):
        t = y / (height - 1)
        pix[0, y] = tuple(round(a + (b - a) * t) for a, b in zip(top, bottom))
    return column.resize((width, height), Image.Resampling.BILINEAR)


FACES = ["ibu-wayan", "pak-agus", "bu-ketut", "putu", "mbok-kadek", "bu-sari", "bli-made", "mbak-rina", "pak-nyoman", "kak-dewi"]


def neighbours(canvas, cy, left, right, height):
    """The cast on either side of the name, gently staggered, on cream discs."""
    from PIL import ImageFilter
    size = int(height * 0.2)
    gap = int(size * 0.18)
    half = len(FACES) // 2
    for side, names in ((-1, FACES[:half]), (1, FACES[half:])):
        for i, name in enumerate(names):
            face = Image.open(ROOT.parent / "site" / "assets" / f"face-{name}.png").convert("RGBA").resize((size, size), Image.Resampling.LANCZOS)
            step = (i + 1) * (size + gap)
            x = int(left - step - gap) if side < 0 else int(right + gap + i * (size + gap) + gap)
            y = int(cy - size / 2 + (size * 0.22 if i % 2 else -size * 0.22))
            disc = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
            d = ImageDraw.Draw(disc)
            d.ellipse((x - 10, y + 6, x + size + 10, y + size + 26), fill=(60, 20, 8, 90))
            disc = disc.filter(ImageFilter.GaussianBlur(14))
            d = ImageDraw.Draw(disc)
            d.ellipse((x - 10, y - 10, x + size + 10, y + size + 10), fill=CREAM + (255,))
            base = canvas.convert("RGBA")
            base.alpha_composite(disc)
            base.alpha_composite(face, (x, y))
            canvas.paste(base.convert("RGB"))


def render(width, height, safe, out, text_size):
    canvas = field(width, height)
    word = "Learn Bahasa"
    face = font(text_size)
    draw = ImageDraw.Draw(canvas)
    bbox = draw.textbbox((0, 0), word, font=face)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    sx, sy, sw, sh = safe
    x = sx + (sw - tw) / 2 - bbox[0]
    y = sy + (sh - th) / 2 - bbox[1]
    draw.text((x, y), word, font=face, fill=CREAM)
    neighbours(canvas, sy + sh / 2, x + bbox[0] - 60, x + bbox[0] + tw + 60, height)

    left = x + bbox[0]
    top = y + bbox[1]
    assert sx <= left and left + tw <= sx + sw, (left, tw, sx, sw)
    assert sy <= top and top + th <= sy + sh, (top, th, sy, sh)

    out.parent.mkdir(exist_ok=True)
    canvas.save(out, "PNG", optimize=True)
    print(out.name, canvas.size, canvas.mode, "word", tw, th)


def main():
    render(*HEADER, 200)
    render(*SEARCH, 320)


if __name__ == "__main__":
    main()
