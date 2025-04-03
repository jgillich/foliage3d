@tool
class_name Foliage3D extends Node3D

const Foliage3DGraphEdit := preload("res://addons/foliage_3d/graph_edit.gd")

static var NODES = {
	"Difference": Foliage3DDifference,
	"Prune": Foliage3DPrune,
	"SurfaceSampler": Foliage3DSurfaceSampler,
	"MeshSpawner": Foliage3DMeshSpawner,
	"TransformPoint": Foliage3DTransformPoint,
	"Filter": Foliage3DFilter,
	"FilterPoint": Foliage3DFilterPoint,
	"Slice": Foliage3DSlice,
}

signal graph_changed()

@export_tool_button("Generate", "Callable") var _gen = generate
@export_tool_button("Clear", "Callable") var _clear = clear
@export_tool_button("Save", "Callable") var _save = save


@export var auto_generate: bool = true
@export var auto_save: bool = false

@export var graph: Foliage3DGraph:
	set(value):
		graph = value
		graph_changed.emit()

# region>mesh>transform
@export var generated: Dictionary[Vector2i, Dictionary] = {}

var terrain: Terrain3D
var timer: Timer
var num_timer: int

var bounds := Foliage3DBounds.new()
var edit: Foliage3DGraphEdit

func _ready() -> void:
	if not get_parent() is Terrain3D:
		return
	terrain = get_parent()

	timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.timeout.connect(generate)
	add_child(timer)

	set_notify_transform(true)

	update_bounds()

#func _exit_tree() -> void:
	#if graph != null:
		#graph.changed.disconnect(queue_gen)

func create_edit() -> Foliage3DGraphEdit:
	edit = Foliage3DGraphEdit.new(graph, terrain, bounds)
	edit.changed.connect(queue_generate)
	edit.mesh_xforms_added.connect(func(region: Vector2i, mesh: int, xforms: Array[Transform3D]):
		generated.get_or_add(region, {}).get_or_add(mesh, []).append_array(xforms)
	)
	return edit

func update_bounds():
	var shapes: Array[CollisionShape3D]
	for child in get_children():
		if child is CollisionShape3D:
			shapes.append(child)
	bounds.set_shapes(shapes)

func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			queue_generate()

func _get_configuration_warnings():
	if terrain == null:
		return ["Foliage3D must be child of Terrain3D"]
	return []

func queue_generate():
	if not auto_generate:
		return
	if timer != null:
		timer.start()

func generate():
	update_bounds()
	clear()
	edit.generate()
	if auto_save:
		save()

func clear():
	# https://terrain3d.readthedocs.io/en/latest/api/class_terrain3dregion.html#class-terrain3dregion-property-instances
	var regions := terrain.data.get_regions_active()
	for region in regions:
		#TODO we get spammed with "Empty cell in region" if we don't always clear them, why?
		if not generated.has(region.location):
			continue
		region.set_modified(true)
		var instances = region.instances
		for mesh in instances.keys():
			if not generated[region.location].has(mesh):
				continue
			var cells = instances[mesh]
			for cell in cells.keys():
				var arr = cells[cell]
				if arr.is_empty():
					continue
				var xforms = arr[0]
				instances[mesh][cell][0] = xforms.filter(func(xform: Transform3D):
					#if not generated.has(region.location) or not generated[region.location].has(mesh):
						#return true
					return not generated[region.location][mesh].has(xform)
				)
				if instances[mesh][cell][0].is_empty():
					instances[mesh].erase(cell)

	generated = {}
	terrain.instancer.update_mmis(true)

func save():
	terrain.data.save_directory(terrain.data_directory)

func _validate_property(property: Dictionary):
	if property.name in ["generated"]:
		property.usage = PROPERTY_USAGE_NO_EDITOR
