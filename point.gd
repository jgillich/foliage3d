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

func _init(p_transform: Transform3D, p_size: Vector3, p_density = 0.0):
	transform = p_transform
	extents = p_size
	density = p_density

func update_aabb():
	var scaled_size = extents * transform.basis.get_scale()
	aabb = AABB(transform.origin - scaled_size/2, scaled_size)

func intersects(point: Foliage3DPoint) -> bool:
	return aabb.intersects(point.aabb)
