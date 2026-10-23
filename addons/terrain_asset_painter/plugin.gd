@tool
extends EditorPlugin

var dock: Control

func _enter_tree() -> void:
    dock = preload("res://addons/terrain_asset_painter/TerrainPaintDock.gd").new()
    add_control_to_docks(dock)

    add_custom_type(
        "TerrainAssetPainter",
        "Node3D",
        preload("res://addons/terrain_asset_painter/TerrainAssetPainter.gd"),
        null
    )

func _exit_tree() -> void:
    remove_custom_type("TerrainAssetPainter")

    if dock:
        remove_control_from_docks(dock)
        dock.queue_free()
