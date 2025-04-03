@tool
class_name Foliage3DFilterPoint extends Foliage3DNode

@export var position_min: Vector3:
	set(value):
		position_min = value
		changed.emit()

@export var position_max: Vector3:
	set(value):
		position_max = value
		changed.emit()

@export var rotation_min: Vector3:
	set(value):
		rotation_min = value
		changed.emit()

@export var rotation_max: Vector3:
	set(value):
		rotation_max = value
		changed.emit()

func get_inputs() -> Array[int]:
	return [TYPE_POINT]

func get_outputs() -> Array[int]:
	return [TYPE_POINT, TYPE_POINT]

func _generate(input: Array[Foliage3DPoint]) -> Array:
	var result: Array[Foliage3DPoint]
	var rest: Array[Foliage3DPoint]

	for point in input:
		if position_min != Vector3.ZERO or position_max != Vector3.ZERO:
			if point.transform.origin.clamp(vec_defaults(position_min, -INF), vec_defaults(position_max)) != point.transform.origin:
				rest.append(point)
				continue
		if rotation_min != Vector3.ZERO or rotation_max != Vector3.ZERO:
			var deg = point.transform.basis.get_euler() * rad_to_deg(1)
			if deg.clamp(vec_defaults(rotation_min, -360), vec_defaults(rotation_max, 360)) != deg and deg.clamp(rotation_max * -1, rotation_min * -1) != deg:
				rest.append(point)
				continue

		result.append(point)

	return [result, rest]

func vec_defaults(vec: Vector3, default = INF) -> Vector3:
	return Vector3(
		vec.x if vec.x != 0 else default,
		vec.y if vec.y != 0 else default,
		vec.z if vec.z != 0 else default
	)
