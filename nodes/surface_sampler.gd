@tool
class_name FoliageSurfaceSampler extends FoliageNode

var spacing = 10.0
var align_height: bool = true
var align_normal: bool = true

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("", "", Type.TRANSFORM, true, true)
	create_port("spacing", "Spacing", Type.FLOAT, false, false, 0.01)
	create_port("align_height", "Align Height", Type.BOOL, false, false)
	create_port("align_normal", "Align Normal", Type.BOOL, false, false)
	super(props)

func gen(input: Variant) -> Array:
	if foliage.shape == null:
		return []
	var transforms: Array[Transform3D]
	if input is Array[Transform3D]:
		transforms = input
	else:
		if foliage.shape is BoxShape3D:
			var size = foliage.shape.size
			var x = -size.x/2
			while x < size.x/2:
				x += spacing/2
				var z = -size.z/2
				while z < size.z/2:
					z += spacing/2
					var position = Vector3(x, size.y/2, z) + foliage.global_position
					transforms.append(Transform3D(Basis(), position))
		elif foliage.shape is SphereShape3D:
			var radius = foliage.shape.radius
			var phi = (1 + sqrt(5)) / 2
			var n = PI * radius * radius / (spacing * PI)
			for k in range(1, n + 1):
				var r = sqrt(k - 0.5) / sqrt(n - 1 / 2)
				var theta = k * 2 * PI / phi ** 2
				var position = Vector3(r * cos(theta), 0, r * sin(theta)) * radius
				transforms.append(Transform3D(Basis(), position + foliage.global_position + Vector3(0, radius, 0)))
		else:
			push_error("foliage: shape not implemented")

	if align_height:
		for i in range(transforms.size()):
			transforms[i].origin.y = foliage.terrain.data.get_height(transforms[i].origin)

	if align_normal:
		for i in range(transforms.size()):
			var transform = transforms[i]
			var scale = transform.basis.get_scale()
			var normal = foliage.terrain.data.get_normal(transform.origin)
			transform.basis.y = normal
			transform.basis.z = -transform.basis.z.cross(normal)
			transform.basis = transform.basis.orthonormalized().scaled(scale)
			transforms[i] = transform

	print_debug("sampled %d" % transforms.size())
	return [transforms]

static func node_name():
	return  "SurfaceSampler"
