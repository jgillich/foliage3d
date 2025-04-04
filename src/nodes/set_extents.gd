class_name Foliage3DSetExtents extends Foliage3DNode

@export var point_extents: Vector3 = Vector3(1, 1, 1):
	set(value):
		point_extents = value
		changed.emit()

func get_inputs() -> Array[int]:
	return [TYPE_POINT]

func get_outputs() -> Array[int]:
	return [TYPE_POINT]

func _generate(input: Array[Foliage3DPoint]) -> Array:
	var points: Array[Foliage3DPoint]
	points.assign(input.map(func(p): return p.duplicate()))

	for point in points:
		point.extents = point_extents
	return [points]
