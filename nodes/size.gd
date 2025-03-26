class_name FoliageSize extends FoliageNode

var point_size: Vector3 = Vector3(1, 1, 1)

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("In", "Out", Type.POINT, true, true)
	create_port("point_size", "Size", Type.VECTOR3, false, false)
	super(props)

# removes all points within the extents of self
func gen(points: Array[Foliage3DPoint]) -> Array:
	var result := points.duplicate()
	for i in range(result.size()):
		result[i].size = point_size

	return [result]

static func node_name():
	return  "Size"
