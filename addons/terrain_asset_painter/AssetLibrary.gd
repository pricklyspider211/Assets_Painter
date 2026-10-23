@tool
extends Resource
class_name TerrainAssetLibrary

@export var textures: Array[Texture2D] = []
@export var models: Array[PackedScene] = []

func add_texture(texture: Texture2D) -> void:
    if texture != null and not textures.has(texture):
        textures.append(texture)

func add_model(scene: PackedScene) -> void:
    if scene != null and not models.has(scene):
        models.append(scene)
