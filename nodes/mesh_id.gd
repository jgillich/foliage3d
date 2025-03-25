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


	#foliage.terrain.instancer.clear_by_mesh(id)
	# added_transforms[region][mesh][cell] = []
	#for xform in transforms:
	#	var region = foliage.terrain.data.get_region(xform.origin)

	#foliage.terrain.instancer.append_region()


	add_transforms(id, transforms)

static func node_name():
	return "MeshID"
