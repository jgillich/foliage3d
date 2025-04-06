@tool
class_name Foliage3DMeshSpawner extends Foliage3DNode

@export var assets: Array[Foliage3DMeshAsset]:
	set(value):
		assets = value
		changed.emit()

func get_inputs() -> Array[int]:
	return [TYPE_POINT]

func get_outputs() -> Array[int]:
	return []

func _generate(ctx: Foliage3DExecutor.NodeContext, points: Array[Foliage3DPoint]) -> Array:
	var ids: Array[int]
	for i in range(assets.size()):
		if assets[i].scene == null:
			continue
		var id = ctx.with_terrain(get_or_create_mesh.bind(assets[i].scene))
		ids.append(id)

	if ids.is_empty():
		return []

	var xforms: Array[Array]
	for i in range(ids.size()):
		xforms.append([] as Array[Transform3D])

	for i in range(0, points.size(), ids.size()):
		for j in range(min(ids.size(), points.size()-i)):
			xforms[j].append(points[i+j].transform)

	for i in range(ids.size()):
		ctx.with_terrain(add_mesh_xforms.bind(ctx, ids[i], xforms[i]))

	return []

func get_or_create_mesh(terrain: Terrain3D, mesh: PackedScene) -> int:
	var mesh_count = terrain.assets.get_mesh_count()
	for i in range(mesh_count):
		var asset = terrain.assets.get_mesh_asset(i)
		if asset == null or asset.scene_file == null:
			continue
		if mesh.resource_path == asset.scene_file.resource_path:
			return i

	var asset := Terrain3DMeshAsset.new()
	asset.scene_file = mesh
	terrain.assets.set_mesh_asset(mesh_count, asset)
	return mesh_count


func add_mesh_xforms(terrain: Terrain3D, ctx: Foliage3DExecutor.NodeContext, mesh: int, xforms: Array[Transform3D]) -> void:
	if mesh >= terrain.assets.get_mesh_count():
		push_warning("foliage: mesh %d out of range" % mesh)
		return
	var dict: Dictionary = {}
	var asset := terrain.assets.get_mesh_asset(mesh)
	for i in range(xforms.size()):
		var xform = xforms[i]
		xform.origin += xform.basis.y * asset.height_offset
		var loc = terrain.data.get_region_location(xform.origin)

		if not terrain.data.has_region(loc):
			terrain.data.add_region_blank(loc)

		var region: Array[Transform3D] = dict.get_or_add(loc, [] as Array[Transform3D])
		region.append(xform)

	for loc in dict.keys():
		var colors: PackedColorArray = []
		colors.resize(dict[loc].size())
		colors.fill(Color.WHITE)

		var region = terrain.data.get_region(loc)
		region.modified = true

		var global_local_offset = Vector3(loc.x, 0, loc.y) * region.region_size * terrain.vertex_spacing
		for i in range(dict[loc].size()):
			dict[loc][i].origin -= global_local_offset

		ctx.with_terrain_main(func(terrain: Terrain3D):
			terrain.instancer.append_region(region, mesh, dict[loc], colors)
		)
		mesh_xforms_added.emit(loc, mesh, dict[loc])
