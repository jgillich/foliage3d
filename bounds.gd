class_name Foliage3DBounds

var shapes: Array[CollisionShape3D]
#var exclusions: Array[CollisionShape3D]

var aabb: AABB

func set_shapes(p_shapes: Array[CollisionShape3D]):
	aabb = AABB()
	shapes = p_shapes
	for shape in p_shapes:
		if shape.shape == null:
			continue
		var shape_aabb = get_aabb(shape.global_position, shape.shape)
		DebugDraw3D.draw_box(shape_aabb.position, Quaternion(), shape_aabb.size, Color.BLUE, false, 10.0)
		if aabb.position == Vector3.ZERO:
			aabb = shape_aabb
		else:
			aabb = aabb.merge(shape_aabb)
	DebugDraw3D.draw_box(aabb.position, Quaternion(), aabb.size, Color.RED, false, 10.0)

func contains(position: Vector3) -> bool:
	#return true
	for shape in shapes:
		if shape_contains(position, shape):
			return true
	return false

func shape_contains(position: Vector3, shape: CollisionShape3D) -> bool:
	if shape.shape is BoxShape3D:
		var min_corner = shape.global_position - shape.shape.extents
		var max_corner = shape.global_position + shape.shape.extents
		return position.x >= min_corner.x and position.x <= max_corner.x and \
			position.y >= min_corner.y and position.y <= max_corner.y and \
			position.z >= min_corner.z and position.z <= max_corner.z
	elif shape.shape is SphereShape3D:
		return position.distance_to(shape.global_position) <= shape.shape.radius

	return false

func get_aabb(position: Vector3, shape: Shape3D) -> AABB:
	if shape is BoxShape3D:
		return AABB(position, shape.extents * 2)
	elif shape is SphereShape3D:
		var radius = Vector3(shape.radius, shape.radius, shape.radius)
		return AABB(position - radius, radius * 2)
	#elif shape is CapsuleShape3D:
		#return AABB(position, Vector3(shape.radius * 2, shape.height + shape.radius * 2, shape.radius * 2))

	return AABB(position, Vector3.ZERO)
