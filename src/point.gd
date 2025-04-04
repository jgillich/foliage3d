class_name Foliage3DPoint

var transform: Transform3D:
	set(value):
		transform = value
		update_aabb()

var extents: Vector3:
	set(value):
		extents = value
		update_aabb()

var density: float

var aabb: AABB

func _init(p_transform: Transform3D, p_extents: Vector3, p_density = 0.0):
	transform = p_transform
	extents = p_extents
	density = p_density

func update_aabb():
	var scaled_size = extents * transform.basis.get_scale()
	aabb = AABB(transform.origin - scaled_size/2, scaled_size)

func intersects(point: Foliage3DPoint) -> bool:
	return aabb.intersects(point.aabb)

func duplicate() -> Foliage3DPoint:
	return Foliage3DPoint.new(transform, extents)


class Grid:
	var points: Array[Foliage3DPoint]
	var grid: Dictionary[Vector3i, Array]
	var cell_size: float = INF

	func _init(p_points: Array[Foliage3DPoint]):
		points = p_points
		for point in points:
			cell_size = min(cell_size, min(point.aabb.size.x, point.aabb.size.y, point.aabb.size.z))
		cell_size = max(cell_size, 0.001)  # Prevent division by zero

	func get_grid_keys(point: Foliage3DPoint) -> Array:
		var min_cell := Vector3i(point.aabb.position / cell_size)
		var max_cell := Vector3i((point.aabb.position + point.aabb.size) / cell_size)
		var keys = []
		for x in range(min_cell.x, max_cell.x + 1):
			for y in range(min_cell.y, max_cell.y + 1):
				for z in range(min_cell.z, max_cell.z + 1):
					keys.append(Vector3i(x, y, z))
		return keys

	func difference(input: Array[Foliage3DPoint]) -> Array[Foliage3DPoint]:
		for point in points:
			for key in get_grid_keys(point):
				if key not in grid:
					grid[key] = []
				grid[key].append(point)

		var result: Array[Foliage3DPoint]
		for point in input:
			var overlaps := false
			for key in get_grid_keys(point):
				if key in grid:
					for diff_point in grid[key]:
						if point.intersects(diff_point):
							overlaps = true
							break
				if overlaps:
					break
			if not overlaps:
				result.append(point)
		return result

	func prune() -> Array[Foliage3DPoint]:
		var result: Array[Foliage3DPoint]
		var to_remove := {}

		for point in points:
			var keys = get_grid_keys(point)
			var overlapping = false

			# Check if the box overlaps with any existing boxes in the same grid cell
			for key in keys:
				if key in grid:
					for other in grid[key]:
						if point.intersects(other):
							overlapping = true
							to_remove[other] = true
							break
				if overlapping:
					break

			if not overlapping:
				for key in keys:
					if key not in grid:
						grid[key] = []
					grid[key].append(point)

		# Filter out overlapping boxes
		for point in points:
			if point not in to_remove:
				result.append(point)

		return result
