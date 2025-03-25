@tool
class_name FoliageSplit extends FoliageNode

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("", "", Type.TRANSFORM, true, true)
	create_port("", "", Type.TRANSFORM, false, true)
	super(props)

func gen(transforms: Array[Transform3D]) -> Array:
	var t1: Array[Transform3D]
	var t2: Array[Transform3D]
	var i = 0
	while i < transforms.size():
		t1.append(transforms[i])
		if i+1 < transforms.size():
			t2.append(transforms[i+1])
		i += 2
	return [t1, t2]

static func node_name():
	return  "Split"
