#!/usr/bin/env python3
"""Draw the Typing Tutor app icon and write the macOS iconset plus asset catalog."""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
ICONSET = ROOT / "App" / "Resources" / "AppIcon.iconset"
CATALOG = ROOT / "App" / "Resources" / "Assets.xcassets" / "AppIcon.appiconset"

CORAL = (232, 97, 77, 255)
CREAM = (255, 248, 236, 255)
INK = (42, 48, 60, 255)
SUN = (245, 192, 56, 255)
WHITE = (255, 255, 255, 255)


def rounded(draw, box, radius, fill):
    draw.rounded_rectangle(box, radius=radius, fill=fill)


def star(draw, cx, cy, r, fill):
    points = []
    for index in range(10):
        angle = -3.14159 / 2 + index * 3.14159 / 5
        radius = r if index % 2 == 0 else r * 0.42
        points.append((cx + radius * __import__("math").cos(angle), cy + radius * __import__("math").sin(angle)))
    draw.polygon(points, fill=fill)


def render(size: int) -> Image.Image:
    image = Image.new("RGBA", (size, size), CORAL)
    draw = ImageDraw.Draw(image)
    s = size
    # Keyboard body.
    rounded(draw, (0.14 * s, 0.30 * s, 0.86 * s, 0.80 * s), 0.06 * s, CREAM)
    keys = []
    for row, count, y in ((0, 4, 0.38), (1, 4, 0.52)):
        gap = 0.025 * s
        key_w = (0.62 * s - gap * (count - 1)) / count
        x = 0.19 * s
        for col in range(count):
            keys.append((x, y * s, x + key_w, y * s + 0.11 * s, row == 0 and col == 3))
            x += key_w + gap
    for left, top, right, bottom, highlighted in keys:
        rounded(draw, (left, top, right, bottom), 0.02 * s, SUN if highlighted else INK)
    rounded(draw, (0.28 * s, 0.66 * s, 0.72 * s, 0.75 * s), 0.02 * s, INK)
    star(draw, 0.74 * s, 0.24 * s, 0.11 * s, SUN)
    star(draw, 0.74 * s, 0.24 * s, 0.045 * s, WHITE)
    return image


def main():
    ICONSET.mkdir(parents=True, exist_ok=True)
    CATALOG.mkdir(parents=True, exist_ok=True)
    master = render(1024)
    sizes = {
        "icon_16x16.png": 16,
        "icon_16x16@2x.png": 32,
        "icon_32x32.png": 32,
        "icon_32x32@2x.png": 64,
        "icon_128x128.png": 128,
        "icon_128x128@2x.png": 256,
        "icon_256x256.png": 256,
        "icon_256x256@2x.png": 512,
        "icon_512x512.png": 512,
        "icon_512x512@2x.png": 1024,
    }
    for name, pixels in sizes.items():
        image = master if pixels == 1024 else master.resize((pixels, pixels), Image.Resampling.LANCZOS)
        image.save(ICONSET / name)
        image.save(CATALOG / name)
    contents = {
        "images": [
            {"size": "16x16", "idiom": "mac", "filename": "icon_16x16.png", "scale": "1x"},
            {"size": "16x16", "idiom": "mac", "filename": "icon_16x16@2x.png", "scale": "2x"},
            {"size": "32x32", "idiom": "mac", "filename": "icon_32x32.png", "scale": "1x"},
            {"size": "32x32", "idiom": "mac", "filename": "icon_32x32@2x.png", "scale": "2x"},
            {"size": "128x128", "idiom": "mac", "filename": "icon_128x128.png", "scale": "1x"},
            {"size": "128x128", "idiom": "mac", "filename": "icon_128x128@2x.png", "scale": "2x"},
            {"size": "256x256", "idiom": "mac", "filename": "icon_256x256.png", "scale": "1x"},
            {"size": "256x256", "idiom": "mac", "filename": "icon_256x256@2x.png", "scale": "2x"},
            {"size": "512x512", "idiom": "mac", "filename": "icon_512x512.png", "scale": "1x"},
            {"size": "512x512", "idiom": "mac", "filename": "icon_512x512@2x.png", "scale": "2x"},
        ],
        "info": {"version": 1, "author": "xcode"},
    }
    import json

    (CATALOG / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")
    (ROOT / "App" / "Resources" / "Assets.xcassets" / "Contents.json").write_text(
        json.dumps({"info": {"version": 1, "author": "xcode"}}, indent=2) + "\n"
    )


if __name__ == "__main__":
    main()
