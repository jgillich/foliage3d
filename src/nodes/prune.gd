@tool
class_name Foliage3DPrune extends Foliage3DNode

func get_inputs() -> Array[int]:
	return [TYPE_POINT]

func get_outputs() -> Array[int]:
	return [TYPE_POINT]

# removes all points within the extents of self
func _generate(ctx: Foliage3DExecutor.NodeContext, input: Array[Foliage3DPoint]) -> Array:
	var result = Foliage3DPoint.Grid.new(input).prune()
	return [result]
