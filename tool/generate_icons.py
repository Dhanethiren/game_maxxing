#!/usr/bin/env python3
"""Draws the Calm Grid app icon and Play Store graphics from scratch.

Outputs
  android/app/src/main/res/mipmap-*/ic_launcher.png        legacy icons
  android/app/src/main/res/mipmap-*/ic_launcher_foreground.png  adaptive icon layer
  android/app/src/main/res/mipmap-*/ic_launcher_monochrome.png  Android 13 themed icon
  android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
  android/app/src/main/res/values/ic_launcher_background.xml
  ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png       all iOS sizes (no alpha)
  store/icon-512.png             Play Store icon (32-bit PNG)
  store/feature-graphic.png      Play Store feature graphic (1024x500, no alpha)

Usage:  python3 tool/generate_icons.py    (needs Pillow)
"""

import json
import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.join(os.path.dirname(__file__), '..')
RES = os.path.join(ROOT, 'android', 'app', 'src', 'main', 'res')
IOS = os.path.join(ROOT, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
STORE = os.path.join(ROOT, 'store')

BG_TOP = (233, 228, 247)
BG_BOTTOM = (221, 241, 236)
ACCENT = (142, 124, 195)
BLOCKS = [(127, 183, 232), (143, 203, 158), (244, 177, 131), (232, 160, 191),
          (178, 161, 230), (240, 205, 110), (114, 204, 195)]
# The logo: (row, col, colour) on a 3x3 grid, same as the in-app logo.
LOGO = [(0, 0, 0), (0, 1, 0), (1, 1, 4), (1, 2, 2), (2, 0, 1), (2, 1, 3), (2, 2, 6)]

SS = 4  # supersampling for smooth edges


def soft_layer(size, shapes, color, radius):
    """Solid [color] whose alpha is the blurred union of [shapes].

    Blurring the alpha only (instead of an RGBA image) avoids the grey fringes
    that transparent-black pixels would otherwise bleed into the edges."""
    mask = Image.new('L', size, 0)
    d = ImageDraw.Draw(mask)
    for draw in shapes:
        draw(d)
    mask = mask.filter(ImageFilter.GaussianBlur(radius))
    layer = Image.new('RGBA', size, color + (0,))
    layer.putalpha(mask.point(lambda v: int(v * color_alpha(color))))
    return layer


def color_alpha(color):
    return 1.0


def resize(img, size):
    """High-quality resize of an RGBA image without dark edge fringes."""
    return img.convert('RGBa').resize(size, Image.LANCZOS).convert('RGBA')


def shade(c, d):
    return tuple(max(0, min(255, int(v + d))) for v in c)


def gradient(size, top, bottom):
    w, h = size
    img = Image.new('RGB', size)
    px = img.load()
    for y in range(h):
        t = y / max(1, h - 1)
        col = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
        for x in range(w):
            px[x, y] = col
    return img


def block(size, color):
    """One glossy block (RGBA, size x size) matching the in-game BlockArt."""
    s = size
    img = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    r = int(s * 0.22)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([0, 0, s - 1, s - 1], r, fill=shade(color, -34) + (255,))
    face_h = int(s * 0.91)
    face = gradient((s, face_h), shade(color, 22), color).convert('RGBA')
    mask = Image.new('L', (s, face_h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, s - 1, face_h - 1], r, fill=255)
    img.paste(face, (0, 0), mask)
    gloss = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    ImageDraw.Draw(gloss).rounded_rectangle(
        [int(s * 0.16), int(s * 0.1), int(s * 0.84), int(s * 0.3)], int(s * 0.1),
        fill=(255, 255, 255, 82))
    return Image.alpha_composite(img, gloss)


def logo(size, mono=False):
    """The 3x3 block cluster on a transparent background, with soft shadows."""
    s = size * SS
    img = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    cell = s / 3
    gap = cell * 0.08
    def shadow_shape(r, c):
        x, y = c * cell + gap / 2, r * cell + gap / 2 + cell * 0.07
        return lambda d: d.rounded_rectangle([x, y, x + cell - gap, y + cell - gap],
                                             cell * 0.22, fill=70)
    img = Image.alpha_composite(
        img, soft_layer((s, s), [shadow_shape(r, c) for r, c, _ in LOGO], (70, 50, 120), cell * 0.06))
    for r, c, k in LOGO:
        b = block(int(cell - gap), (255, 255, 255) if mono else BLOCKS[k])
        if mono:  # Android 13 themed icons: a plain white silhouette
            white = Image.new('RGB', b.size, (255, 255, 255))
            b = Image.merge('RGBA', (*white.split(), b.getchannel('A')))
        img.alpha_composite(b, (int(c * cell + gap / 2), int(r * cell + gap / 2)))
    return resize(img, (size, size))


def full_icon(size, rounded=False):
    """Square icon: gradient background + centred logo."""
    s = size * SS
    bg = gradient((s, s), BG_TOP, BG_BOTTOM).convert('RGBA')
    # Soft glow behind the logo for depth.
    bg = Image.alpha_composite(bg, soft_layer(
        (s, s), [lambda d: d.ellipse([s * 0.14, s * 0.12, s * 0.86, s * 0.84], fill=150)],
        (255, 255, 255), s * 0.08))
    lg = resize(logo(int(size * 0.62)), (int(s * 0.62), int(s * 0.62)))
    bg.alpha_composite(lg, (int(s * 0.19), int(s * 0.18)))
    if rounded:
        mask = Image.new('L', (s, s), 0)
        ImageDraw.Draw(mask).rounded_rectangle([0, 0, s - 1, s - 1], s * 0.22, fill=255)
        bg.putalpha(mask)
    return resize(bg, (size, size))


def write_android():
    densities = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
    for name, k in densities.items():
        folder = os.path.join(RES, f'mipmap-{name}')
        os.makedirs(folder, exist_ok=True)
        full_icon(int(48 * k), rounded=True).save(os.path.join(folder, 'ic_launcher.png'))
        # Adaptive layers are 108dp; artwork stays in the central 66dp safe zone.
        fg_size = int(108 * k)
        for mono in (False, True):
            canvas = Image.new('RGBA', (fg_size, fg_size), (0, 0, 0, 0))
            art = logo(int(fg_size * 0.5), mono=mono)
            canvas.alpha_composite(art, (int(fg_size * 0.25), int(fg_size * 0.24)))
            suffix = 'monochrome' if mono else 'foreground'
            canvas.save(os.path.join(folder, f'ic_launcher_{suffix}.png'))
    anydpi = os.path.join(RES, 'mipmap-anydpi-v26')
    os.makedirs(anydpi, exist_ok=True)
    with open(os.path.join(anydpi, 'ic_launcher.xml'), 'w') as f:
        f.write('<?xml version="1.0" encoding="utf-8"?>\n'
                '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
                '    <background android:drawable="@color/ic_launcher_background"/>\n'
                '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
                '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>\n'
                '</adaptive-icon>\n')
    with open(os.path.join(RES, 'values', 'ic_launcher_background.xml'), 'w') as f:
        f.write('<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
                '    <color name="ic_launcher_background">#E6E6F6</color>\n</resources>\n')


def write_ios():
    with open(os.path.join(IOS, 'Contents.json')) as f:
        contents = json.load(f)
    for image in contents['images']:
        name = image.get('filename')
        if not name:
            continue
        pts = float(image['size'].split('x')[0])
        scale = int(image['scale'].rstrip('x'))
        px = int(round(pts * scale))
        # Apple requires opaque icons (no alpha channel).
        full_icon(px).convert('RGB').save(os.path.join(IOS, name))


def write_store():
    os.makedirs(STORE, exist_ok=True)
    full_icon(512).save(os.path.join(STORE, 'icon-512.png'))

    w, h = 1024, 500
    g = gradient((w * 2, h * 2), BG_TOP, BG_BOTTOM).convert('RGBA')
    for (cx, cy, rad, col, a) in [(400, 500, 380, (255, 255, 255), 170),
                                  (1750, 200, 260, BLOCKS[4], 70),
                                  (1500, 900, 300, BLOCKS[6], 60),
                                  (120, 950, 220, BLOCKS[3], 55)]:
        g = Image.alpha_composite(g, soft_layer(
            g.size, [lambda d, cx=cx, cy=cy, rad=rad, a=a: d.ellipse(
                [cx - rad, cy - rad, cx + rad, cy + rad], fill=a)], col, 90))
    lg = logo(560)
    g.alpha_composite(lg, (170, 220))
    font_dir = '/usr/share/fonts/opentype/inter'
    title = ImageFont.truetype(os.path.join(font_dir, 'Inter-ExtraBold.otf'), 176)
    tag = ImageFont.truetype(os.path.join(font_dir, 'Inter-Medium.otf'), 72)
    d = ImageDraw.Draw(g)
    d.text((862, 352), 'Calm Grid', font=title, fill=(255, 255, 255, 160))
    d.text((860, 344), 'Calm Grid', font=title, fill=(74, 74, 104, 255))
    d.text((866, 584), 'Relax. Place. Clear.', font=tag, fill=(138, 138, 166, 255))
    resize(g, (w, h)).convert('RGB').save(os.path.join(STORE, 'feature-graphic.png'))


if __name__ == '__main__':
    write_android()
    write_ios()
    write_store()
    print('Icons and store graphics written.')
