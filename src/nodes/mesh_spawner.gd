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

func _generate(points: Array[Foliage3DPoint]) -> Array:
	var mesh_count = terrain3d.assets.get_mesh_count()
	var ids: Array[int]
	for i in range(assets.size()):
		if assets[i].scene == null:
			continue
		var id = get_or_create_mesh(assets[i].scene, mesh_count)
		if id == mesh_count:
			mesh_count += 1
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
		add_mesh_xforms.call_deferred(ids[i], xforms[i])

	return []

func get_or_create_mesh(mesh: PackedScene, mesh_count: int) -> int:
	for i in range(mesh_count):
		var asset = terrain3d.assets.get_mesh_asset(i)
		if asset == null or asset.scene_file == null:
			continue
		if mesh.resource_path == asset.scene_file.resource_path:
			return i

	var asset := Terrain3DMeshAsset.new()
	asset.scene_file = mesh
	terrain3d.assets.set_mesh_asset.call_deferred(mesh_count, asset)
	return mesh_count
