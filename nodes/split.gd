@tool
class_name FoliageSplit extends FoliageNode

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("", "", Type.POINT, true, true)
	create_port("", "", Type.POINT, false, true)
	super(props)

func gen(points: Array[Foliage3DPoint]) -> Array:
	var p1: Array[Foliage3DPoint] = []
	var p2: Array[Foliage3DPoint] = []
	var i = 0
	while i < points.size():
		p1.append(points[i])
		if i+1 < points.size():
			p2.append(points[i+1])
		i += 2
	return [p1, p2]

static func node_name():
	return "Split"
