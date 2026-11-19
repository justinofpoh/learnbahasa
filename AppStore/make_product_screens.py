#!/usr/bin/env python3
"""Editorial App Store frames for Bahasa. Real UI, set on the app's palette."""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "screenshots"
SRC63 = ROOT / "screenshots-63"
OUT = ROOT / "product"
OUT63 = ROOT / "product-63"

W, H = 1320, 2868
CREAM = (246, 241, 232, 255)
CREAM_SOFT = (246, 241, 232, 210)

NY = "/System/Library/Fonts/NewYork.ttf"
SANS = "/Library/Fonts/SF-Pro-Display-Medium.otf"
ROUNDED = "/Library/Fonts/SF-Pro-Rounded-Semibold.otf"


def ny(size, weight=640):
    font = ImageFont.truetype(NY, size)
    # Optical size, weight, grade. Large sizes want the biggest optical size.
    font.set_variation_by_axes([256, weight, 0])
    return font


def sans(size):
    return ImageFont.truetype(SANS, size)


def rounded_font(size):
    return ImageFont.truetype(ROUNDED, size)


def tracked(draw, xy, text, font, fill, tracking):
    x, y = xy
    for ch in text:
        draw.text((x, y), ch, font=font, fill=fill)
        x += font.getlength(ch) + tracking
    return x


def kawung(base, color, alpha, origin, cell=86, cols=4, rows=3):
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    ox, oy = origin
    stroke = (*color[:3], alpha)
    for r in range(rows):
        for c in range(cols):
            x = ox + c * cell + (cell / 2 if r % 2 else 0)
            y = oy + r * cell * 0.82
            petals = [
                (-cell * 0.20, 0, cell * 0.30, cell * 0.50),
                (cell * 0.20, 0, cell * 0.30, cell * 0.50),
                (0, -cell * 0.20, cell * 0.50, cell * 0.30),
                (0, cell * 0.20, cell * 0.50, cell * 0.30),
            ]
            for dx, dy, w, h in petals:
                box = (x + dx - w / 2, y + dy - h / 2, x + dx + w / 2, y + dy + h / 2)
                draw.ellipse(box, outline=stroke, width=2)
            dot = cell * 0.045
            draw.ellipse((x - dot, y - dot, x + dot, y + dot), fill=stroke)
    base.alpha_composite(layer)


def fit_width(im, width):
    scale = width / im.width
    height = round(im.height * scale)
    return im.resize((width, height), Image.Resampling.LANCZOS)


def round_mask(size, radius, corners="all"):
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size[0], size[1]), radius=radius, fill=255)
    if corners == "top":
        # Square off the bottom so a bleeding phone stays sharp at the cut.
        draw.rectangle((0, size[1] - radius - 2, size[0], size[1]), fill=255)
    return mask


def paste_phone(canvas, shot, top, side=72, bezel=18, radius=72, bleed=True, bottom=80):
    inner_w = W - side * 2 - bezel * 2
    screen = fit_width(shot.convert("RGBA"), inner_w)
    if not bleed:
        max_h = H - top - bottom - bezel * 2
        if screen.height > max_h:
            scale = max_h / screen.height
            screen = screen.resize(
                (round(screen.width * scale), max_h), Image.Resampling.LANCZOS
            )
            inner_w = screen.width
    frame_w = inner_w + bezel * 2
    frame_h = screen.height + bezel * 2
    x = (W - frame_w) // 2
    y = top

    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle(
        (x + 10, y + 28, x + frame_w - 6, y + frame_h + 10),
        radius=radius,
        fill=(29, 18, 12, 70),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(36))
    canvas.alpha_composite(shadow)

    frame = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    fd = ImageDraw.Draw(frame)
    fd.rounded_rectangle((x, y, x + frame_w, y + frame_h), radius=radius, fill=CREAM)
    canvas.alpha_composite(frame)

    screen_pos = (x + bezel, y + bezel)
    mask = round_mask(screen.size, radius - bezel + 4, "top" if bleed else "all")
    screen.putalpha(mask)
    canvas.alpha_composite(screen, screen_pos)


def make(spec, shot):
    canvas = Image.new("RGBA", (W, H), spec["bg"] + (255,))
    draw = ImageDraw.Draw(canvas)

    margin = 80
    y = 150
    title_font = ny(118, 700)
    for line in spec["title"]:
        draw.text((margin, y), line, font=title_font, fill=CREAM)
        y += 128

    paste_phone(
        canvas,
        shot,
        top=spec["top"],
        bleed=spec["bleed"],
        side=spec.get("side", 72),
        bottom=spec.get("bottom", 88),
    )
    if spec["bleed"]:
        fade = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
        fd = ImageDraw.Draw(fade)
        fade_h = 200
        for i in range(fade_h):
            t = i / (fade_h - 1)
            alpha = int(255 * t * t)
            y = H - fade_h + i
            fd.line((0, y, W, y), fill=spec["bg"] + (alpha,))
        canvas.alpha_composite(fade)
    return canvas.convert("RGB")


SCREENS = [
    {
        "file": "01-learn.png",
        "src": SRC63,
        "n": "01",
        "bg": (196, 69, 34),
        "eyebrow": "BELAJAR",
        "title": ["Greet the hour", "you're in."],
        "top": 520,
        "bleed": True,
    },
    {
        "file": "02-lesson.png",
        "src": SRC,
        "n": "02",
        "bg": (36, 48, 86),
        "eyebrow": "POLA",
        "title": ["A sentence", "has a shape."],
        "top": 480,
        "bleed": False,
    },
    {
        "file": "03-talk.png",
        "src": SRC,
        "n": "03",
        "bg": (62, 42, 32),
        "eyebrow": "NGOBROL",
        "title": ["Five places.", "Real replies."],
        "top": 520,
        "bleed": True,
    },
    {
        "file": "04-chat.png",
        "src": SRC,
        "n": "04",
        "bg": (92, 64, 46),
        "eyebrow": "JAWAB",
        "title": ["She speaks.", "You answer."],
        "top": 480,
        "bleed": False,
    },
    {
        "file": "05-patterns.png",
        "src": SRC,
        "n": "05",
        "bg": (24, 92, 104),
        "eyebrow": "TATA BAHASA",
        "title": ["Every rule,", "in one place."],
        "top": 520,
        "bleed": True,
    },
    {
        "file": "06-phrases.png",
        "src": SRC,
        "n": "06",
        "bg": (32, 96, 70),
        "eyebrow": "FRASA",
        "title": ["Hear it before", "you need it."],
        "top": 520,
        "bleed": True,
    },
]


def main():
    OUT.mkdir(exist_ok=True)
    OUT63.mkdir(exist_ok=True)
    for spec in SCREENS:
        shot = Image.open(spec["src"] / spec["file"])
        image = make(spec, shot)
        path = OUT / spec["file"]
        image.save(path, "PNG", optimize=True)
        small = image.resize((1206, 2622), Image.Resampling.LANCZOS)
        small.save(OUT63 / spec["file"], "PNG", optimize=True)
        print(path.name, image.size, small.size)


if __name__ == "__main__":
    main()
