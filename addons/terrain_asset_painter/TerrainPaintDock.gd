@tool
extends PanelContainer

var painter: Node
var texture_paths: Array[String] = []
var model_paths: Array[String] = []

func _ready() -> void:
    _build_ui()

func _build_ui() -> void:
    var vbox := VBoxContainer.new()
    add_child(vbox)

    var title := Label.new()
    title.text = "Terrain Asset Painter"
    vbox.add_child(title)

    var mode_box := HBoxContainer.new()

    var texture_btn := Button.new()
    texture_btn.text = "Texture Paint"
    var model_btn := Button.new()
    model_btn.text = "Model Paint"

    mode_box.add_child(texture_btn)
    mode_box.add_child(model_btn)
    vbox.add_child(mode_box)

    texture_btn.pressed.connect(_on_texture_mode)
    model_btn.pressed.connect(_on_model_mode)

    var import_tex_btn := Button.new()
    import_tex_btn.text = "Import Textures"
    vbox.add_child(import_tex_btn)
    import_tex_btn.pressed.connect(_on_import_textures)

    var import_model_btn := Button.new()
    import_model_btn.text = "Import Models"
    vbox.add_child(import_model_btn)
    import_model_btn.pressed.connect(_on_import_models)

    var assign_btn := Button.new()
    assign_btn.text = "Assign to selected terrain"
    vbox.add_child(assign_btn)
    assign_btn.pressed.connect(_on_assign_terrain)

    var help := Label.new()
    help.text = "Tip: run AssetPackGenerator.gd once to generate built-in assets."
    help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    vbox.add_child(help)

func _on_texture_mode() -> void:
    painter = _find_painter()
    if painter and painter.has_method("set"):
        painter.paint_mode = painter.PaintMode.TEXTURE

func _on_model_mode() -> void:
    painter = _find_painter()
    if painter and painter.has_method("set"):
        painter.paint_mode = painter.PaintMode.MODEL

func _on_import_textures() -> void:
    var dialog := FileDialog.new()
    dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
    dialog.access = FileDialog.ACCESS_FILESYSTEM
    dialog.filters = PackedStringArray([
        "*.png ; PNG",
        "*.jpg ; JPG",
        "*.jpeg ; JPEG",
        "*.tga ; TGA",
        "*.webp ; WEBP"
    ])
    dialog.title = "Import terrain textures"
    dialog.min_size = Vector2i(800, 500)

    dialog.files_selected.connect(func(paths: PackedStringArray):
        texture_paths = []
        var arr: Array[Texture2D] = []
        for path in paths:
            texture_paths.append(path)
            var tex := ResourceLoader.load(path)
            if tex is Texture2D:
                arr.append(tex)

        painter = _find_painter()
        if painter:
            painter.texture_library = arr
    )

    add_child(dialog)
    dialog.popup_centered()

func _on_import_models() -> void:
    var dialog := FileDialog.new()
    dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
    dialog.access = FileDialog.ACCESS_FILESYSTEM
    dialog.filters = PackedStringArray([
        "*.glb ; GLB",
        "*.gltf ; GLTF"
    ])
    dialog.title = "Import 3D models"
    dialog.min_size = Vector2i(800, 500)

    dialog.files_selected.connect(func(paths: PackedStringArray):
        model_paths = []
        var arr: Array[PackedScene] = []

        for path in paths:
            model_paths.append(path)
            var res := ResourceLoader.load(path)
            if res is PackedScene:
                arr.append(res)

        painter = _find_painter()
        if painter:
            painter.model_library = arr
    )

    add_child(dialog)
    dialog.popup_centered()

func _on_assign_terrain() -> void:
    painter = _find_painter()
    if painter == null:
        push_warning("No TerrainAssetPainter found in scene.")
        return

    var selection = get_tree().get_edited_scene_root()
    if selection == null:
        push_warning("No scene root selected.")
        return

    var candidates: Array[Node] = [selection]
    while not candidates.is_empty():
        var n = candidates.pop_back()
        if n is Node3D and _looks_like_terrain(n):
            painter.terrain_path = get_path_to(n)
            print("Assigned terrain: ", n.name)
            return
        for child in n.get_children():
            candidates.append(child)

    push_warning("No terrain-like node found in active scene.")

func _looks_like_terrain(node: Node) -> bool:
    if node == null:
        return false

    var name_lower = node.name.to_lower()
    if "terrain" in name_lower or "hterrain" in name_lower:
        return true

    for method_name in ["get_height_at", "get_height", "sample_height", "paint_texture_layer", "paint_layer"]:
        if node.has_method(method_name):
            return true

    return false

func _find_painter() -> Node:
    var root := get_tree().get_edited_scene_root()
    if root == null:
        return null

    var stack: Array[Node] = [root]
    while not stack.is_empty():
        var current := stack.pop_back()
        if current.has_method("paint_at"):
            return current
        for child in current.get_children():
            stack.append(child)

    return null
