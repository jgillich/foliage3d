@tool
extends GraphEdit

const Foliage3DGraphEditNode = preload("res://addons/foliage_3d/graph_edit_node.gd")

signal changed()
signal mesh_xforms_added(region: Vector2i, mesh: int, xforms: Array[Vector3])

@onready var node_popup: Window = preload("res://addons/foliage_3d/node_popup.tscn").instantiate()

var resource: Foliage3DGraph
var terrain: Terrain3D
var bounds: Foliage3DBounds

func _init(p_resource: Foliage3DGraph, p_terrain: Terrain3D, p_bounds: Foliage3DBounds):
	resource = p_resource
	terrain = p_terrain
	bounds = p_bounds
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _ready():
	for params in resource.nodes:
		var node = create_node(params["resource_name"], params)
		add_child(node)

	for connection in resource.connections:
		connection["from_node"] = connection["from_node"].validate_node_name()
		connection["to_node"] = connection["to_node"].validate_node_name()
		var err = connect_node(connection["from_node"], connection["from_port"], connection["to_node"], connection["to_port"])
		if err != OK:
			push_error("foliage: connect_node error %d" % err)

	add_child(node_popup)
	node_popup.node_created.connect(_on_node_created)
	popup_request.connect(_show_add_node_popup)
	connection_request.connect(_on_connection_request)
	delete_nodes_request.connect(_on_delete_nodes_request)
	disconnection_request.connect(_on_disconnection_request)
	end_node_move.connect(_on_end_node_move)
	node_selected.connect(_on_node_selected)

	add_valid_connection_type(TYPE_TRANSFORM3D, TYPE_TRANSFORM3D)

	right_disconnects = true

func create_node(type: String, params: Dictionary = {}) -> Foliage3DGraphEditNode:
	var node = Foliage3DGraphEditNode.new(type, bounds, terrain, params)
	node.changed.connect(func():
		save()
		changed.emit()
	)
	node.mesh_xforms_added.connect(mesh_xforms_added.emit)
	return node

func generate():
	var nodes: Dictionary[String, Foliage3DNode]
	for child in get_children():
		if child is Foliage3DGraphEditNode:
			nodes[str(child.name)] = child.node

	var executor = Foliage3DExecutor.new()
	executor.execute(nodes, connections)

func save():
	resource.nodes = []
	resource.connections = connections

	for node in get_children():
		if node is Foliage3DGraphEditNode:
			var dict = {
				"name": node.get_name().validate_node_name(),
				"position_offset": node.position_offset
			}
			for prop in node.node.get_property_list():
				if (prop.usage & PROPERTY_USAGE_STORAGE) == 0:
					continue
				if ["terrain", "slots", "script"].has(prop["name"]):
					continue
				dict[prop["name"]] = node.node.get(prop["name"])
			resource.nodes.append(dict)

	ResourceSaver.save(resource, resource.resource_path)

func _on_node_selected(node):
	EditorInterface.edit_resource(node.node)

func _on_node_created(type: String, node_offset: Vector2):
	var node = create_node(type)
	node.position_offset = node_offset
	add_child(node)
	save()

func _on_connection_request(from: StringName, fport: int, to: StringName, tport: int):
	if from == to:
		return
	connect_node(from, fport, to, tport)
	save()
	changed.emit()


func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	for node in nodes:
		get_node(NodePath(node)).queue_free()
	save()
	changed.emit()

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)
	save()
	changed.emit()

func _on_end_node_move():
	save()

func _show_add_node_popup(click_position: Vector2i) -> void:
	node_popup.node_position = (get_local_mouse_position() + scroll_offset) / zoom
	node_popup.popup(Rect2i(Vector2i(DisplayServer.mouse_get_position()), node_popup.size))
