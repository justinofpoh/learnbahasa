#!/usr/bin/env python3
"""App Store product pages (2026): real screens from screenshots-2026/, set on the app's palette,
with an eyebrow, a two-line New York headline and a faint kawung corner. Run make_header.py for the header."""

from pathlib import Path

from PIL import Image, ImageDraw

from make_product_screens import CREAM, H, W, kawung, ny, paste_phone, rounded_font, tracked

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "screenshots-2026"
OUT = ROOT / "product-2026"            # 6.9" (1320 x 2868)
OUT63 = ROOT / "product-2026-63"       # 6.3" (1206 x 2622)

SCREENS = [
    ("01-talk", (196, 69, 34), "LEARN BAHASA", ["Indonesian for", "your Bali trip."], True),
    ("04-chat", (92, 64, 46), "NGOBROL", ["Ibu Wayan asks.", "You answer."], False),
    ("08-pasar", (36, 48, 86), "12 NEIGHBOURS", ["Real places.", "Real replies."], True),
    ("07-lesson", (24, 92, 104), "POLA", ["See how a", "sentence works."], False),
    ("03-learn", (176, 118, 20), "11 STAGES", ["Five minutes", "a day."], True),
    ("05-phrases", (32, 96, 70), "FRASA", ["Hear it before", "you need it."], True),
    ("06-patterns", (122, 40, 74), "TATA BAHASA", ["Every rule,", "in one place."], True),
]


def make(name, bg, eyebrow, title, bleed):
    canvas = Image.new("RGBA", (W, H), bg + (255,))
    kawung(canvas, CREAM, 34, (W - 300, 40), cell=92, cols=4, rows=4)
    draw = ImageDraw.Draw(canvas)
    margin = 84
    # Eyebrow: a small cream pill, tracked capitals.
    face = rounded_font(38)
    width = sum(face.getlength(ch) + 6 for ch in eyebrow) + 52
    pill = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(pill).rounded_rectangle((margin, 140, margin + width, 204), radius=32,
                                           fill=CREAM[:3] + (36,), outline=CREAM[:3] + (130,), width=2)
    canvas.alpha_composite(pill)
    tracked(draw, (margin + 26, 150), eyebrow, face, CREAM, 6)
    y = 248
    title_font = ny(124, 700)
    for line in title:
        draw.text((margin, y), line, font=title_font, fill=CREAM)
        y += 136
    shot = Image.open(SRC / f"{name}.png")
    paste_phone(canvas, shot, top=560, bleed=bleed, bottom=96)
    if bleed:
        fade = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
        fd = ImageDraw.Draw(fade)
        for i in range(220):
            t = i / 219
            fd.line((0, H - 220 + i, W, H - 220 + i), fill=bg + (int(255 * t * t),))
        canvas.alpha_composite(fade)
    return canvas.convert("RGB")


def main():
    OUT.mkdir(exist_ok=True)
    OUT63.mkdir(exist_ok=True)
    for i, spec in enumerate(SCREENS, 1):
        image = make(*spec)
        file = f"{i:02d}-{spec[0][3:]}.png"
        image.save(OUT / file, "PNG", optimize=True)
        image.resize((1206, 2622), Image.Resampling.LANCZOS).save(OUT63 / file, "PNG", optimize=True)
        print(file)


if __name__ == "__main__":
    main()
