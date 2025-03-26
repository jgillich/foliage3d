@tool
class_name FoliageEdit extends GraphEdit

signal changed()

@onready var node_popup: Window = preload("res://addons/procedural_foliage/node_popup.tscn").instantiate()

var foliage: Foliage3D:
	set(value):
		if foliage != null:
			foliage.graph_changed.disconnect(_on_graph_changed)
		foliage = value
		if foliage != null:
			_on_graph_changed()
			foliage.graph_changed.connect(_on_graph_changed)

#func _init():
	#resource = res


	#print(graph.nodes[0].density)
	#var node = FoliageSurfaceSampler.new()
	#node.density = 1000
	#graph.nodes.append(node)
	#ResourceSaver.save(graph, graph.resource_path)

func _ready():
	add_child(node_popup)
	node_popup.node_created.connect(_on_node_created)
	popup_request.connect(_show_add_node_popup)
	connection_request.connect(_on_connection_request)
	delete_nodes_request.connect(_on_delete_nodes_request)
	disconnection_request.connect(_on_disconnection_request)

	add_valid_connection_type(0, 0)
	add_valid_connection_type(1, 1)
	right_disconnects = true

func save():
	if foliage == null or foliage.graph == null:
		print("save: graph null")
		return
	foliage.graph.nodes = []
	for node in get_children():
		if node is FoliageNode:
			foliage.graph.nodes.append(node.serialize())
	foliage.graph.connections = connections
	ResourceSaver.save(foliage.graph, foliage.graph.resource_path)
	changed.emit()

func _on_graph_changed():
	for child in get_children():
		if child is FoliageNode:
			remove_child(child)
	if foliage.graph == null:
		push_warning("foliage: resource is null")
		return
	for child in get_children():
		if child is FoliageNode:
			remove_child(child)
	for node in foliage.graph.nodes:
		var fn = FoliageNode.deserialize(node)
		fn.port_value_changed.connect(save)
		add_child(fn)
	for connection in foliage.graph.connections:
		connect_node(connection["from_node"], connection["from_port"], connection["to_node"], connection["to_port"])
	queue_redraw()

func _on_node_created(node: FoliageNode):
	node.port_value_changed.connect(save)
	add_child(node)
	save()

func _on_connection_request(from: StringName, fport: int, to: StringName, tport: int):
	if from == to:
		return
	connect_node(from, fport, to, tport)
	save()

func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	for node in nodes:
		get_node(NodePath(node)).queue_free()
	save()

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)
	save()

func _show_add_node_popup(click_position: Vector2i) -> void:
	node_popup.popup(Rect2i(Vector2i(DisplayServer.mouse_get_position()), node_popup.size))
