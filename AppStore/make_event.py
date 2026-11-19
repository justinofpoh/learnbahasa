#!/usr/bin/env python3
"""In-app event art. Kawung on sambal, no type: the App Store draws the name."""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent / "event"
SAMBAL = (212, 81, 42)
DEEP = (154, 48, 22)
CREAM = (246, 241, 232, 255)


def field(width, height):
    column = Image.new("RGB", (1, height))
    pix = column.load()
    for y in range(height):
        t = (y / (height - 1)) ** 1.4
        pix[0, y] = tuple(round(a + (b - a) * t) for a, b in zip(SAMBAL, DEEP))
    return column.resize((width, height), Image.Resampling.BILINEAR)


def kawung(draw, origin, cell):
    x, y = origin
    stroke = CREAM
    width = max(4, int(cell * 0.028))
    petals = [
        (-cell * 0.20, 0, cell * 0.30, cell * 0.50),
        (cell * 0.20, 0, cell * 0.30, cell * 0.50),
        (0, -cell * 0.20, cell * 0.50, cell * 0.30),
        (0, cell * 0.20, cell * 0.50, cell * 0.30),
    ]
    for dx, dy, w, h in petals:
        box = (x + dx - w / 2, y + dy - h / 2, x + dx + w / 2, y + dy + h / 2)
        draw.ellipse(box, outline=stroke, width=width)
    dot = cell * 0.045
    draw.ellipse((x - dot, y - dot, x + dot, y + dot), fill=stroke)


def render(width, height, cell, name):
    from PIL import ImageChops

    canvas = field(width, height).convert("RGBA")
    layer = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    rows = int(height / (cell * 0.82)) + 3
    cols = int(width / cell) + 3
    for r in range(-1, rows):
        for c in range(-1, cols):
            x = c * cell + (cell / 2 if abs(r) % 2 else 0)
            y = r * cell * 0.82
            kawung(draw, (x, y), cell)
    # The store lays the name across the bottom. Ease the motif off there.
    fade = Image.new("L", (1, height))
    fp = fade.load()
    for y in range(height):
        t = y / (height - 1)
        fp[0, y] = 255 if t < 0.58 else round(255 - (t - 0.58) / 0.42 * 170)
    alpha = ImageChops.multiply(layer.getchannel("A"), fade.resize((width, height)))
    layer.putalpha(alpha)
    canvas.alpha_composite(layer)
    out = canvas.convert("RGB")
    ROOT.mkdir(exist_ok=True)
    path = ROOT / name
    out.save(path, "PNG", optimize=True)
    print(path.name, out.size, out.mode, path.stat().st_size)


def main():
    render(3840, 2160, 460, "Event Card 3840x2160.png")
    render(2160, 3840, 460, "Event Details 2160x3840.png")


if __name__ == "__main__":
    main()
