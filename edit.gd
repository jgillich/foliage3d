@tool
class_name FoliageEdit extends GraphEdit

signal changed()

@onready var node_popup: Window = preload("res://addons/foliage_3d/node_popup.tscn").instantiate()

var foliage: Foliage3D:
	set(value):
		if foliage != null:
			foliage.graph_changed.disconnect(_on_graph_changed)
		foliage = value
		if foliage != null:
			_on_graph_changed()
			foliage.graph_changed.connect(_on_graph_changed)

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
		if fn == null:
			push_error("foliage: failed to deserialize ", node)
			continue
		fn.port_value_changed.connect(save)
		add_child(fn)

	for connection in foliage.graph.connections:
		connection["from_node"] = connection["from_node"].validate_node_name()
		connection["to_node"] = connection["to_node"].validate_node_name()
		var err = connect_node(connection["from_node"], connection["from_port"], connection["to_node"], connection["to_port"])
		if err != OK:
			push_error("foliage: connect_node error %d" % err)

	queue_redraw()

func _on_node_created(node: FoliageNode, node_offset: Vector2):
	node.port_value_changed.connect(save)
	node.position_offset = node_offset
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
	node_popup.node_position = (get_local_mouse_position() + scroll_offset) / zoom
	node_popup.popup(Rect2i(Vector2i(DisplayServer.mouse_get_position()), node_popup.size))
