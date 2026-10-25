#!/usr/bin/env python3
"""Build Woodcaller pixel-art assets from staged CC0 sources.

Reads source PNGs from a staging directory (downloaded CC0 packs) and writes
processed 32x32 RGBA frames into assets/art/<entity>/ for AnimatedSprite2D.

Usage:
    python3 -I tools/build_art.py [staging_dir]

Default staging dir: /tmp/woodcaller-assets-staging
Sources and licenses are registered in Woodcaller_Project_Log.md and
assets/ART_CREDITS.md; this script only performs CC0-permitted derivatives
(hue/saturation tweaks and 1px bob frames).
"""
from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image, ImageEnhance

ROOT = Path(__file__).resolve().parents[1]
STAGING = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/tmp/woodcaller-assets-staging")
DCSS = STAGING / "dcss" / "Dungeon Crawl Stone Soup Full"
SLIME_SHEET = STAGING / "slime" / "slime-Sheet.png"
OUT = ROOT / "assets" / "art"
TILE = 32


def load_rgba(path: Path) -> Image.Image:
    if not path.is_file():
        raise FileNotFoundError(f"missing source: {path}")
    return Image.open(path).convert("RGBA")


def save(img: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if img.size != (TILE, TILE):
        raise ValueError(f"{path.name} is {img.size}, expected {(TILE, TILE)}")
    img.save(path)
    print(f"wrote {path.relative_to(ROOT)}")


def shift_pixels(img: Image.Image, dx: int, dy: int) -> Image.Image:
    """Shift opaque content inside the same 32x32 canvas; fill transparent."""
    moved = Image.new("RGBA", img.size, (0, 0, 0, 0))
    moved.paste(img, (dx, dy), img)
    return moved


def slice_sheet(sheet: Image.Image, count: int) -> list[Image.Image]:
    cols = sheet.width // TILE
    frames: list[Image.Image] = []
    for i in range(count):
        x = (i % cols) * TILE
        y = (i // cols) * TILE
        frames.append(sheet.crop((x, y, x + TILE, y + TILE)))
    return frames


def mute(img: Image.Image, color: float = 0.55, brightness: float = 0.92) -> Image.Image:
    """Lower saturation and brightness to match the dark-forest palette."""
    return ImageEnhance.Brightness(ImageEnhance.Color(img).enhance(color)).enhance(brightness)


def recolor_to_hue(img: Image.Image, target_deg: float) -> Image.Image:
    """Rotate saturated pixels so the dominant hue lands on target_deg (0-360)."""
    hsv = img.convert("HSV")
    h, s, v = hsv.split()
    sat_mask = s.point(lambda value: 255 if value >= 80 else 0)
    hist = h.histogram(mask=sat_mask)
    if sum(hist) == 0:
        return img
    dominant = max(range(256), key=lambda i: hist[i])
    delta = (round(target_deg / 360 * 255) - dominant) % 256
    h = h.point([(i + delta) % 256 for i in range(256)])
    out = Image.merge("HSV", (h, s, v)).convert("RGBA")
    out.putalpha(img.getchannel("A"))
    return out


def brighten(img: Image.Image, factor: float = 1.25) -> Image.Image:
    return ImageEnhance.Brightness(img).enhance(factor)


def bob_frames(base: Image.Image, amount: int = 1) -> dict[str, list[Image.Image]]:
    """Derive minimal idle/walk loops from a static 32x32 sprite."""
    return {
        "idle": [base, shift_pixels(base, 0, amount)],
        "walk": [base, shift_pixels(base, 0, -amount)],
    }


def emit(entity: str, name_prefix: str, anims: dict[str, list[Image.Image]]) -> None:
    for anim, frames in anims.items():
        for idx, frame in enumerate(frames):
            save(frame, OUT / entity / f"{name_prefix}_{anim}_{idx}.png")


def main() -> None:
    if not DCSS.is_dir() or not SLIME_SHEET.is_file():
        raise SystemExit(f"staging sources not found under {STAGING}")

    # Player: spriggan druid (DCSS, CC0)
    player = load_rgba(DCSS / "monster" / "spriggan" / "spriggan_druid.png")
    emit("player", "druid", bob_frames(player))

    # Summon: wolf (DCSS, CC0)
    wolf = load_rgba(DCSS / "monster" / "animals" / "wolf.png")
    emit("summons", "wolf", bob_frames(wolf))

    # Boss: treant (DCSS, CC0), palette-indexed source handled by convert
    treant = load_rgba(DCSS / "monster" / "fungi_plants" / "treant.png")
    emit("bosses", "treant", bob_frames(treant))

    # Enemy: animated slime (CC0 pack), muted toward the forest palette
    sheet = load_rgba(SLIME_SHEET)
    frames = [mute(f) for f in slice_sheet(sheet, 16)]
    emit("enemies", "slime", {
        "idle": [frames[0], frames[1], frames[2], frames[1]],
        "walk": [frames[4], frames[6], frames[8], frames[10]],
    })

    # Experience orb: crystal (DCSS, CC0) hue-shifted to green, 2-frame pulse
    crystal = load_rgba(DCSS / "item" / "misc" / "misc_crystal_new.png")
    green = recolor_to_hue(crystal, 120.0)
    emit("pickups", "exp_orb", {"idle": [green, brighten(green)]})

    build_arena_terrain()


def build_arena_terrain() -> None:
    """Composite the 640x360 arena floor and the 48x80 tree obstacle."""
    import random

    dungeon = DCSS / "dungeon"
    base = load_rgba(dungeon / "floor" / "moss_0.png")  # (3,26,0) dark green
    variants = [
        (load_rgba(dungeon / "floor" / "bog_green_0_new.png"), 0.14),  # near-black green
        (load_rgba(dungeon / "floor" / "grass" / "grass_0_new.png"), 0.10),  # mid green
        (load_rgba(dungeon / "floor" / "dirt_0_new.png"), 0.02),  # rare tan patch
        (load_rgba(dungeon / "floor" / "grass" / "grass_flowers_blue_1_new.png"), 0.008),
    ]
    rng = random.Random(20261025)
    floor = Image.new("RGBA", (640, 360))
    for ty in range(0, 360, TILE):
        for tx in range(0, 640, TILE):
            tile = base
            roll = rng.random()
            for variant, chance in variants:
                if roll < chance:
                    tile = variant
                    break
                roll -= chance
            floor.paste(tile, (tx, ty), tile)
    # Lift the very dark base slightly, then frame the 16px out-of-play border.
    floor = ImageEnhance.Brightness(floor).enhance(1.35)
    floor = ImageEnhance.Color(floor).enhance(0.9)
    shade = Image.new("RGBA", (640, 360), (0, 0, 0, 0))
    from PIL import ImageDraw

    draw = ImageDraw.Draw(shade)
    for rect in [(0, 0, 640, 16), (0, 344, 640, 360), (0, 0, 16, 360), (624, 0, 640, 360)]:
        draw.rectangle(rect, fill=(4, 8, 6, 170))
    floor = Image.alpha_composite(floor, shade)
    out = OUT / "arena" / "floor.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    floor.save(out)
    print(f"wrote {out.relative_to(ROOT)}")

    # Obstacle: two dark mangrove canopies stacked over a shared trunk block.
    tree = load_rgba(dungeon / "trees" / "mangrove_1.png")
    canopy = tree.resize((48, 48), Image.NEAREST)
    obstacle = Image.new("RGBA", (48, 80), (0, 0, 0, 0))
    lower = canopy.crop((0, 16, 48, 48))
    obstacle.paste(lower, (0, 48), lower)
    obstacle.paste(canopy, (0, 0), canopy)
    obstacle = ImageEnhance.Brightness(obstacle).enhance(0.85)
    obstacle.save(OUT / "arena" / "obstacle_tree.png")
    print(f"wrote {(OUT / 'arena' / 'obstacle_tree.png').relative_to(ROOT)}")


if __name__ == "__main__":
    main()
