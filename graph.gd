class_name Foliage3DGraph

var NODES = {
	"Difference": Foliage3DDifference,
	"Prune": Foliage3DPrune,
}

var nodes: Dictionary[String, Foliage3DNode]
var connections: Dictionary

func load(p_nodes: Array[Dictionary], p_connections: Dictionary):
	nodes = {}
	connections = connections
	for params in p_nodes:
		var cls = NODES[params["node"]]
		if cls == null:
			push_warning("unknown node %s" % params["node"])
			continue
		var node: Foliage3DNode = cls.new()
		node.set_params(params)
		nodes[params["name"]] = node

	for connection in connections:
		var to = nodes[connection["to_node"]]
		to.set_input(nodes[connection["from_node"]], connection["to_port"])

func execute():
	# this might be a little resource intensive
	# look into green threads or a fixed thread pool maybe
	var threads: Array[Thread]

	for node in nodes.values():
		var thread = Thread.new()
		thread.start(node.execute)
		threads.append(thread)

	for thread in threads:
		thread.wait_to_finish()
