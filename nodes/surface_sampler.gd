@tool
class_name FoliageSurfaceSampler extends FoliageNode

var spacing = 10.0
var point_size: Vector3 = Vector3(1, 1, 1)
var calculate_density: bool = true
var seed: int

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("", "", Type.POINT, false, true)
	create_port("spacing", "Spacing", Type.FLOAT, false, false, 0.001)
	create_port("point_size", "Size", Type.VECTOR3, false, false)
	create_port("calculate_density", "Calculate Density", Type.BOOL, false, false)
	create_port("seed", "Seed", Type.INT, false, false)
	super(props)

func gen() -> Array:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	var points: Array[Foliage3DPoint]
	if foliage.shape is BoxShape3D:
		var size = foliage.shape.size
		var x = -size.x/2
		while x < size.x/2:
			x += spacing/2
			var z = -size.z/2
			while z < size.z/2:
				z += spacing/2
				var offset = Vector3(rng.randf_range(-spacing/4, spacing/4), 0, rng.randf_range(-spacing/4, spacing/4))
				var position = Vector3(x, size.y/2, z) + foliage.global_position
				points.append(Foliage3DPoint.new(Transform3D(Basis(), position + offset), point_size))
	elif foliage.shape is SphereShape3D:
		var radius = foliage.shape.radius
		var phi = (1 + sqrt(5)) / 2
		var n = radius * radius / spacing
		for k in range(1, n + 1):
			var r = sqrt(k - 0.5) / sqrt(n - 1 / 2)
			var theta = k * 2 * PI / phi ** 2
			var offset = Vector3(rng.randf_range(-spacing/4, spacing/4), 0, rng.randf_range(-spacing/4, spacing/4))
			var position = offset + Vector3(r * cos(theta), 0, r * sin(theta)) * radius
			var transform = Transform3D(Basis(), position + foliage.global_position + Vector3(0, radius, 0))
			points.append(Foliage3DPoint.new(transform, point_size))
	else:
		push_error("foliage: shape not implemented")

	if points.size() == 0:
		return [points]

	# TODO *very* slow with many points
	if false and calculate_density:
		var min_distance: float = 1 << 31
		var max_distance: float
		var distances: Array[float]
		for i in range(points.size()):
			distances.append(0)
			var p1 = points[i]
			var matches: int
			for j in range(points.size()):
				var p2 = points[j]
				var distance = p1.transform.origin.distance_to(p2.transform.origin)
				if distance < p1.size.length() * 2:
					matches += 1
					distances[i] += distance
			distances[i] /= matches
			min_distance = min(min_distance, distances[i])
			max_distance = max(max_distance, distances[i])

		for i in range(distances.size()):
			points[i].density = remap(distances[i], min_distance, max_distance, 0.0, 1.0)

	for i in range(points.size()):
		var transform = points[i].transform
		transform.origin.y = foliage.terrain.data.get_height(transform.origin)
		var scale = transform.basis.get_scale()
		var normal = foliage.terrain.data.get_normal(transform.origin)
		transform.basis.y = normal
		transform.basis.z = -transform.basis.z.cross(normal)
		transform.basis.x = -transform.basis.x.cross(normal)
		transform.basis = transform.basis.orthonormalized().scaled(scale)
		points[i].transform = transform

	print_debug("sampled %d" % points.size())
	return [points]

static func node_name():
	return  "SurfaceSampler"
