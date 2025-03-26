class_name Foliage3DPoint

var transform: Transform3D
var size: Vector3

func _init(p_transform: Transform3D, p_size: Vector3 = Vector3(1, 1, 1)):
	transform = p_transform
	size = p_size

func aabb() -> AABB:
	return AABB(transform.origin - (size/2), size)

func intersects(point: Foliage3DPoint) -> bool:
	return aabb().intersects(point.aabb())
