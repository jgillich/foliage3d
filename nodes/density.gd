@tool
class_name FoliageDensity extends FoliageNode

var lower_bound: float = 0.0
var upper_bound: float = 1.0

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("", "", Type.POINT, true, true)
	create_port("lower_bound", "Lower Bound", Type.FLOAT, false, false, 0.0, 1.0)
	create_port("upper_bound", "Upper Bound", Type.FLOAT, false, false, 0.0, 1.0)
	super(props)

func gen(transforms: Array[Transform3D]) -> Array:
	return []
	# TODOOOOOO
	# use size * 2 for radius
	var total_distance = 0.0
	var min: Vector3
	var max: Vector3
	var distances: Dictionary[int, float]

	for i in range(transforms.size()):
		min = Vector3(min(min.x, transforms[i].origin.x), 0, min(min.z, transforms[i].origin.z))
		max = Vector3(max(max.x, transforms[i].origin.x), 0, max(max.z, transforms[i].origin.z))

		for j in range(transforms.size()):
			total_distance += transforms[i].origin.distance_to(transforms[j].origin)
			var distance = transforms[i].origin.distance_to(transforms[j].origin)
			distances[i] = distances.get_or_add(i, 0.0) + distance

			#distances[i] += xform1.origin.distance_to(xform2.origin)
		#min = min(min, distances[i])
		#max = max(max, distances[i])

	var bounding_box = Rect2(Vector2(min.x, min.y), Vector2(max.x - max.x, min.y - min.y))
	var area = bounding_box.size.x * bounding_box.size.y
	var average_distance = total_distance / transforms.size() ** 2
	var result: Array[Transform3D]

	for i in range(transforms.size()):
		print(distances[i], " ", area, " ", average_distance)
		#var weight = remap(distances[i], min, max, 0.0, 1.0)
		#if weight < lower_bound or weight > upper_bound:
			#continue
#
		#result.append(transforms[i])

	return [result]

static func node_name():
	return  "Density"
