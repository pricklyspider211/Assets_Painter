#!/usr/bin/env python3
import math
import random
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter
import trimesh

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "generated_assets"
TREES = OUT / "trees"
GRASS = OUT / "grass"
TEXTURE_WIDTH = 1920
TEXTURE_HEIGHT = 1080


def save_png(img, path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)


def make_wood_texture(seed: int):
    rng = random.Random(seed)
    img = Image.new("RGB", (TEXTURE_WIDTH, TEXTURE_HEIGHT), (120, 90, 65))
    pixels = np.array(img, dtype=np.uint8)
    for _ in range(2600):
        x = rng.randint(0, TEXTURE_WIDTH - 1)
        y = rng.randint(0, TEXTURE_HEIGHT - 1)
        shade = rng.randint(35, 90)
        pixels[y, x] = [max(0, 90 + shade), max(0, 70 + shade // 2), max(0, 55 + shade // 3)]
    img = Image.fromarray(pixels)
    return img.filter(ImageFilter.GaussianBlur(radius=0.4))


def make_leaf_texture(seed: int, hue_shift: float = 0.0):
    rng = random.Random(seed)
    img = Image.new("RGB", (TEXTURE_WIDTH, TEXTURE_HEIGHT), (60, 150, 70))
    pixels = np.array(img, dtype=np.uint8)
    for _ in range(20000):
        x = rng.randint(0, TEXTURE_WIDTH - 1)
        y = rng.randint(0, TEXTURE_HEIGHT - 1)
        shade = rng.randint(10, 90)
        r = max(0, min(255, 35 + shade + int(hue_shift * 80)))
        g = max(0, min(255, 140 + shade))
        b = max(0, min(255, 60 + shade // 2))
        pixels[y, x] = [r, g, b]
    img = Image.fromarray(pixels)
    return img.filter(ImageFilter.GaussianBlur(radius=0.5))


def make_grass_texture(seed: int, light: int = 80):
    rng = random.Random(seed)
    img = Image.new("RGB", (TEXTURE_WIDTH, TEXTURE_HEIGHT), (60, 110, 55))
    pixels = np.array(img, dtype=np.uint8)
    for _ in range(18000):
        x = rng.randint(0, TEXTURE_WIDTH - 1)
        y = rng.randint(0, TEXTURE_HEIGHT - 1)
        shade = rng.randint(20, 90)
        pixels[y, x] = [max(0, 30 + shade), max(0, 100 + shade // 2 + light), 50 + shade // 2]
    for y in range(TEXTURE_HEIGHT):
        for x in range(TEXTURE_WIDTH):
            if ((x + y + seed * 13) % 31) == 0:
                pixels[y, x] = [20, 80, 30]
    return Image.fromarray(pixels).filter(ImageFilter.GaussianBlur(radius=0.6))


def build_tree(seed: int):
    rng = random.Random(seed)
    height = 1.8 + rng.random() * 1.8
    trunk = trimesh.creation.cylinder(radius=0.14 + rng.random() * 0.12, height=height, sections=28)
    trunk.apply_translation([0, height / 2.0, 0])

    crown_count = 3 + rng.randint(0, 2)
    scene = trimesh.Scene()
    scene.add_geometry(trunk)

    for i in range(crown_count):
        radius = 0.8 + rng.random() * 1.0
        sphere = trimesh.creation.icosphere(subdivisions=2, radius=radius)
        offset = [
            (rng.random() - 0.5) * 1.5,
            height * 0.7 + rng.random() * 1.2,
            (rng.random() - 0.5) * 1.5,
        ]
        sphere.apply_translation(offset)
        scene.add_geometry(sphere)

    return scene


def build_grass(seed: int, length_type: str = "short"):
    rng = random.Random(seed)
    scene = trimesh.Scene()
    blade_count = 12 + rng.randint(0, 8)

    for _ in range(blade_count):
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
        scene.add_geometry(blade)

    return scene


def export_glb(scene, target: Path):
    target.parent.mkdir(parents=True, exist_ok=True)
    trimesh.exchange.gltf.export_glb(scene, file_obj=str(target))


def generate_pack():
    TREES.mkdir(parents=True, exist_ok=True)
    GRASS.mkdir(parents=True, exist_ok=True)

    for i in range(20):
        tree = build_tree(i)
        wood_tex = make_wood_texture(i + 17)
        leaf_tex = make_leaf_texture(i + 13, hue_shift=0.25)
        save_png(wood_tex, TREES / f"tree_{i + 1:02d}_wood.png")
        save_png(leaf_tex, TREES / f"tree_{i + 1:02d}_leaf.png")
        export_glb(tree, TREES / f"tree_{i + 1:02d}.glb")

    for i in range(20):
        mode = "short" if i % 2 == 0 else "long"
        grass = build_grass(i, mode)
        gtex = make_grass_texture(i + 99, light=90 if mode == "short" else 60)
        save_png(gtex, GRASS / f"grass_{i + 1:02d}_{mode}.png")
        export_glb(grass, GRASS / f"grass_{i + 1:02d}_{mode}.glb")

    print(f"Generated assets in {OUT}")
    print("Texture PNGs: 1920x1080")


if __name__ == "__main__":
    generate_pack()
