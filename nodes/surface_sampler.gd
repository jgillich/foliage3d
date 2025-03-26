@tool
class_name FoliageSurfaceSampler extends FoliageNode

var spacing = 10.0
var point_size: Vector3 = Vector3(1, 1, 1)
var align_height: bool = true
var align_normal: bool = true

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("", "", Type.POINT, true, true)
	create_port("spacing", "Spacing", Type.FLOAT, false, false, 0.01)
	create_port("point_size", "Size", Type.VECTOR3, false, false)
	create_port("align_height", "Align Height", Type.BOOL, false, false)
	create_port("align_normal", "Align Normal", Type.BOOL, false, false)
	super(props)

func gen(input: Array[Foliage3DPoint]) -> Array:
	if foliage.shape == null:
		return [[]]
	var points: Array[Foliage3DPoint]
	#if input is Array[Foliage3DPoint]:
		#points = input
	#else:
	if foliage.shape is BoxShape3D:
		var size = foliage.shape.size
		var x = -size.x/2
		while x < size.x/2:
			x += spacing/2
			var z = -size.z/2
			while z < size.z/2:
				z += spacing/2
				var position = Vector3(x, size.y/2, z) + foliage.global_position
				points.append(Foliage3DPoint.new(Transform3D(Basis(), position)))
	elif foliage.shape is SphereShape3D:
		var radius = foliage.shape.radius
		var phi = (1 + sqrt(5)) / 2
		var n = PI * radius * radius / (spacing * PI)
		for k in range(1, n + 1):
			var r = sqrt(k - 0.5) / sqrt(n - 1 / 2)
			var theta = k * 2 * PI / phi ** 2
			var position = Vector3(r * cos(theta), 0, r * sin(theta)) * radius
			var transform = Transform3D(Basis(), position + foliage.global_position + Vector3(0, radius, 0))
			points.append(Foliage3DPoint.new(transform, point_size))
	else:
		push_error("foliage: shape not implemented")

	# TODO MOVE OUT and remove input
	if align_height:
		for i in range(points.size()):
			points[i].transform.origin.y = foliage.terrain.data.get_height(points[i].transform.origin)

	if align_normal:
		for i in range(points.size()):
			var transform = points[i].transform
			var scale = transform.basis.get_scale()
			var normal = foliage.terrain.data.get_normal(transform.origin)
			transform.basis.y = normal
			transform.basis.z = -transform.basis.z.cross(normal)
			transform.basis = transform.basis.orthonormalized().scaled(scale)
			points[i].transform = transform

	print_debug("sampled %d" % points.size())
	return [points]

static func node_name():
	return  "SurfaceSampler"
