@tool
extends EditorPlugin

#var inspector_plugin = Foliage3DEditorInspectorPlugin.new()

var container: BoxContainer = BoxContainer.new()
var button: Button

@onready var selection = EditorInterface.get_selection()
var current: Foliage3D

#var loader: FoliageGraph.Loader
#var saver: FoliageGraph.Saver

func _ready():
	#add_inspector_plugin(inspector_plugin)

	selection.selection_changed.connect(_selection_changed)
	_selection_changed()

	container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	container.grow_vertical = Control.GROW_DIRECTION_BOTH

	button = add_control_to_bottom_panel(container, "Foliage3D")
	add_custom_type("Foliage3D", "Node3D", Foliage3D, null)

	#graph_edit.changed.connect(func():
		#if current != null:
			#current.queue_gen()
	#)

	#loader = FoliageGraph.Loader.new()
	#ResourceLoader.add_resource_format_loader(loader, true)
	#saver = FoliageGraph.Saver.new()
	#ResourceSaver.add_resource_format_saver(saver, true)

func _exit_tree():
	#remove_inspector_plugin(inspector_plugin)
	remove_control_from_bottom_panel(button)
	remove_custom_type("Foliage3D")
	selection.selection_changed.disconnect(_selection_changed)
	button.queue_free()
	#ResourceLoader.remove_resource_format_loader(loader)
	#ResourceSaver.remove_resource_format_saver(saver)

func _selection_changed():
	var nodes = selection.get_selected_nodes()
	if nodes.is_empty():
		return
	var foliage = nodes[0]
	if foliage is Foliage3D:
		if not foliage.graph_changed.is_connected(add_graph_edit):
			foliage.graph_changed.connect(add_graph_edit.bind(foliage))
		add_graph_edit(foliage)

func add_graph_edit(foliage: Foliage3D):
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
	if is_instance_valid(foliage.graph) and is_instance_valid(foliage.terrain):
		container.add_child(foliage.create_edit())
