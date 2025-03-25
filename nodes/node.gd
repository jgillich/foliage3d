@tool
class_name FoliageNode extends GraphNode

var foliage: Foliage3D
var result: Variant = null
var _name: String = ""

enum Type { TRANSFORM, VECTOR3, FLOAT, INT, BOOL, SCENE }

var ports: Array[Port]

signal port_value_changed()

static func nodes() -> Array:
	return [FoliageSurfaceSampler, FoliageMesh, FoliageMeshID, FoliageSplit, FoliageTransform]

static func deserialize(dict: Dictionary) -> FoliageNode:
	for n in nodes():
		if dict.get("node") == n.node_name():
			var d = dict.duplicate()
			d.erase("node")
			return n.new(d)
	return null

func _init(props: Dictionary = {}) -> void:
	add_theme_constant_override("separation", 4)

	for k in props.keys():
		set(k, props[k])

	for i in range(ports.size()):
		var port = ports[i]
		var color: Color

		match port.type:
			Type.TRANSFORM:
				color = Color.BLUE
		set_slot(i, port.input, port.type, color, port.output,  port.type, color)
		add_child(port.get_control(self))

func serialize() -> Dictionary:
	var dict = {
		"node": title,
		"name": get_name(),
		"position_offset": position_offset
	}

	for port in ports:
		if port.prop.is_empty():
			continue
		dict[port.prop] = get(port.prop)

	return dict

func create_port(prop: String, name: String, type: Type, input: bool = false, output: bool = false, min: Variant = null):
	var port = Port.new()
	port.prop = prop
	port.name = name
	port.type = type
	port.input = input
	port.output = output
	port.min = min
	ports.append(port)

static func node_name():
	return ""

#
#func create_connection_row(left_label: String, right_label: String) -> Control:
	#var hbox = HBoxContainer.new()
	#var label = Label.new()
	#label.text = left_label
	#hbox.add_child(label)
	#label = label.duplicate()
	#label.text = right_label
	#hbox.add_child(label)
	#return hbox
#
#func create_float_row(label: String, value_changed: Callable, step = 0.01, min_value = 0.01) -> Control:
	#var hbox = HBoxContainer.new()
	#var lbl = Label.new()
	#lbl.text = label
	#hbox.add_child(lbl)
	#var spin = SpinBox.new()
	#spin.value = 1
	#spin.step = step
	#spin.min_value = min_value
	#spin.value_changed.connect(value_changed)
	#hbox.add_child(spin)
	#return hbox
#
#func create_int_row(label: String, value_changed: Callable) -> Control:
	#var hbox = HBoxContainer.new()
	#var lbl = Label.new()
	#lbl.text = label
	#hbox.add_child(lbl)
	#var spin = SpinBox.new()
	#spin.value_changed.connect(func(v: float): value_changed.call(int(v)))
	#hbox.add_child(spin)
	#return hbox

class Port:
	var prop: String
	var name: String
	var type: Type
	var input: bool
	var output: bool
	var min: Variant

	func get_control(node: FoliageNode):
		var vbox = VBoxContainer.new()
		var row1 = HBoxContainer.new()
		vbox.add_child(row1)
		if input:
			var label = Label.new()
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.text = "In"
			row1.add_child(label)

		if not prop.is_empty():
			var label = Label.new()
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.text = name
			row1.add_child(label)

			match type:
				Type.BOOL:
					var v = CheckBox.new()
					v.button_pressed = node.get(prop)
					v.size_flags_horizontal = Control.SIZE_EXPAND_FILL | Control.SIZE_SHRINK_END
					v.toggled.connect(func(value: bool):
						node.set(prop, value)
						node.port_value_changed.emit()
					)
					row1.add_child(v)
				Type.INT:
					var v = SpinBox.new()
					v.value = node.get(prop)
					v.max_value = 1 << 31
					v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					v.value_changed.connect(func(v: float):
						node.set(prop, int(v))
						node.port_value_changed.emit()
					)
					row1.add_child(v)
				Type.FLOAT:
					var v = SpinBox.new()
					v.value = node.get(prop)
					v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					v.max_value = 1 << 31
					v.min_value = -(1 << 31)
					if min != null:
						v.min_value = min
					v.step = 0.01
					v.value_changed.connect(func(v: float):
						node.set(prop, v)
						node.port_value_changed.emit()
					)
					row1.add_child(v)
				Type.VECTOR3:
					var x = SpinBox.new()
					var y = SpinBox.new()
					var z = SpinBox.new()
					x.get_line_edit().add_theme_constant_override("minimum_character_width", 3)
					y.get_line_edit().add_theme_constant_override("minimum_character_width", 3)
					z.get_line_edit().add_theme_constant_override("minimum_character_width", 3)
					var value: Vector3 = node.get(prop)
					x.value = value.x
					y.value = value.y
					z.value = value.z
					x.value_changed.connect(func(_v: float):
						node.set(prop, Vector3(x.value, y.value, z.value))
						node.port_value_changed.emit()
					)
					y.value_changed.connect(func(_v: float):
						node.set(prop, Vector3(x.value, y.value, z.value))
						node.port_value_changed.emit()
					)
					z.value_changed.connect(func(_v: float):
						node.set(prop, Vector3(x.value, y.value, z.value))
						node.port_value_changed.emit()
					)
					x.prefix = "x"
					y.prefix = "y"
					z.prefix = "z"
					x.alignment = HORIZONTAL_ALIGNMENT_FILL
					y.alignment = HORIZONTAL_ALIGNMENT_FILL
					z.alignment = HORIZONTAL_ALIGNMENT_FILL
					x.max_value = 1 << 31
					y.max_value = 1 << 31
					z.max_value = 1 << 31
					x.min_value = -(1 << 31)
					y.min_value = -(1 << 31)
					z.min_value = -(1 << 31)
					x.step = 0.01
					y.step = 0.01
					z.step = 0.01
					row1.add_child(x)
					row1.add_child(y)
					row1.add_child(z)

		if output:
			var label = Label.new()
			label.text = "Out"
			label.size_flags_horizontal = Control.SIZE_SHRINK_END | Control.SIZE_EXPAND_FILL
			row1.add_child(label)

		return vbox
