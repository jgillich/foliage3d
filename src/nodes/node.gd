@tool
class_name Foliage3DNode extends Resource

enum {
	TYPE_POINT = 100
}

signal mesh_xforms_added(region: Vector2i, mesh: int, xforms: Array[Vector3])

var inputs: Array[Array]
var result: Array

func _init():
	inputs.resize(get_inputs().size())
	resource_name = type()
	for i in range(inputs.size()):
		inputs[i] = []

func get_inputs() -> Array[int]:
	return []

func get_outputs() -> Array[int]:
	return []

func generate(ctx: Foliage3DExecutor.NodeContext):
	if OS.get_thread_caller_id() != OS.get_main_thread_id():
		Thread.set_thread_safety_checks_enabled(false)

	var args = []

	for i in range(inputs.size()):
		for j in inputs[i]:
			var port = j[0]
			var node = j[1]
			if args.size() <= i:
				args.append(node.result[port].duplicate())
			else:
				args[i].append_array(node.result[port])

	if args.size() != get_inputs().size():
		return

	args.push_front(ctx)
	result = callv("_generate", args)

	for i in range(inputs.size()):
		inputs[i] = []

func post_generate(ctx: Foliage3DExecutor.NodeContext):
	if not has_method("_post_generate"):
		return

	call("_post_generate", ctx)

func type() -> String:
	return get_script().get_global_name().trim_prefix("Foliage3D")
