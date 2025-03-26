@tool
class_name FoliageDensityFilter extends FoliageNode

var lower_bound: float = 0.0
var upper_bound: float = 1.0

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("", "", Type.POINT, true, true)
	create_port("lower_bound", "Lower Bound", Type.FLOAT, false, false, 0.0, 1.0)
	create_port("upper_bound", "Upper Bound", Type.FLOAT, false, false, 0.0, 1.0)
	super(props)

func gen(input: Array[Foliage3DPoint]) -> Array:
	var output: Array[Foliage3DPoint]
	for point in input:
		if point.density < lower_bound or point.density > upper_bound:
			continue
		output.append(point)

	return [result]

static func node_name():
	return  "DensityFilter"
