@tool
extends RefCounted

static func load_textures(paths: Array[String]) -> Array[Texture2D]:
    var result: Array[Texture2D] = []
    for path in paths:
        var tex := ResourceLoader.load(path)
        if tex is Texture2D:
            result.append(tex)
    return result

static func load_models(paths: Array[String]) -> Array[PackedScene]:
    var result: Array[PackedScene] = []
    for path in paths:
        var res := ResourceLoader.load(path)
        if res is PackedScene:
            result.append(res)
    return result
