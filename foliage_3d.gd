@tool
class_name Foliage3D extends Node3D

signal graph_changed()

@export var shape: Shape3D:
	set(value):
		shape = value
		debug_mesh.mesh = shape.get_debug_mesh()

@export var graph: FoliageGraph:
	set(value):
		if graph != null:
			graph.changed.disconnect(queue_gen)
		graph = value
		graph.changed.connect(queue_gen)
		graph_changed.emit()

# region>mesh>transform
@export var generated: Dictionary[Vector2i, Dictionary] = {}

var terrain: Terrain3D
var timer: SceneTreeTimer
var num_timer: int

var debug_mesh: MeshInstance3D = MeshInstance3D.new()

func _enter_tree() -> void:
	add_child(debug_mesh)
	set_notify_transform(true)
	terrain = get_parent()

func _exit_tree() -> void:
	if graph != null:
		graph.changed.disconnect(queue_gen)

func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			queue_gen()

func _get_configuration_warnings():
	if terrain == null:
		return ["Foliage3D must be child of Terrain3D"]
	return []

func queue_gen():
	num_timer += 1
	timer = get_tree().create_timer(0.5)
	timer.timeout.connect(func():
		num_timer -= 1
		if num_timer == 0:
			gen()
	)

func gen():
	# https://terrain3d.readthedocs.io/en/latest/api/class_terrain3dregion.html#class-terrain3dregion-property-instances
	var regions := terrain.data.get_regions_all()


	for region in regions:
		#TODO we get spammed with "Empty cell in region" if we don't always clear them, why?
		#if not generated.has(region):
			#continue
		var instances = regions[region].get_instances()
		for mesh in instances.keys():
			#if not generated[region].has(mesh):
				#continue
			var cells = instances[mesh]
			for cell in cells.keys():
				var arr = cells[cell]
				var xforms = arr[0]
				instances[mesh][cell][0] = xforms.filter(func(xform: Transform3D):
					if not generated.has(region) or not generated[region].has(mesh):
						return true
					return not generated[region][mesh].has(xform)
				)
				if instances[mesh][cell][0].is_empty():
					instances[mesh].erase(cell)

	generated = {}
	terrain.instancer.force_update_mmis()

	var nodes: Array[FoliageNode]
	for n in graph.nodes:
		var node = FoliageNode.deserialize(n)
		node.foliage = self
		nodes.append(node)

	for i in range(100):
		var pending: int = 0
		for node in nodes:
			if node.result != null:
				continue
			var inputs = get_inputs(nodes, node)
			if inputs == null:
				pending += 1
				continue
			node.result = node.gen.callv(inputs)
		if pending == 0:
			return

	push_error("foliage: too many iterations")

func get_inputs(nodes: Array[FoliageNode], node: FoliageNode) -> Variant:
	if node.get_input_port_count()  == 0:
		return []
	var inputs: Array
	inputs.resize(node.get_input_port_count())
	for connection in graph.connections:
		if connection["to_node"] != node.get_name():
			continue
		var from = nodes.filter(func(n: FoliageNode): return n.name == connection["from_node"])
		if from.size() == 0:
			return inputs
		if from[0].result == null:
			return null
		inputs[connection["to_port"]] = from[0].result[connection["from_port"]]

	return inputs

func _validate_property(property: Dictionary):
	if property.name in ["generated"]:
		property.usage = PROPERTY_USAGE_NO_EDITOR
