#!/usr/bin/env python3
"""Embed the shipped art (game/assets/art/*.jpg) into builtin_pack.json's
optional art section (ADR-0008). Idempotent: re-runs refresh the base64.

    python3 scripts/embed_art.py
"""

import base64
import json
import pathlib

GAME = pathlib.Path(__file__).resolve().parent.parent / "game"
ART_DIR = GAME / "assets" / "art"
PACK_PATH = GAME / "engine" / "builtin_pack.json"

SECTIONS = {
    "portraits": {
        "hero": "hero", "tank": "tank", "healer": "healer",
        "mage": "mage", "striker": "striker", "archer": "archer",
    },
    "enemies": {
        "grunt": "enemy_grunt", "brute": "enemy_brute",
        "shaman": "enemy_shaman", "boss": "enemy_boss",
    },
    "backgrounds": {"tavern": "bg_tavern", "sea": "bg_sea", "deck": "bg_deck"},
}


def b64(file_stem: str) -> str:
    return base64.b64encode((ART_DIR / f"{file_stem}.jpg").read_bytes()).decode()


def main() -> None:
    pack = json.loads(PACK_PATH.read_text())
    pack["art"] = {
        section: {pack_id: b64(file_stem) for pack_id, file_stem in names.items()}
        for section, names in SECTIONS.items()
    }
    PACK_PATH.write_text(json.dumps(pack, ensure_ascii=False, indent="\t") + "\n")
    print(f"embedded art into {PACK_PATH.name}: {PACK_PATH.stat().st_size / 1e6:.1f} MB")


if __name__ == "__main__":
    main()
