@tool
extends GraphNode

signal changed()
signal mesh_xforms_added(region: Vector2i, mesh: int, xforms: Array[Vector3])

var node: Foliage3DNode

func _init(type: String, bounds: Foliage3DBounds, terrain: Terrain3D, props: Dictionary = {}):
	node = Foliage3D.NODES[type].new()
	node.changed.connect(changed.emit)
	node.mesh_xforms_added.connect(mesh_xforms_added.emit)
	node.terrain3d = terrain
	node.bounds = bounds
	title = type

	if not props.is_empty():
		name = props["name"]
		position_offset = props["position_offset"]

	for i in range(max(node.get_inputs().size(), node.get_outputs().size())):
		var hbox := HBoxContainer.new()
		var has_input: bool
		var input_type = TYPE_VECTOR3
		if node.get_inputs().size() > i:
			has_input = true
			input_type = node.get_inputs()[i]
			var label = Label.new()
			label.text = "in"
			hbox.add_child(label)
		var has_output: bool
		var output_type = TYPE_VECTOR3
		if node.get_outputs().size() > i:
			has_output = true
			output_type = node.get_outputs()[i]
			var label = Label.new()
			label.text = "out"
			label.size_flags_horizontal = Control.SIZE_SHRINK_END | Control.SIZE_EXPAND
			hbox.add_child(label)
		set_slot(i, has_input, input_type, Color.BLUE, has_output, output_type, Color.BLUE)
		add_child(hbox)

	for prop in node.get_property_list():
		if (prop.usage & PROPERTY_USAGE_STORAGE) == 0:
			continue
		# TODO not sure why all C++ props are included
		if ["terrain", "slots", "script", "resource_name"].has(prop["name"]):
			continue
		if props.has(prop["name"]):
			node.set(prop["name"], props[prop["name"]])
