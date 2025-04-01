@tool
extends Window

signal node_created(String, Vector2i)

@onready var tree: Tree = %Tree
var node_position: Vector2

func _ready() -> void:
	refresh()
	about_to_popup.connect(refresh)
	close_requested.connect(hide)
	focus_exited.connect(hide)

	tree.item_activated.connect(_on_item_activated)
	tree.item_selected.connect(_on_item_selected)
	tree.nothing_selected.connect(_on_nothing_selected)

	%CreateButton.pressed.connect(_on_item_activated)
	%CancelButton.pressed.connect(hide)

func refresh():
	tree.clear()
	var root = tree.create_item()

	for type in Foliage3DGraphEdit.NODES.keys():
		var item = tree.create_item(root)
		item.set_text(0, type)
		#item.set_tooltip_text(0, "description")
		item.set_metadata(0, type)

func _on_item_selected() -> void:
	var item = tree.get_selected()
	if item == null:
		_on_nothing_selected()
		return
	%CreateButton.disabled = false

func _on_nothing_selected() -> void:
	%CreateButton.disabled = true

func _on_item_activated() -> void:
	var selected = tree.get_selected()
	if selected == null:
		return
	node_created.emit(selected.get_metadata(0), node_position)
	hide()
