# Terrain Asset Painter

A Godot 4.6.2 addon for:
- painting terrain textures
- painting 3D models on terrain
- importing multiple textures at once
- importing multiple GLB/GLTF models at once
- compatibility with Hterrain by dynamic method detection

## How to use

1. Copy the `addons/terrain_asset_painter` folder into your Godot project.
2. Enable the plugin in Project > Project Settings > Plugins.
3. Add a `Node3D` to your scene.
4. Add a custom node script or use the `TerrainAssetPainter` custom type.
5. Assign the terrain node path.
6. Use the dock panel to import textures/models.
7. Select Texture Paint or Model Paint.
8. Call `paint_at(Vector3(...))` from a script or attach it to a brush system.

## Built-in assets

Open the `AssetPackGenerator.gd` script, run it once, and it will generate:

- `addons/terrain_asset_painter/generated_assets/trees/` with 20 tree GLB files
- `addons/terrain_asset_painter/generated_assets/grass/` with 20 grass GLB files

## Example usage

```gdscript
var painter := TerrainAssetPainter.new()
add_child(painter)
painter.terrain_path = NodePath("HTerrain")
painter.paint_mode = TerrainAssetPainter.PaintMode.MODEL
painter.model_library = AssetImporter.load_models([
    "res://addons/terrain_asset_painter/generated_assets/trees/tree_01.glb",
    "res://addons/terrain_asset_painter/generated_assets/grass/grass_01.glb"
])

painter.paint_at(Vector3(5, 0, 7))
```

## Notes

- Works best with terrain nodes exposing height API like `get_height_at`, `get_height`, or `sample_height`.
- If your Hterrain version uses different method names, add them to the method call list in `TerrainAssetPainter.gd`.
- The plugin is intentionally dynamic so it supports multiple terrain implementations.
