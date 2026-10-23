#!/usr/bin/env python3
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ADDON_DIR = ROOT / "addons" / "terrain_asset_painter"
OUT_ZIP = ROOT / "terrain_asset_painter_addon.zip"

if not ADDON_DIR.exists():
    raise FileNotFoundError(f"Addon directory not found: {ADDON_DIR}")

with zipfile.ZipFile(OUT_ZIP, "w", compression=zipfile.ZIP_DEFLATED) as zf:
    for path in sorted(ADDON_DIR.rglob("*")):
        if path.is_dir():
            continue
        arcname = path.relative_to(ROOT)
        zf.write(path, arcname)

print(f"Created: {OUT_ZIP}")
print("Extract this ZIP into your Godot project root so it creates: addons/terrain_asset_painter/")
