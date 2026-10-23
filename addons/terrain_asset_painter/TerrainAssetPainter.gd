@tool
extends Node3D

enum PaintMode { TEXTURE, MODEL }

@export var terrain_path: NodePath
@export var paint_mode: PaintMode = PaintMode.TEXTURE

@export_group("Texture painting")
@export var texture_library: Array[Texture2D] = []
@export var texture_index: int = 0
@export var texture_layer: int = 0
@export var brush_radius: float = 2.0
@export var brush_strength: float = 1.0
@export var brush_falloff: float = 0.7

@export_group("Model painting")
@export var model_library: Array[PackedScene] = []
@export var model_scale_min: float = 0.8
@export var model_scale_max: float = 1.4
@export var random_rotation: bool = true
@export var max_placed_models: int = 200
@export var place_on_ground: bool = true

var _placed_models: Array[Node3D] = []

func _ready() -> void:
    if Engine.is_editor_hint():
        return

func paint_at(world_position: Vector3) -> void:
    if paint_mode == PaintMode.TEXTURE:
        _paint_texture(world_position)
    else:
        _paint_model(world_position)

func _get_terrain_node() -> Node:
    if terrain_path != NodePath() and has_node(terrain_path):
        return get_node(terrain_path)

    var root := get_tree().get_root()
    if root:
        var found = _search_for_terrain(root)
        if found:
            return found

    return null

func _search_for_terrain(node: Node) -> Node:
    for child in node.get_children():
        if child is Node3D and _looks_like_terrain(child):
            return child
        var nested := _search_for_terrain(child)
        if nested:
            return nested
    return null

func _looks_like_terrain(node: Node) -> bool:
    if node == null:
        return false

    var name_lower = node.name.to_lower()
    if "terrain" in name_lower or "hterrain" in name_lower:
        return true

    for method_name in ["get_height_at", "get_height", "sample_height", "paint_texture_layer", "paint_layer", "paint_model"]:
        if node.has_method(method_name):
            return true

    return false

func _paint_texture(world_position: Vector3) -> void:
    var terrain = _get_terrain_node()
    if terrain == null:
        push_warning("TerrainAssetPainter: no terrain found.")
        return

    if texture_library.is_empty():
        push_warning("TerrainAssetPainter: no textures imported.")
        return

    var texture = texture_library[texture_index % texture_library.size()]
    if texture == null:
        return

    var args = [
        texture_layer,
        world_position,
        brush_radius,
        brush_strength,
        brush_falloff,
        texture
    ]

    var calls = [
        "paint_texture_layer",
        "paint_layer",
        "paint_terrain_layer",
        "paint_splat",
        "paint"
    ]

    for call_name in calls:
        if terrain.has_method(call_name):
            var result = terrain.callv(call_name, args)
            if result != null:
                return

    terrain.set_meta("terrain_asset_painter_last_texture_paint", {
        "position": world_position,
        "layer": texture_layer,
        "radius": brush_radius,
        "strength": brush_strength,
        "falloff": brush_falloff,
        "texture": texture
    })

func _paint_model(world_position: Vector3) -> void:
    if model_library.is_empty():
        push_warning("TerrainAssetPainter: no models imported.")
        return

    var terrain = _get_terrain_node()
    var scene = model_library[randi() % model_library.size()]
    if scene == null:
        return

    var instance = scene.instantiate()
    if not instance is Node3D:
        return

    var node3d = instance as Node3D
    var final_pos = world_position

    if place_on_ground and terrain != null:
        final_pos.y = _get_ground_height(terrain, world_position)

    node3d.position = final_pos
    if random_rotation:
        node3d.rotation_degrees.y = randf_range(0.0, 360.0)
    node3d.scale = Vector3.ONE * randf_range(model_scale_min, model_scale_max)

    add_child(node3d)
    _placed_models.append(node3d)

    if _placed_models.size() > max_placed_models:
        var old = _placed_models.pop_front()
        if is_instance_valid(old):
            old.queue_free()

func _get_ground_height(terrain: Node, world_position: Vector3) -> float:
    if terrain.has_method("get_height_at"):
        return terrain.call("get_height_at", world_position.x, world_position.z)
    if terrain.has_method("get_height"):
        return terrain.call("get_height", world_position)
    if terrain.has_method("sample_height"):
        return terrain.call("sample_height", world_position)
    return world_position.y
