class_name Foliage3DTexturePainter extends Foliage3DNode

const BRUSH_PATH: String = "res://addons/terrain_3d/brushes"

enum Brush {
	CIRCLE0,
	CIRCLE1,
	CIRCLE2,
	CIRCLE3,
	CIRCLE4,
	SQUARE1,
	SQUARE2,
	SQUARE3,
	SQUARE4,
	SQUARE5,
}

@export var albedo_texture: Texture2D:
	set(value):
		albedo_texture = value
		changed.emit()

@export var brush: Brush:
	set(value):
		brush = value
		changed.emit()

@export_range(0.1, 1000.0) var strength: float = 1000.0:
	set(value):
		strength = value
		changed.emit()

# textures are painted in order of priority, lowest first, highest last
@export_range(0, 1024) var priority: int:
	set(value):
		priority = value
		changed.emit()

func get_inputs() -> Array[int]:
	return [TYPE_POINT]

func _generate(ctx: Foliage3DExecutor.NodeContext, input: Array[Foliage3DPoint]) -> Array:
	if input.is_empty() or albedo_texture == null:
		return []

	if priority > 0:
		ctx.mutate(func(data: Dictionary):
			data[self] = input
		)
	else:
		ctx.with_terrain_main(paint.bind(input))

	return []


func _post_generate(ctx: Foliage3DExecutor.NodeContext):
	var data = ctx.finalize()
	if data is not Dictionary:
		return

	var keys: Array = data.keys()
	keys.sort_custom(func(a, b): return a.priority < b.priority)

	ctx.with_terrain_main(func(terrain: Terrain3D):
		for node: Foliage3DTexturePainter in keys:
			node.paint(terrain, data[node])
	)

func paint(terrain: Terrain3D, input: Array[Foliage3DPoint]):
	var editor = Terrain3DEditor.new()
	editor.set_terrain(terrain)
	editor.set_tool(Terrain3DEditor.TEXTURE)
	editor.set_operation(Terrain3DEditor.REPLACE)

	var brush = load_brush(get_or_create_texture(terrain))
	editor.set_brush_data(brush)

	editor.start_operation(Vector3.ZERO)
	for point: Foliage3DPoint in input:
		var size = point.size.x + point.size.z
		if brush["size"] != size:
			brush["size"] = size
			editor.set_brush_data(brush)
		editor.operate(point.transform.origin, 0.0)
	editor.stop_operation()

func get_or_create_texture(terrain: Terrain3D) -> int:
	var texture_count = terrain.assets.get_texture_count()
	for i in range(texture_count):
		var texture = terrain.assets.get_texture(i)
		if texture.albedo_texture.resource_path == albedo_texture.resource_path:
			return i

	var texture = Terrain3DTextureAsset.new()
	texture.id = texture_count
	texture.albedo_texture = albedo_texture
	texture.name = albedo_texture.resource_path.get_file()
	terrain.assets.set_texture(texture_count, texture)
	return texture_count

func load_brush(texture_id: int) -> Dictionary:
	var img: Image = Image.load_from_file("%s/%s.exr" % [BRUSH_PATH, Brush.keys()[brush].to_lower()])
	var thumbimg: Image = img.duplicate()
	img.convert(Image.FORMAT_RF)

	var tex_img = img
	if tex_img.get_width() < 1024 and tex_img.get_height() < 1024:
		tex_img = tex_img.duplicate()
		tex_img.resize(1024, 1024, Image.INTERPOLATE_CUBIC)
	var tex: ImageTexture = ImageTexture.create_from_image(tex_img)

	return {
		"brush": [img, tex],
		"strength": strength,
		"enable_texture": true,
		"asset_id": texture_id,
		"size": 0.0,
	}
