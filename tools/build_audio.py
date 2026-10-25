#!/usr/bin/env python3
"""Copy selected CC0 audio from the staging directory into assets/audio/.

Sources (registered in Woodcaller_Project_Log.md and assets/ART_CREDITS.md):
- Juhani Junkala "The Essential Retro Video Game Sound Effects Collection" (CC0)
- beardalea "Dark Woods Loop" dark_woods_in_game.ogg (CC0)

Usage:
    python3 -I tools/build_audio.py [staging_dir]
"""
from __future__ import annotations

import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STAGING = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/tmp/woodcaller-assets-staging")
SFX_ROOT = STAGING / "sfx512" / "The Essential Retro Video Game Sound Effects Collection [512 sounds] By Juhani Junkala"
OUT = ROOT / "assets" / "audio"

# game event name -> source file inside the 512-sounds pack
SFX_MAP = {
    "attack": "Weapons/Melee/sfx_wpn_punch1.wav",
    "enemy_die": "Death Screams/Alien/sfx_deathscream_alien1.wav",
    "pickup": "General Sounds/Coins/sfx_coin_cluster1.wav",
    "levelup": "General Sounds/Positive Sounds/sfx_sounds_powerup2.wav",
    "hurt": "General Sounds/Negative Sounds/sfx_sounds_damage1.wav",
    "win": "General Sounds/Fanfares/sfx_sounds_fanfare1.wav",
    "lose": "General Sounds/Negative Sounds/sfx_sounds_negative1.wav",
    "ui_click": "General Sounds/Menu Sounds/sfx_menu_select1.wav",
}

MUSIC_MAP = {
    "dark_woods.ogg": STAGING / "dark_woods_in_game.ogg",
}


def main() -> None:
    for name, relative in SFX_MAP.items():
        source = SFX_ROOT / relative
        if not source.is_file():
            raise FileNotFoundError(f"missing sfx source: {source}")
        target = OUT / "sfx" / f"{name}.wav"
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        print(f"wrote {target.relative_to(ROOT)}")
    for name, source in MUSIC_MAP.items():
        if not source.is_file():
            raise FileNotFoundError(f"missing music source: {source}")
        target = OUT / "music" / name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        print(f"wrote {target.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
