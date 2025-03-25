@tool
extends EditorPlugin

var edit: FoliageEdit = FoliageEdit.new()
var button: Button

@onready var selection = EditorInterface.get_selection()
var current: Foliage3D

#var loader: FoliageGraph.Loader
#var saver: FoliageGraph.Saver

func _ready():
	#preload("./reloader.gd").new()
	selection.selection_changed.connect(_selection_changed)
	_selection_changed()

	button = add_control_to_bottom_panel(edit, "Foliage3D")
	add_custom_type("Foliage3D", "Node", Foliage3D, null)

	edit.changed.connect(func():
		if current != null:
			current.queue_gen()
	)

	#loader = FoliageGraph.Loader.new()
	#ResourceLoader.add_resource_format_loader(loader, true)
	#saver = FoliageGraph.Saver.new()
	#ResourceSaver.add_resource_format_saver(saver, true)

func _exit_tree():
	remove_control_from_bottom_panel(button)
	remove_custom_type("Foliage3D")
	selection.selection_changed.disconnect(_selection_changed)
	button.queue_free()
	#ResourceLoader.remove_resource_format_loader(loader)
	#ResourceSaver.remove_resource_format_saver(saver)

func _selection_changed():
	var node = selection.get_selected_nodes().get(0)
	if node is Foliage3D:
		edit.foliage = node
		current = node
