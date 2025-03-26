class_name FoliageDifference extends FoliageNode

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("", "", Type.POINT, true, true)
	create_port("", "Difference", Type.POINT, true, false)
	super(props)

# removes all points within the extents of diff
func gen(points: Array[Foliage3DPoint] = [], diff: Array[Foliage3DPoint] = []) -> Array:
	return [points.filter(func(p: Foliage3DPoint): return diff.find_custom(p.intersects) == -1) as Array[Foliage3DPoint]]

static func node_name():
	return  "Difference"
