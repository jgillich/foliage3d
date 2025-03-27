@tool
class_name Foliage3D extends Node3D

signal graph_changed()

@export_tool_button("Generate", "Callable") var _gen = gen
@export_tool_button("Clear", "Callable") var _clear = clear

@export var save_to_data: bool = false
@export var auto_generate: bool = true
@export var time_limit: int = 30

@export var shape: Shape3D:
	set(value):
		shape = value
		debug_mesh.mesh = shape.get_debug_mesh()
		queue_gen()

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
var timer: Timer
var num_timer: int

var debug_mesh: MeshInstance3D = MeshInstance3D.new()

func _ready() -> void:
	if not get_parent() is Terrain3D:
		return
	terrain = get_parent()

	timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.timeout.connect(gen)
	add_child(timer)

	add_child(debug_mesh)
	set_notify_transform(true)

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
	if not auto_generate:
		return
	if timer != null:
		timer.start()

func gen():
	clear()

	var nodes: Array[FoliageNode]
	for n in graph.nodes:
		var node = FoliageNode.deserialize(n)
		node.foliage = self
		nodes.append(node)

	gen_next(nodes, Time.get_ticks_msec())


	if save_to_data:
		for region in generated.keys():
			terrain.data.save_region(region, terrain.data_directory, terrain.save_16_bit)
			#print_debug("saving data", region.location)
			#foliage.terrain.data.save_region(region.location, foliage.terrain.data_directory)
	#foliage.terrain.data.save_directory(foliage.terrain.data_directory)
#
	#var regions = foliage.terrain.data.get_regions_active()
	#for region in regions:
		#



func gen_next(nodes: Array[FoliageNode], time: int):
	var pending: int = 0
	if Time.get_ticks_msec() - time > (time_limit*1000):
		push_warning("foliage: generation time limit exceeded")
		return

	#var threads: Dictionary[FoliageNode, Thread]

	for node in nodes:
		if node.result != null:
			continue

		var inputs = get_inputs(nodes, node)
		if inputs == null:
			pending += 1
			continue

		var start_time = Time.get_ticks_msec()
		node.result = node.gen.callv(inputs)
		if node.result == null:
			push_error("foliage: node %s returned null" % node.node_name())
			return
		elif node.result is Array and node.result.size() == 0:
			push_error("foliage: node %s returned empty" % node.node_name())
			return

		var gen_time = Time.get_ticks_msec() - start_time
		if gen_time > 100:
			print_debug("%s processed in %d" % [node.node_name(), gen_time])

		#TODO? some nodes could use threads, but some require terrain access
		#var thread = Thread.new()
		#thread.set_thread_safety_checks_enabled(false)
		#thread.start(node.gen.bindv(inputs))
		#threads[node] = thread
#
	#for node in threads:
		#var thread = threads[node]
		#var result = thread.wait_to_finish()
		#node.result = result
		#if result == null:
			#push_error("foliage: node %s returned null" % node.node_name())
			#return
		#elif result is Array and result.size() == 0:
			#push_error("foliage: node %s returned empty" % node.node_name())
			#return
#
	if pending > 0:
		gen_next(nodes, time)




func get_inputs(nodes: Array[FoliageNode], node: FoliageNode) -> Variant:
	var inputs = []

	for i in range(node.ports.size()):
		var port = node.ports[i]
		if not port.input:
			continue
		#inputs.resize(i+1)
		match port.type:
			FoliageNode.Type.POINT:
				inputs.append([] as Array[Foliage3DPoint])
			_:
				push_warning("missing port type")
				inputs.append([])

		for connection in graph.connections:
			if connection["to_node"] != node.get_name() or connection["to_port"] != i:
				continue
			var from = nodes.filter(func(n: FoliageNode): return n.name == connection["from_node"])
			if from.size() == 0:
				continue
			var result = from[0].result
			if result == null:
				return null
			if result.size() <= connection["from_port"]:
				push_error("foliage: missing output on %s " % from[0].node_name())
				inputs[i].append_array([])
				continue

			inputs[i].append_array(result[connection["from_port"]])


	return inputs

func clear():
	# https://terrain3d.readthedocs.io/en/latest/api/class_terrain3dregion.html#class-terrain3dregion-property-instances
	var regions := terrain.data.get_regions_active()
	for region in regions:
		#TODO we get spammed with "Empty cell in region" if we don't always clear them, why?
		#if not generated.has(region):
			#continue
		var instances = region.instances
		for mesh in instances.keys():
			#if not generated[region].has(mesh):
				#continue
			var cells = instances[mesh]
			for cell in cells.keys():
				var arr = cells[cell]
				var xforms = arr[0]
				instances[mesh][cell][0] = xforms.filter(func(xform: Transform3D):
					if not generated.has(region.location) or not generated[region.location].has(mesh):
						return true
					return not generated[region.location][mesh].has(xform)
				)
				if instances[mesh][cell][0].is_empty():
					instances[mesh].erase(cell)

	generated = {}
	terrain.instancer.force_update_mmis()

func _validate_property(property: Dictionary):
	if property.name in ["generated"]:
		property.usage = PROPERTY_USAGE_NO_EDITOR
