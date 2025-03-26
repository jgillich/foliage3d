class_name FoliagePrune extends FoliageNode

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("", "", Type.POINT, true, true)
	super(props)

# removes all points within the extents of self
func gen(points: Array[Foliage3DPoint]) -> Array:
	var result: Array[Foliage3DPoint]
	for p1 in points:
		var intersects: bool
		for p2 in points:
			if p1.transform == p2.transform:
				continue
			var a1 = AABB(p1.transform.origin, p1.extents)
			var a2 = AABB(p1.transform.origin, p1.extents)
			intersects = a1.intersects(a2)
			if intersects: break
		if not intersects:
			result.append(p1)

	return [result]

static func node_name():
	return  "Prune"
