@tool
class_name Foliage3DSurfaceSampler extends Foliage3DNode

@export var spacing: float = 10.0:
	set(value):
		spacing = value
		changed.emit()

@export var point_extents: Vector3 = Vector3(1, 1, 1):
	set(value):
		point_extents = value
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

			if is_nan(position.y):
				position.y = 0

			if not bounds.contains(position):
				continue

			var normal = get_normal(position)
			if is_nan(normal.x):
				normal = Vector3.UP

			var basis: Basis
			if normal != Vector3.UP:
				var tangent = normal.cross(Vector3.UP).normalized()
				var bitangent = tangent.cross(normal).normalized()
				basis = Basis(tangent, normal, bitangent)

			var transform = Transform3D(basis, position)
			points.append(Foliage3DPoint.new(transform, point_extents))

	return [points]
