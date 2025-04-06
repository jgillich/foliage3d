class_name Foliage3DExtentsModifier extends Foliage3DNode

enum Mode {
	SET,
	MULTIPLY,
	ADD
}

@export var point_extents: Vector3 = Vector3(1, 1, 1):
	set(value):
		point_extents = value
		changed.emit()

@export var mode: Mode

func get_inputs() -> Array[int]:
	return [TYPE_POINT]

func get_outputs() -> Array[int]:
	return [TYPE_POINT]

func _generate(ctx: Foliage3DExecutor.NodeContext, input: Array[Foliage3DPoint]) -> Array:
	var points: Array[Foliage3DPoint]
	points.assign(input.map(func(p): return p.duplicate()))
	for point in points:
		match mode:
			Mode.SET:
				point.extents = point_extents
			Mode.MULTIPLY:
				point.extents *= point_extents
			Mode.ADD:
				point.extents += point_extents
	return [points]
