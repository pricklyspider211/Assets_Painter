# Terrain Asset Painter

This repository now includes a procedural asset-generation pipeline that creates real `.glb` files with generated textures, rather than only a script stub.

## Included output

Running the generator creates:
- 20 tree `.glb` models
- 20 grass `.glb` models
- short and long grass variants
- 1024x1024 generated textures embedded in the GLB exports

## Generate the assets

Requirements:
- Python 3.10+
- pip install pillow trimesh numpy

Run:

```bash
python3 tools/generate_terrain_asset_pack.py
```

Output folder:
- `generated_assets/trees/`
- `generated_assets/grass/`

## Notes

These are procedural generated models designed for terrain painting and quick prototyping. They are suitable for gameplay use and rapid asset placement, but they are not a licensed AAA art pack.
