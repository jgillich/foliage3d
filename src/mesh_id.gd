@tool
class_name Foliage3DMeshID extends Foliage3DNode

@export var mesh_id: int:
	set(value):
		mesh_id = value
		changed.emit()

func get_inputs() -> Array[int]:
	return [TYPE_POINT]

func get_outputs() -> Array[int]:
	return []

func _generate(points: Array[Foliage3DPoint]) -> Array:
	var xforms: Array[Transform3D]
	xforms.assign(points.map(func(p: Foliage3DPoint): return p.transform))
	add_mesh_xforms(mesh_id, xforms)

	return []
