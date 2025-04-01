@tool
class_name Foliage3DSurfaceSampler extends Foliage3DNode

@export var spacing: float = 10.0:
	set(value):
		spacing = value
		changed.emit()

@export var point_size: Vector3 = Vector3(1, 1, 1):
	set(value):
		point_size = value
		changed.emit()

@export var seed: int:
	set(value):
		seed = value
		changed.emit()

func get_inputs() -> Array[int]:
	return []

func get_outputs() -> Array[int]:
	return [TYPE_POINT]

func _generate() -> Array:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	var points: Array[Foliage3DPoint]
	var size = bounds.aabb.size
	var x = 0.0
	while x < size.x:
		x += spacing
		var z = 0.0
		while z < size.z:
			z += spacing
			var offset = Vector3(rng.randf_range(-spacing/2, spacing/2), 0, rng.randf_range(-spacing/2, spacing/2))
			var position = Vector3(x, 0, z) + bounds.aabb.position + offset
			position.y = get_height(position)
			var transform = Transform3D(Basis(), position)

			if not bounds.contains(position):
				continue

			# align to surface normal
			var scale = transform.basis.get_scale()
			var normal = get_normal(transform.origin)
			transform.basis.y = normal
			transform.basis.z = -transform.basis.z.cross(normal)
			transform.basis.x = -transform.basis.x.cross(normal)
			transform.basis = transform.basis.orthonormalized().scaled(scale)

			points.append(Foliage3DPoint.new(transform, point_size))

	return [points]
