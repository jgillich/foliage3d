@tool
class_name FoliageMeshID extends FoliageNode

var id = 0

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("", "", Type.POINT, true, false)
	create_port("id", "ID", Type.INT, false, false)
	super(props)

func gen(points: Array[Foliage3DPoint]) -> int:
	var xforms: Array[Transform3D]
	xforms.assign(points.map(func(p: Foliage3DPoint): return p.transform))
	add_transforms(id, xforms)

	return OK

static func node_name():
	return "MeshID"
