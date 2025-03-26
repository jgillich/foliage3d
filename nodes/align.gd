@tool
class_name FoliageAlign extends FoliageNode

var align_height: bool = true
var align_normal: bool = true

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("", "", Type.POINT, true, true)
	create_port("align_height", "Align Height", Type.BOOL, false, false)
	create_port("align_normal", "Align Normal", Type.BOOL, false, false)
	super(props)

# TODO aligning twice produces bad results, this node probably shouldn't exist
# check pcg
func gen(input: Array[Foliage3DPoint]) -> Array:
	var points: Array[Foliage3DPoint] = input.duplicate()

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

	return [points]

static func node_name():
	return  "Align"
