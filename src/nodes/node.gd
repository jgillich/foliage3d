@tool
class_name Foliage3DNode extends Resource

enum {
	TYPE_POINT = 100
}

signal mesh_xforms_added(region: Vector2i, mesh: int, xforms: Array[Vector3])

var inputs: Array[Array]
var result: Array
var terrain3d: Terrain3D
var bounds: Foliage3DBounds

func _init():
	inputs.resize(get_inputs().size())
	resource_name = type()
	for i in range(inputs.size()):
		inputs[i] = []

func get_inputs() -> Array[int]:
	return []

func get_outputs() -> Array[int]:
	return []

func generate():
	if OS.get_thread_caller_id() != OS.get_main_thread_id():
		Thread.set_thread_safety_checks_enabled(false)

	var time = Time.get_ticks_msec()

	var args: Array

	for i in range(inputs.size()):
		for j in inputs[i]:
			var port = j[0]
			var node = j[1]
			if args.size() <= i:
				args.append(node.result[port].duplicate())
			else:
				args[i].append_array(node.result[port])

	if args.size() != get_inputs().size():
		return

	result = callv("_generate", args)

	for i in range(inputs.size()):
		inputs[i] = []

	time = Time.get_ticks_msec() - time
	#if time > 100:
	print_debug("%s completed in %dms" % [type(), time])

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

		if not terrain3d.data.has_region(loc):
			terrain3d.data.add_region_blank(loc)

		var region: Array[Transform3D] = dict.get_or_add(loc, [] as Array[Transform3D])
		region.append(xform)

	for loc in dict.keys():
		var colors: PackedColorArray = []
		colors.resize(dict[loc].size())
		colors.fill(Color.WHITE)

		var region = terrain3d.data.get_region(loc)
		region.modified = true

		var global_local_offset = Vector3(loc.x, 0, loc.y) * region.region_size * terrain3d.vertex_spacing
		for i in range(dict[loc].size()):
			dict[loc][i].origin -= global_local_offset

		terrain3d.instancer.append_region(region, mesh, dict[loc], colors)
		mesh_xforms_added.emit(loc, mesh, dict[loc])

func type() -> String:
	return get_script().get_global_name().trim_prefix("Foliage3D")
