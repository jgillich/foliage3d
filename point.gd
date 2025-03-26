class_name Foliage3DPoint

var transform: Transform3D
var size: Vector3
var density: float

func _init(p_transform: Transform3D, p_size: Vector3 = Vector3(1, 1, 1), p_density = 0.0):
	transform = p_transform
	size = p_size
	density = p_density

func aabb() -> AABB:
	var scaled_size = size * transform.basis.get_scale()
	return AABB(transform.origin - (scaled_size/2), scaled_size)

func intersects(point: Foliage3DPoint) -> bool:
	return aabb().intersects(point.aabb())
