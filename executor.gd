class_name Foliage3DExecutor

var threads: Array[Thread]

func execute(p_nodes: Dictionary[String, Foliage3DNode], p_connections: Array[Dictionary]):
	var connections := p_connections.duplicate()
	var nodes := p_nodes.duplicate()

	for connection in connections:
		var from: Foliage3DNode = nodes[connection["from_node"]]
		var to: Foliage3DNode = nodes[connection["to_node"]]
		if from == null or to == null:
			push_error("bad node connection")
			return
		to.inputs[connection["to_port"]].append([connection["from_port"], from])

	while nodes.size() > 0:
		var next: Array[Foliage3DNode]
		var erase_keys: Array[String]
		for name in nodes.keys():
			if connections.filter(func(d: Dictionary): return d["to_node"] == name).is_empty():
				next.append(nodes[name])
				erase_keys.append(name)

		for key in erase_keys:
			connections = connections.filter(func(d: Dictionary): return d["from_node"] != key)
			nodes.erase(key)

		if next.is_empty():
			push_error("failed to process graph")
			return

		while next.size() > 0:
			## TODO add max threads config
			threads.clear()
			for i in range(min(4, next.size())):
				threads.append(Thread.new())

			for i in range(min(next.size(), threads.size())):
				var node = next.pop_back()
				threads[i].start(node.generate)

			for thread in threads:
				thread.wait_to_finish()

	threads.clear()
