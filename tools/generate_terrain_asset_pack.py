#!/usr/bin/env python3
import math
import random
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter
import trimesh

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "generated_assets"
TREES = OUT / "trees"
GRASS = OUT / "grass"
TEXTURE_SIZE = 1024


def make_wood_texture(seed: int) -> Image.Image:
    rng = random.Random(seed)
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE), (120, 90, 65))
    pixels = np.array(img, dtype=np.uint8)

    for _ in range(1800):
        x = rng.randint(0, TEXTURE_SIZE - 1)
        y = rng.randint(0, TEXTURE_SIZE - 1)
        shade = rng.randint(35, 80)
        pixels[y, x] = [max(0, 90 + shade), max(0, 70 + shade // 2), max(0, 55 + shade // 3)]

    for _ in range(500):
        x = rng.randint(0, TEXTURE_SIZE - 1)
        y = rng.randint(0, TEXTURE_SIZE - 1)
        if rng.random() < 0.5:
            pixels[y, x] = [45, 30, 20]

    img = Image.fromarray(pixels)
    return img.filter(ImageFilter.GaussianBlur(radius=0.4))


def make_leaf_texture(seed: int, hue_shift: float = 0.0) -> Image.Image:
    rng = random.Random(seed)
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE), (60, 150, 70))
    pixels = np.array(img, dtype=np.uint8)

    for _ in range(20000):
        x = rng.randint(0, TEXTURE_SIZE - 1)
        y = rng.randint(0, TEXTURE_SIZE - 1)
        shade = rng.randint(10, 80)
        r = max(0, min(255, 40 + shade + int(hue_shift * 80)))
        g = max(0, min(255, 140 + shade))
        b = max(0, min(255, 60 + shade // 2))
        pixels[y, x] = [r, g, b]

    for _ in range(800):
        x = rng.randint(0, TEXTURE_SIZE - 1)
        y = rng.randint(0, TEXTURE_SIZE - 1)
        if rng.random() < 0.3:
            pixels[y, x] = [20, 80, 30]

    img = Image.fromarray(pixels)
    return img.filter(ImageFilter.GaussianBlur(radius=0.5))


def make_grass_texture(seed: int, light: int = 80) -> Image.Image:
    rng = random.Random(seed)
    img = Image.new("RGB", (TEXTURE_SIZE, TEXTURE_SIZE), (60, 110, 55))
    pixels = np.array(img, dtype=np.uint8)

    for _ in range(15000):
        x = rng.randint(0, TEXTURE_SIZE - 1)
        y = rng.randint(0, TEXTURE_SIZE - 1)
        shade = rng.randint(20, 90)
        pixels[y, x] = [max(0, 30 + shade), max(0, 100 + shade // 2 + light), 50 + shade // 2]

    # Add blade-like streaking pattern
    for y in range(TEXTURE_SIZE):
        for x in range(TEXTURE_SIZE):
            if ((x + y + seed * 13) % 31) == 0:
                pixels[y, x] = [20, 80, 30]

    return Image.fromarray(pixels).filter(ImageFilter.GaussianBlur(radius=0.6))


def apply_texture(mesh: trimesh.Trimesh, image: Image.Image, uv_scale: float = 1.0):
    width, height = image.size
    vertices = mesh.vertices
    # Planar UV mapping for simple meshes.
    u = (vertices[:, 0] + 1.0) * 0.5
    v = (vertices[:, 2] + 1.0) * 0.5
    uv = np.column_stack([u * uv_scale, v * uv_scale])
    mesh.visual = trimesh.visual.TextureVisuals(uv=uv, image=image)
    return mesh


def build_tree(seed: int, kind: str = "broadleaf") -> trimesh.Scene:
    rng = random.Random(seed)
    height = 1.8 + rng.random() * 1.8
    trunk_r = 0.14 + rng.random() * 0.12
    trunk = trimesh.creation.cylinder(radius=trunk_r, height=height, sections=24)
    trunk.apply_translation([0, height / 2.0, 0])
    trunk = apply_texture(trunk, make_wood_texture(seed + 17), uv_scale=2.0)

    crown_count = 3 + rng.randint(0, 2)
    crowns = []
    for i in range(crown_count):
        radius = 0.8 + rng.random() * 1.0
        sphere = trimesh.creation.icosphere(subdivisions=2, radius=radius)
        offset = [
            (rng.random() - 0.5) * 1.5,
            height * 0.7 + rng.random() * 1.2,
            (rng.random() - 0.5) * 1.5,
        ]
        sphere.apply_translation(offset)
        sphere = apply_texture(sphere, make_leaf_texture(seed + i * 17 + 9, hue_shift=(i / max(1, crown_count)) * 0.6), uv_scale=1.5)
        crowns.append(sphere)

    scene = trimesh.Scene()
    scene.add_geometry(trunk)
    for crown in crowns:
        scene.add_geometry(crown)
    return scene


def build_grass(seed: int, length_type: str = "short") -> trimesh.Scene:
    rng = random.Random(seed)
    scene = trimesh.Scene()

    blade_count = 10 + rng.randint(0, 8)
    grass_tex = make_grass_texture(seed + 99, light=90 if length_type == "short" else 60)

    for i in range(blade_count):
        blade_height = 0.25 + rng.random() * (0.55 if length_type == "short" else 1.2)
        blade = trimesh.creation.box(extents=[0.08, blade_height, 0.02])
        blade.apply_translation([
            (rng.random() - 0.5) * 0.8,
            blade_height / 2.0,
            (rng.random() - 0.5) * 0.8,
        ])
        blade.rotation = trimesh.transformations.rotation_matrix(
            rng.random() * math.tau,
            [0, 0, 1],
            [0, 0, 0],
        )
        blade = apply_texture(blade, grass_tex, uv_scale=3.0)
        scene.add_geometry(blade)

    return scene


def export_scene(scene: trimesh.Scene, target: Path):
    target.parent.mkdir(parents=True, exist_ok=True)
    trimesh.exchange.gltf.export_glb(scene, file_obj=str(target))


def generate_pack():
    TREES.mkdir(parents=True, exist_ok=True)
    GRASS.mkdir(parents=True, exist_ok=True)

    for i in range(20):
        tree = build_tree(i)
        export_scene(tree, TREES / f"tree_{i + 1:02d}.glb")

    for i in range(20):
        mode = "short" if i % 2 == 0 else "long"
        grass = build_grass(i, mode)
        export_scene(grass, GRASS / f"grass_{i + 1:02d}_{mode}.glb")

    print(f"Generated 20 tree models + 20 grass models into {OUT}")


if __name__ == "__main__":
    generate_pack()
