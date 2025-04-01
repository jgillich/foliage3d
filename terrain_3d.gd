class_name Foliage3DTerrain3D

#signal mesh_xforms_added(mesh: int, xforms: Array[Vector3])

var terrain3d: Terrain3D

func get_height(pos: Vector3) -> float:
	return terrain3d.data.get_height(pos)

func get_normal(pos: Vector3) -> Vector3:
	return terrain3d.data.get_normal(pos)

func add_mesh_xforms(mesh: int, xforms: Array[Transform3D]) -> void:
	if mesh >= terrain3d.assets.get_mesh_count():
		push_warning("foliage: mesh %d out of range" % mesh)
		return
	var dict: Dictionary = {}
	var asset := terrain3d.assets.get_mesh_asset(mesh)
	for i in range(xforms.size()):
		var xform = xforms[i]
		xform.origin += xform.basis.y * asset.height_offset
		var loc = terrain3d.data.get_region_location(xform.origin)
		var region: Array[Transform3D] = dict.get_or_add(loc, [] as Array[Transform3D])
		region.append(xform)

	for loc in dict.keys():
		var colors: PackedColorArray = []
		colors.resize(dict[loc].size())
		colors.fill(Color.WHITE)

		var region = terrain3d.data.get_region(loc)
		var global_local_offset = Vector3(loc.x, 0, loc.y) * region.region_size * terrain3d.vertex_spacing
		for i in range(dict[loc].size()):
			dict[loc][i].origin -= global_local_offset
			#mesh_xforms_added.emit(mesh, dict[loc][i])

		terrain3d.instancer.append_region.call_deferred(region, mesh, dict[loc], colors)
