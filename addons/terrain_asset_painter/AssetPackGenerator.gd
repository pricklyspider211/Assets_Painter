@tool
extends EditorScript

const TREE_DIR := "res://addons/terrain_asset_painter/generated_assets/trees/"
const GRASS_DIR := "res://addons/terrain_asset_painter/generated_assets/grass/"

func _run() -> void:
    _ensure_dirs()
    _generate_tree_models()
    _generate_grass_models()
    print("Built-in terrain asset pack generated.")

func _ensure_dirs() -> void:
    var dir := DirAccess.open("res://")
    if not dir.dir_exists("res://addons/terrain_asset_painter/generated_assets"):
        dir.make_dir_recursive("res://addons/terrain_asset_painter/generated_assets")
    if not dir.dir_exists(TREE_DIR):
        dir.make_dir_recursive(TREE_DIR)
    if not dir.dir_exists(GRASS_DIR):
        dir.make_dir_recursive(GRASS_DIR)

func _generate_tree_models() -> void:
    for i in range(20):
        var tree := Node3D.new()
        tree.name = "Tree_%02d" % (i + 1)

        var trunk := MeshInstance3D.new()
        var trunk_mesh := CylinderMesh.new()
        trunk_mesh.top_radius = 0.18
        trunk_mesh.bottom_radius = 0.26
        trunk_mesh.height = 1.35 + (i % 5) * 0.22
        trunk_mesh.radial_segments = 12
        trunk_mesh.rings = 4
        trunk.mesh = trunk_mesh
        trunk.position.y = trunk_mesh.height * 0.5
        tree.add_child(trunk)

        var leaves := MeshInstance3D.new()
        var leaves_mesh := SphereMesh.new()
        leaves_mesh.radius = 0.7 + (i % 4) * 0.1
        leaves_mesh.height = leaves_mesh.radius * 2.0
        leaves_mesh.radial_segments = 20
        leaves_mesh.rings = 16
        leaves.mesh = leaves_mesh
        leaves.position.y = 1.95 + (i % 6) * 0.15
        tree.add_child(leaves)

        var leaves2 := MeshInstance3D.new()
        var leaves2_mesh := SphereMesh.new()
        leaves2_mesh.radius = 0.5 + (i % 3) * 0.08
        leaves2_mesh.height = leaves2_mesh.radius * 2.0
        leaves2_mesh.radial_segments = 18
        leaves2_mesh.rings = 12
        leaves2.mesh = leaves2_mesh
        leaves2.position = Vector3(0.35, 1.55, 0.25)
        tree.add_child(leaves2)

        var bark := StandardMaterial3D.new()
        bark.albedo_color = Color(0.47, 0.33, 0.22)
        bark.roughness = 0.95
        trunk.set_surface_override_material(0, bark)

        var leaf_mat := StandardMaterial3D.new()
        leaf_mat.albedo_color = Color(0.18 + (i % 5) * 0.04, 0.6 + (i % 4) * 0.05, 0.18 + (i % 3) * 0.04)
        leaf_mat.roughness = 0.8
        leaves.set_surface_override_material(0, leaf_mat)
        leaves2.set_surface_override_material(0, leaf_mat)

        _export_scene(tree, TREE_DIR + "tree_%02d.glb" % (i + 1))

func _generate_grass_models() -> void:
    for i in range(20):
        var grass := Node3D.new()
        grass.name = "Grass_%02d" % (i + 1)

        for j in range(8):
            var blade := MeshInstance3D.new()
            var plane := PlaneMesh.new()
            plane.size = Vector2(0.15, 0.9 + (j % 4) * 0.12)
            blade.mesh = plane

            var angle = (float(j) / 8.0) * TAU
            blade.position = Vector3(sin(angle) * 0.08, 0.18, cos(angle) * 0.08)
            blade.rotation_degrees.x = 90.0
            blade.rotation_degrees.z = randf_range(-35.0, 35.0)

            var mat := StandardMaterial3D.new()
            mat.albedo_color = Color(0.15 + (i % 5) * 0.05, 0.62 + (i % 4) * 0.04, 0.18 + (i % 3) * 0.04)
            mat.roughness = 0.9
            mat.cull_mode = BaseMaterial3D.CULL_DISABLED
            blade.set_surface_override_material(0, mat)

            grass.add_child(blade)

        _export_scene(grass, GRASS_DIR + "grass_%02d.glb" % (i + 1))

func _export_scene(scene: Node3D, path: String) -> void:
    var doc := GLTFDocument.new()
    var state := GLTFState.new()
    var err = doc.append_from_scene(scene, state)
    if err != OK:
        push_error("Failed to append scene to GLTF: " + path)
        return

    err = doc.write_to_filesystem(state, path)
    if err != OK:
        push_error("Failed to write GLB: " + path)
        return

    print("Saved: ", path)
