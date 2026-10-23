# Terrain Asset Painter

This project is set up as a Godot add-on package. The add-on folder is:

addons/terrain_asset_painter/

## Install in Godot

Download this repository as a ZIP and extract it into the root of your Godot project so the path becomes:

- your_project/addons/terrain_asset_painter/

That is the correct layout for Godot 4.6.2. If you unzip directly into the `addons` folder, the final path should still be:

- your_project/addons/terrain_asset_painter/plugin.gd

## Build a zip for distribution

You can also make a zip file that is ready to extract into your Godot project root:

```bash
python3 tools/build_addon_zip.py
```

This creates a zip file at the repository root named:

- terrain_asset_painter_addon.zip

The archive contains:

- addons/terrain_asset_painter/...

## Generate the built-in asset pack

The repo includes a generator for procedural asset models and textures.

```bash
python3 tools/generate_terrain_asset_pack.py
```

The script writes output to:

- generated_assets/trees/
- generated_assets/grass/

## Notes

- The terrain painting add-on supports textured terrain painting and 3D model placement.
- It is designed to work with Hterrain-style terrain nodes by dynamic API detection.
- Generated assets are procedural placeholders and can be used as a working terrain asset pack.
