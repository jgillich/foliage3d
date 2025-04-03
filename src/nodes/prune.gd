@tool
class_name Foliage3DPrune extends Foliage3DNode

func get_inputs() -> Array[int]:
	return [TYPE_POINT]

func get_outputs() -> Array[int]:
	return [TYPE_POINT]

# removes all points within the extents of self
func _generate(input: Array[Foliage3DPoint]) -> Array:
	var points: Array[Foliage3DPoint] = input.duplicate()
	for i in range(input.size()-1, 0, -1):
		for j in range(i-1, -1, -1):
			if input[i].intersects(input[j]):
				points.remove_at(i)
				break
	return [points]
