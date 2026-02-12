"""Generate Browseroo app icon and menu bar icon assets from a kangaroo silhouette.

The source image has a fake checkerboard "transparency" background baked in as
opaque gray pixels. The kangaroo itself is white (~254). We extract the silhouette
by thresholding on brightness.
"""

import sys
from pathlib import Path
from PIL import Image, ImageDraw

PROJECT = Path(__file__).resolve().parent.parent
SOURCE = PROJECT / "Gemini_Generated_Image_fbphjjfbphjjfbph.png"
APP_ICON_DIR = PROJECT / "Browseroo" / "Assets.xcassets" / "AppIcon.appiconset"
MENU_ICON_DIR = PROJECT / "Browseroo" / "Assets.xcassets" / "MenuBarIcon.imageset"

APP_ICON_SIZES = [16, 32, 64, 128, 256, 512, 1024]

COLOR_BOTTOM_LEFT = (26, 58, 138)   # #1a3a8a
COLOR_TOP_RIGHT = (0, 180, 216)     # #00b4d8

# Brightness threshold: pixels brighter than this are the kangaroo
BRIGHTNESS_THRESHOLD = 200


def create_gradient(size: int) -> Image.Image:
    """Create a diagonal gradient from bottom-left to top-right."""
    img = Image.new("RGBA", (size, size))
    for y in range(size):
        for x in range(size):
            t = (x + (size - 1 - y)) / (2 * (size - 1)) if size > 1 else 0.5
            r = int(COLOR_BOTTOM_LEFT[0] + t * (COLOR_TOP_RIGHT[0] - COLOR_BOTTOM_LEFT[0]))
            g = int(COLOR_BOTTOM_LEFT[1] + t * (COLOR_TOP_RIGHT[1] - COLOR_BOTTOM_LEFT[1]))
            b = int(COLOR_BOTTOM_LEFT[2] + t * (COLOR_TOP_RIGHT[2] - COLOR_BOTTOM_LEFT[2]))
            img.putpixel((x, y), (r, g, b, 255))
    return img


def extract_silhouette(img: Image.Image) -> Image.Image:
    """Extract the white kangaroo from the fake-transparency checkerboard background.

    Returns a white silhouette on a truly transparent background.
    """
    img = img.convert("RGBA")
    w, h = img.size
    result = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    src = img.load()
    dst = result.load()

    for y in range(h):
        for x in range(w):
            r, g, b, a = src[x, y]
            brightness = (r + g + b) / 3
            if brightness > BRIGHTNESS_THRESHOLD:
                dst[x, y] = (255, 255, 255, 255)

    # Remove watermark in bottom-right corner
    draw = ImageDraw.Draw(result)
    margin = int(w * 0.08)
    draw.rectangle([w - margin, h - margin, w, h], fill=(0, 0, 0, 0))

    return result


def generate_app_icons(silhouette: Image.Image):
    """Generate app icons at all required sizes."""
    APP_ICON_DIR.mkdir(parents=True, exist_ok=True)

    print("Creating gradient background and compositing...")
    base_size = 1024
    gradient = create_gradient(base_size)

    # Resize silhouette to fit with ~15% margin
    inner_size = int(base_size * 0.70)
    sil_resized = silhouette.resize((inner_size, inner_size), Image.LANCZOS)

    offset = (base_size - inner_size) // 2
    composite = gradient.copy()
    composite.paste(sil_resized, (offset, offset), sil_resized)

    for size in APP_ICON_SIZES:
        out = composite.resize((size, size), Image.LANCZOS)
        out_path = APP_ICON_DIR / f"icon_{size}.png"
        out.save(out_path)
        print(f"  {out_path.name} ({size}x{size})")


def generate_menu_bar_icons(silhouette: Image.Image):
    """Generate menu bar template icons (black on transparent).

    Crops to the silhouette bounding box so the kangaroo fills the icon frame,
    then pads to a square with a small margin.
    """
    MENU_ICON_DIR.mkdir(parents=True, exist_ok=True)

    # Convert white to black, keep alpha
    w, h = silhouette.size
    black_sil = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    src = silhouette.load()
    dst = black_sil.load()
    for y in range(h):
        for x in range(w):
            _, _, _, a = src[x, y]
            if a > 0:
                dst[x, y] = (0, 0, 0, a)

    # Crop to bounding box of non-transparent pixels
    bbox = black_sil.getbbox()
    if bbox:
        cropped = black_sil.crop(bbox)
    else:
        cropped = black_sil

    # Scale the kangaroo to 75% of the target height, keeping aspect ratio.
    for target_h, suffix in [(18, ""), (36, "@2x")]:
        cw, ch = cropped.size
        inner_h = round(target_h * 0.75)
        scale = inner_h / ch
        target_w = round(cw * scale)
        out = cropped.resize((target_w, inner_h), Image.LANCZOS)
        # Pad height back to target
        canvas = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
        canvas.paste(out, (0, (target_h - inner_h) // 2), out)
        out = canvas
        out_path = MENU_ICON_DIR / f"MenuBarIconTemplate{suffix}.png"
        out.save(out_path)
        print(f"  {out_path.name} ({target_w}x{target_h})")


def main():
    if not SOURCE.exists():
        print(f"Error: Source image not found at {SOURCE}")
        sys.exit(1)

    print(f"Loading: {SOURCE.name}")
    raw = Image.open(SOURCE).convert("RGBA")

    print("Extracting silhouette from checkerboard background...")
    silhouette = extract_silhouette(raw)

    print("\nApp icons:")
    generate_app_icons(silhouette)

    print("\nMenu bar icons:")
    generate_menu_bar_icons(silhouette)

    print("\nDone!")


if __name__ == "__main__":
    main()
