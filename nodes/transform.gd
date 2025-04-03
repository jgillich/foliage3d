class_name Foliage3DTransform extends Foliage3DNode

@export var offset_min: Vector3:
	set(value):
		offset_min = value
		changed.emit()
@export var offset_max: Vector3:
	set(value):
		offset_max = value
		changed.emit()
@export var rotation_min: Vector3:
	set(value):
		rotation_min = value
		changed.emit()
@export var rotation_max: Vector3:
	set(value):
		rotation_max = value
		changed.emit()
@export var rotation_absolute: bool:
	set(value):
		rotation_absolute = value
		changed.emit()
@export var scale_min: Vector3 = Vector3(1, 1, 1):
	set(value):
		scale_min = value
		changed.emit()
@export var scale_max: Vector3 = Vector3(1, 1, 1):
	set(value):
		scale_max = value
		changed.emit()
@export var scale_uniform: bool = true:
	set(value):
		scale_uniform = value
		changed.emit()
@export var seed: int:
	set(value):
		seed = value
		changed.emit()

func get_inputs() -> Array[int]:
	return [TYPE_POINT]

func get_outputs() -> Array[int]:
	return [TYPE_POINT]

func _generate(input: Array[Foliage3DPoint]) -> Array:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	var result: Array[Foliage3DPoint] = input.duplicate()

	if offset_min != Vector3.ZERO or offset_max != Vector3.ZERO:
		for i in range(result.size()):
			var transform = result[i].transform
			transform.origin.x += rng.randf_range(offset_min.x, offset_max.x)
			transform.origin.y += rng.randf_range(offset_min.y, offset_max.y)
			transform.origin.z += rng.randf_range(offset_min.z, offset_max.z)
			result[i].transform = transform

	if rotation_min != Vector3.ZERO or rotation_max != Vector3.ZERO or rotation_absolute:
		for i in range(result.size()):
			var transform = result[i].transform
			if rotation_absolute:
				transform.basis = Basis()
			transform.basis = transform.basis * Basis.from_euler(Vector3(
				deg_to_rad(rng.randf_range(rotation_min.x, rotation_max.x)),
				deg_to_rad(rng.randf_range(rotation_min.y, rotation_max.y)),
				deg_to_rad(rng.randf_range(rotation_min.z, rotation_max.z))
			))
			#transform.basis.x = transform.basis.x.rotated(Vector3(1, 0, 0), ))
			#transform.basis.y = transform.basis.y.rotated(Vector3(0, 1, 0), )
			#transform.basis.z = transform.basis.z.rotated(Vector3(0, 0, 1), )
			result[i].transform = transform

	if not scale_min.is_equal_approx(scale_max):
		for i in range(result.size()):
			var transform = result[i].transform
			var scale : Vector3
			if scale_uniform:
				var val = rng.randf_range(scale_min.x, scale_max.x)
				scale = Vector3(val, val, val)
			else:
				scale = Vector3(rng.randf_range(scale_min.x, scale_max.x), rng.randf_range(scale_min.y, scale_max.y), rng.randf_range(scale_min.z, scale_max.z))
			transform.basis = transform.basis.scaled(scale)
			result[i].transform = transform

	return [result]
