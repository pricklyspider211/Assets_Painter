# Terrain Asset Painter

This project contains a Godot 4.6.2 addon with:
- terrain texture paint support
- model paint support
- random forest-style scattered placement while painting
- imported PNG textures and GLB models
- GitHub Actions asset generation workflow

## Random model painting

The model painter now supports:
- multiple imported models at once
- random model selection from the active palette
- random scale and rotation
- scattered placement within the brush radius
- forest-like distribution using density and cluster radius

## GitHub Actions

The workflow file is located at:
- .github/workflows/generate_terrain_asset_pack.yml

Run it manually from the Actions tab to generate the asset pack in-repo.
