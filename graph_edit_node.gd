@tool
class_name Foliage3DGraphEditNode extends GraphNode

signal changed()
signal mesh_xforms_added(region: Vector2i, mesh: int, xforms: Array[Vector3])

var node: Foliage3DNode

func _init(type: String, bounds: Foliage3DBounds, terrain: Terrain3D, props: Dictionary = {}):
	node = Foliage3DGraphEdit.NODES[type].new()
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
		if ["terrain", "slots", "script"].has(prop["name"]):
			continue
		if props.has(prop["name"]):
			node.set(prop["name"], props[prop["name"]])
		#add_child(create_prop(prop))
#
#func create_prop(prop: Dictionary):
	#var row = HBoxContainer.new()
	#var label = Label.new()
	#label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#label.text = prop.name
	#row.add_child(label)
#
	#match prop.type:
		#TYPE_BOOL:
			#var check_box := CheckBox.new()
			#check_box.button_pressed = node.get(prop.name)
			#check_box.size_flags_horizontal = Control.SIZE_SHRINK_END
			#check_box.toggled.connect(func(value: bool):
				#node.set(prop.name, value)
				#changed.emit()
			#)
			#row.add_child(check_box)
		#TYPE_INT:
			#var spin_box := SpinBox.new()
			#spin_box.size_flags_horizontal = Control.SIZE_SHRINK_END
			#spin_box.min_value = 0
			#spin_box.max_value = 1 << 31
			#spin_box.value = node.get(prop.name)
			#spin_box.value_changed.connect(func(v: float):
				#node.set(prop.name, int(v))
				#changed.emit()
			#)
			#row.add_child(spin_box)
		#TYPE_FLOAT:
			#var spin_box := SpinBox.new()
			#spin_box.min_value = -(1 << 31)
			#spin_box.max_value = 1 << 31
			#spin_box.step = 0.01
			#spin_box.size_flags_horizontal = Control.SIZE_SHRINK_END
			#spin_box.value = node.get(prop.name)
			#spin_box.value_changed.connect(func(v: float):
				#node.set(prop.name, v)
				#changed.emit()
			#)
			#row.add_child(spin_box)
		#TYPE_VECTOR3:
			#var x := SpinBox.new()
			#var y := SpinBox.new()
			#var z := SpinBox.new()
			#x.get_line_edit().add_theme_constant_override("minimum_character_width", 3)
			#y.get_line_edit().add_theme_constant_override("minimum_character_width", 3)
			#z.get_line_edit().add_theme_constant_override("minimum_character_width", 3)
			#x.max_value = 1 << 31
			#y.max_value = 1 << 31
			#z.max_value = 1 << 31
			#x.min_value = -(1 << 31)
			#y.min_value = -(1 << 31)
			#z.min_value = -(1 << 31)
			#x.step = 0.01
			#y.step = 0.01
			#z.step = 0.01
			#var value = node.get(prop.name)
			#x.value = value.x
			#y.value = value.y
			#z.value = value.z
			#x.value_changed.connect(func(_v: float):
				#node.set(prop.name, Vector3(x.value, y.value, z.value))
				#changed.emit()
			#)
			#y.value_changed.connect(func(_v: float):
				#node.set(prop.name, Vector3(x.value, y.value, z.value))
				#changed.emit()
			#)
			#z.value_changed.connect(func(_v: float):
				#node.set(prop.name, Vector3(x.value, y.value, z.value))
				#changed.emit()
			#)
			#x.prefix = "x"
			#y.prefix = "y"
			#z.prefix = "z"
			#x.alignment = HORIZONTAL_ALIGNMENT_FILL
			#y.alignment = HORIZONTAL_ALIGNMENT_FILL
			#z.alignment = HORIZONTAL_ALIGNMENT_FILL
			#row.add_child(x)
			#row.add_child(y)
			#row.add_child(z)
#
	#return row
