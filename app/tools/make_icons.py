#!/usr/bin/env python3
"""Generates the Ashelf launcher icon and splash logos (needs Pillow).
Run from the app/ folder:  python tools/make_icons.py"""
from PIL import Image, ImageDraw
import os

OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'icon')
os.makedirs(OUT, exist_ok=True)

BG = (20, 19, 15, 255)  # graphite #14130F
DARK_PALETTE = dict(books=[(212, 167, 60), (244, 238, 223), (138, 106, 61), (230, 196, 110), (244, 238, 223)],
                    band=(20, 19, 15), plank=(244, 238, 223))
LIGHT_PALETTE = dict(books=[(43, 38, 32), (138, 106, 61), (201, 151, 43), (90, 70, 48), (166, 129, 47)],
                     band=(247, 242, 233), plank=(43, 38, 32))

WIDTHS = [74, 60, 84, 66, 78]
HEIGHTS = [300, 380, 340, 420, 330]
GAP = 14
SS = 2  # supersampling


def mark(size, pal, bg=None):
    """Five books on a shelf, centred inside the Android safe zone."""
    s = size * SS / 1024
    img = Image.new('RGBA', (size * SS, size * SS), bg or (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    total = sum(WIDTHS) + GAP * (len(WIDTHS) - 1)
    x = 512 - total / 2
    base = 708
    for w, h, c in zip(WIDTHS, HEIGHTS, pal['books']):
        top = base - h
        d.rounded_rectangle([x * s, top * s, (x + w) * s, base * s], radius=10 * s, fill=c + (255,))
        for off in (38, 58):  # spine bands
            d.rectangle([x * s, (top + off) * s, (x + w) * s, (top + off + 8) * s], fill=pal['band'] + (255,))
        x += w + GAP
    d.rounded_rectangle([272 * s, base * s, 752 * s, (base + 32) * s], radius=8 * s, fill=pal['plank'] + (255,))
    return img.resize((size, size), Image.LANCZOS)


mark(1024, DARK_PALETTE, bg=BG).convert('RGB').save(f'{OUT}/icon.png')
mark(1024, DARK_PALETTE).save(f'{OUT}/icon_foreground.png')
mark(1152, LIGHT_PALETTE).save(f'{OUT}/splash_logo.png')
mark(1152, DARK_PALETTE).save(f'{OUT}/splash_logo_dark.png')
print('Icons written to', os.path.abspath(OUT))
