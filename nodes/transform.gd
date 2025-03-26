@tool
class_name FoliageTransform extends FoliageNode

var offset_min: Vector3
var offset_max: Vector3
var rotation_min: Vector3
var rotation_max: Vector3
var scale_min: Vector3 = Vector3(1, 1, 1)
var scale_max: Vector3 = Vector3(1, 1, 1)
var scale_uniform: bool = true
var seed: int

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("", "", Type.POINT, true, true)
	create_port("offset_min", "Offset Min", Type.VECTOR3, false, false)
	create_port("offset_max", "Offset Max", Type.VECTOR3, false, false)
	create_port("rotation_min", "Rotation Min", Type.VECTOR3, false, false)
	create_port("rotation_max", "Rotation Max", Type.VECTOR3, false, false)
	create_port("scale_min", "Scale Min", Type.VECTOR3, false, false)
	create_port("scale_max", "Scale Max", Type.VECTOR3, false, false)
	create_port("scale_uniform", "Scale Uniform", Type.BOOL, false, false)

	create_port("seed", "Seed", Type.INT, false, false)
	super(props)

func gen(points: Array[Foliage3DPoint] = []) -> Array:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	var result: Array[Foliage3DPoint] = points.duplicate()

	if offset_min != Vector3.ZERO or offset_max != Vector3.ZERO:
		for i in range(result.size()):
			var transform = result[i].transform
			transform.origin.x += rng.randf_range(offset_min.x, offset_max.x)
			transform.origin.y += rng.randf_range(offset_min.y, offset_max.y)
			transform.origin.z += rng.randf_range(offset_min.z, offset_max.z)
			result[i].transform = transform

	if rotation_min != Vector3.ZERO or rotation_max != Vector3.ZERO:
		for i in range(result.size()):
			var transform = result[i].transform
			transform.basis = transform.basis.rotated(Vector3(1, 0, 0), deg_to_rad(rng.randf_range(rotation_min.x, rotation_max.x)))
			transform.basis = transform.basis.rotated(Vector3(0, 1, 0), deg_to_rad(rng.randf_range(rotation_min.y, rotation_max.y)))
			transform.basis = transform.basis.rotated(Vector3(0, 0, 1), deg_to_rad(rng.randf_range(rotation_min.z, rotation_max.z)))
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

static func node_name():
	return  "Transform"
