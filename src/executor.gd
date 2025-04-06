class_name Foliage3DExecutor

class Context:
	var bounds: Foliage3DBounds

	var _data: Dictionary[String, Dictionary]
	var _data_mut: Mutex = Mutex.new()

	var _terrain: Terrain3D
	var _terrain_mut: Mutex = Mutex.new()

	var _finalized: Array[String]
	var _finalized_mut: Mutex = Mutex.new()

	var _main: Array[Callable]
	var _main_mut: Mutex = Mutex.new()

	func _init(terrain: Terrain3D, bounds: Foliage3DBounds):
		_terrain = terrain
		self.bounds = bounds

	func for_node(key: String) -> NodeContext:
		return NodeContext.new(self, key)

	func duplicate(key: String) -> Dictionary:
		_data_mut.lock()
		var data = _data.get(key, {}).duplicate(true)
		_data_mut.unlock()
		return data

	func mutate(key: String, fn: Callable) :
		_data_mut.lock()
		fn.call(_data.get_or_add(key, {}))
		_data_mut.unlock()

	func with_terrain(fn: Callable) -> Variant:
		_terrain_mut.lock()
		var res = fn.call(_terrain)
		_terrain_mut.unlock()
		return res

	func with_terrain_main(fn: Callable) -> void:
		push_main(with_terrain.bind(fn))

	func finalize(key: String) -> Variant:
		_finalized_mut.lock()
		if _finalized.has(key):
			_finalized_mut.unlock()
			return false
		_finalized.append(key)
		_finalized_mut.unlock()
		_data_mut.lock()
		var data = _data.get(key, {})
		_data_mut.unlock()
		return data

	func push_main(fn: Callable) -> void:
		_main.append(fn)

	func pop_main() -> Variant:
		return _main.pop_back()

class NodeContext:
	var _root: Context
	var _key: String

	var bounds: Foliage3DBounds:
		get:
			return _root.bounds

	func _init(context: Context, key: String):
		_root = context
		_key = key

	func duplicate() -> Dictionary:
		return _root.duplicate(_key)

	func mutate(fn: Callable) -> void:
		_root.mutate(_key, fn)

	func with_terrain(fn: Callable) -> Variant:
		return _root.with_terrain(fn)

	func with_terrain_main(fn: Callable) -> void:
		return _root.with_terrain_main(fn)

	func finalize() -> Variant:
		return _root.finalize(_key)

	func push_main(fn: Callable) -> void:
		_root.push_main(fn)

var ctx: Context
var all_nodes: Dictionary[String, Foliage3DNode]
var remaining_nodes: Dictionary[String, Foliage3DNode]
var connections: Array[Dictionary]
var threads: Dictionary[String, Thread]

func _init(p_ctx: Context, p_nodes: Dictionary[String, Foliage3DNode], p_connections: Array[Dictionary]):
	ctx = p_ctx
	connections = p_connections.duplicate()
	all_nodes = p_nodes

func execute():
	var total = Time.get_ticks_msec()
	var durations: Dictionary[String, int]

	for connection in connections:
		var from: Foliage3DNode = all_nodes[connection["from_node"]]
		var to: Foliage3DNode = all_nodes[connection["to_node"]]
		if from == null or to == null:
			push_error("bad node connection")
			return
		to.inputs[connection["to_port"]].append([connection["from_port"], from])

	for fname in ["generate", "post_generate"]:
		remaining_nodes = all_nodes.duplicate()
		while remaining_nodes.size() > 0:
			for name in threads.keys():
				var thread = threads[name]
				if not thread.is_alive():
					connections = connections.filter(func(d: Dictionary): return d["from_node"] != name)
					remaining_nodes.erase(name)
					thread.wait_to_finish()
					threads.erase(name)
					durations[name] = Time.get_ticks_msec() - durations[name]

			# TODO max threads config
			for i in range(4 - threads.size()):
				var name := get_next()
				if name.is_empty():
					break
				var thread = Thread.new()
				var node = remaining_nodes[name]
				var fn = node[fname].bind(ctx.for_node(node.type()))
				thread.start(fn)
				threads[name] = thread
				durations[name] = Time.get_ticks_msec()

			var fn = ctx.pop_main()
			while fn != null:
				fn.call()
				fn = ctx.pop_main()

			OS.delay_msec(10)

	threads.clear()
	print_stats(Time.get_ticks_msec() - total, durations)

func print_stats(total: int, durations: Dictionary[String, int]):
	var by_node: Dictionary[String, int]
	for name in durations.keys():
		var type = all_nodes[name].type()
		by_node[type] = by_node.get(type, 0) + durations[name]

	var keys = by_node.keys()
	keys.sort_custom(func(a, b): return by_node[a] > by_node[b])
	var bottom3 = keys.slice(0, 3).map(func(k): return "%s in %dms" % [k, by_node[k]])
	var text = "Foliage3D generation completed in %dms (bottom 3: %s, %s, %s)" % ([total] + bottom3)
	print_debug(text)

func get_next() -> String:
	for name in remaining_nodes.keys():
		if threads.keys().has(name):
			continue
		if connections.filter(func(d: Dictionary): return d["to_node"] == name).is_empty():
			return name

	return ""
