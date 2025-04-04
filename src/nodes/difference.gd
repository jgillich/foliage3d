@tool
class_name Foliage3DDifference extends Foliage3DNode

func get_inputs() -> Array[int]:
	return [TYPE_POINT, TYPE_POINT]

func get_outputs() -> Array[int]:
	return [TYPE_POINT]

# removes all points within the extents of diff
func _generate(input: Array[Foliage3DPoint] = [], diff: Array[Foliage3DPoint] = []) -> Array:
	var result = Foliage3DPoint.Grid.new(diff).difference(input)
	return [result]

func get_grid_keys(box: AABB, cell_size: float) -> Array:
	var min_cell := Vector3i(box.position / cell_size)
	var max_cell := Vector3i((box.position + box.size) / cell_size)
	var keys = []
	for x in range(min_cell.x, max_cell.x + 1):
		for y in range(min_cell.y, max_cell.y + 1):
			for z in range(min_cell.z, max_cell.z + 1):
				keys.append(Vector3i(x, y, z))
	return keys
