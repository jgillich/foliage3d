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
			var rad_min = vec_defaults(rotation_min, 0.0) * deg_to_rad(1)
			var rad_max = vec_defaults(rotation_max, 360.0) * deg_to_rad(1)
			var rad = point.transform.basis.get_euler()
			if not filter_rotation_vector(rad, rad_min, rad_max):
				rest.append(point)
				continue

		result.append(point)

	return [result, rest]

func filter_rotation_vector(value: Vector3, min: Vector3, max: Vector3):
	for axis in ["x", "y", "z"]:
		if value[axis] < 0:
			value[axis] *= -1
		if value[axis] > max[axis] or value[axis] < min[axis]:
			return false
	return true

func vec_defaults(vec: Vector3, default = INF) -> Vector3:
	return Vector3(
		vec.x if vec.x != 0.0 else default,
		vec.y if vec.y != 0.0 else default,
		vec.z if vec.z != 0.0 else default
	)
