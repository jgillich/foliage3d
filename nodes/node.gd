@tool
class_name FoliageNode extends GraphNode

var foliage: Foliage3D
var result: Variant = null
var _name: String = ""

enum Type { POINT, VECTOR3, FLOAT, INT, BOOL, STRING }

var ports: Array[Port]

signal port_value_changed()

static func nodes() -> Array:
	return [
		FoliageSurfaceSampler,
		FoliageMeshID,
		FoliageSplit,
		FoliageTransform,
		FoliageDensityFilter,
		FoliageDifference,
		FoliagePrune,
		FoliageSize,
		#FoliageAlign,
		FoliageFilter,
	]

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
			Type.POINT:
				color = Color.BLUE
		set_slot(i, port.input, port.type, color, port.output,  port.type, color)
		add_child(port.get_control(self))

func add_transforms(mesh: int, xforms: Array[Transform3D]):
	if mesh >= foliage.terrain.assets.get_mesh_count():
		push_warning("foliage: mesh %d out of range" % mesh)
		return
	var dict: Dictionary = {}
	var asset := foliage.terrain.assets.get_mesh_asset(mesh)
	for i in range(xforms.size()):
		var xform = xforms[i]
		xform.origin += xform.basis.y * asset.height_offset
		var loc = foliage.terrain.data.get_region_location(xform.origin)
		var region: Array[Transform3D] = dict.get_or_add(loc, [] as Array[Transform3D])
		region.append(xform)
		xforms[i] = xform

	for loc in dict.keys():
		var colors: PackedColorArray = []
		colors.resize(dict[loc].size())
		colors.fill(Color.WHITE)

		var region = foliage.terrain.data.get_region(loc)
		var global_local_offset = Vector3(loc.x, 0, loc.y) * region.region_size * foliage.terrain.vertex_spacing
		for i in range(dict[loc].size()):
			dict[loc][i].origin -= global_local_offset
			foliage.generated.get_or_add(loc, {}).get_or_add(mesh, []).append(dict[loc][i])

		foliage.terrain.instancer.append_region(region, mesh, dict[loc], colors)

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

func create_port(prop: String, name: String, type: Type, input: bool = false, output: bool = false, min: Variant = null, max: Variant = null, step: Variant = null):
	var port = Port.new()
	port.prop = prop
	port.name = name
	port.type = type
	port.input = input
	port.output = output
	port.min = min
	port.max = max
	ports.append(port)

static func node_name():
	return ""

class Port:
	var prop: String
	var name: String
	var type: Type
	var input: bool
	var output: bool
	var min: Variant
	var max: Variant
	var step: Variant

	func get_control(node: FoliageNode):
		var vbox = VBoxContainer.new()
		var row1 = HBoxContainer.new()
		vbox.add_child(row1)
		if input:
			var label = Label.new()
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.text = "In"
			if not name.is_empty():
				label.text = name
			row1.add_child(label)

		if not prop.is_empty():
			var label = Label.new()
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.text = name
			row1.add_child(label)

			match type:
				Type.STRING:
					var l = LineEdit.new()
					l.text = node.get(prop)
					l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					l.text_changed.connect(func(v: String):
						node.set(prop, v)
						node.port_value_changed.emit()
					)
					row1.add_child(l)
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
					if min != null:
						v.min_value = min
					if max != null:
						v.max_value = max
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
					if max != null:
						v.max_value = max
					v.step = 0.01
					if step != null:
						v.step = step
					elif min != null and min < v.step:
						v.step = min
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
			if not name.is_empty():
				label.text = name
			label.size_flags_horizontal = Control.SIZE_SHRINK_END | Control.SIZE_EXPAND_FILL
			row1.add_child(label)

		return vbox
