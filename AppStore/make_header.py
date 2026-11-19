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


def render(width, height, safe, out, text_size):
    canvas = field(width, height)
    word = "Bahasa"
    face = font(text_size)
    draw = ImageDraw.Draw(canvas)
    bbox = draw.textbbox((0, 0), word, font=face)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    sx, sy, sw, sh = safe
    x = sx + (sw - tw) / 2 - bbox[0]
    y = sy + (sh - th) / 2 - bbox[1]
    draw.text((x, y), word, font=face, fill=CREAM)

    left = x + bbox[0]
    top = y + bbox[1]
    assert sx <= left and left + tw <= sx + sw, (left, tw, sx, sw)
    assert sy <= top and top + th <= sy + sh, (top, th, sy, sh)

    out.parent.mkdir(exist_ok=True)
    canvas.save(out, "PNG", optimize=True)
    print(out.name, canvas.size, canvas.mode, "word", tw, th)


def main():
    render(*HEADER, 340)
    render(*SEARCH, 600)


if __name__ == "__main__":
    main()
