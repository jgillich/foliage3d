@tool
class_name FoliageMeshID extends FoliageNode

var id = 0

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("", "", Type.TRANSFORM, true, false)
	create_port("id", "ID", Type.INT, false, false)
	super(props)

func gen(transforms: Array[Transform3D]):
	print_debug("adding meshes ", transforms.size())
	foliage.terrain.instancer.force_update_mmis()
	foliage.terrain.instancer.clear_by_mesh(id)
	foliage.terrain.instancer.add_transforms(id, transforms)

static func node_name():
	return "MeshID"
