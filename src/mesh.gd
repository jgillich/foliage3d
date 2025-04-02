@tool
class_name Foliage3DMesh extends Foliage3DNode

@export var meshes: Array[PackedScene]:
	set(value):
		meshes = value
		changed.emit()

func get_inputs() -> Array[int]:
	return [TYPE_POINT]

func get_outputs() -> Array[int]:
	return []

func _generate(points: Array[Foliage3DPoint]) -> Array:
	if meshes.is_empty():
		return []

	var ids: Array[int]
	for mesh in meshes:
		ids.append(get_or_create_mesh(mesh))

	var xforms: Array[Array]
	for i in range(ids.size()):
		xforms.append([] as Array[Transform3D])

	for i in range(0, points.size(), ids.size()):
		for j in range(min(ids.size(), points.size()-i)):
			xforms[j].append(points[i+j].transform)

	for i in range(ids.size()):
		add_mesh_xforms.call_deferred(ids[i], xforms[i])

	return []

func get_or_create_mesh(mesh: PackedScene) -> int:
	var count = terrain3d.assets.get_mesh_count()
	for i in range(count):
		var asset = terrain3d.assets.get_mesh_asset(i)
		if asset.scene_file == null:
			continue
		if mesh.resource_path == asset.scene_file.resource_path:
			return i

	var asset := Terrain3DMeshAsset.new()
	asset.scene_file = mesh
	terrain3d.assets.set_mesh_asset.call_deferred(count, asset)
	return count
