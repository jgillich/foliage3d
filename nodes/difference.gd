class_name FoliageDifference extends FoliageNode

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("", "", Type.POINT, true, true)
	create_port("", "Difference", Type.POINT, true, false)
	super(props)

# removes all points within the extents of diff
func gen(input: Array[Foliage3DPoint] = [], diff: Array[Foliage3DPoint] = []) -> Array:
	var points: Array[Foliage3DPoint] = input.duplicate()
	for i in range(input.size()-1, -1, -1):
		for j in range(diff.size()):
			if input[i].intersects(diff[j]):
				points.remove_at(i)
				break
	return [points]

static func node_name():
	return  "Difference"
