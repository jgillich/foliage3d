#include "point.hpp"

#include <godot_cpp/core/class_db.hpp>

using namespace godot;


Foliage3DPoint::Foliage3DPoint()
{
}

// Foliage3DPoint::Foliage3DPoint(Transform3D p_transform, Vector3 p_size)
// {
// 	_transform = p_transform;
// 	_size = p_size;
// 	_update_aabb();
// }

Foliage3DPoint::~Foliage3DPoint()
{
}

void Foliage3DPoint::set_transform(Transform3D p_transform)
{
	 _transform = p_transform; 
	 _update_aabb();
}

void Foliage3DPoint::set_size(Vector3 p_size)
{
	_size = p_size;
	_update_aabb();
}

bool Foliage3DPoint::intersects(Foliage3DPoint* p_point)
{ 
	return _aabb.intersects(p_point->_aabb);
}

void Foliage3DPoint::_update_aabb()
{
	Vector3 scaled_size = _size.operator*(_transform.basis.get_scale());
	_aabb = AABB(_transform.origin.operator-(scaled_size.operator/(2)), scaled_size);
}

void Foliage3DPoint::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("get_transform"), &Foliage3DPoint::get_transform);
	ClassDB::bind_method(D_METHOD("set_transform", "transform"), &Foliage3DPoint::set_transform);
	ClassDB::bind_method(D_METHOD("get_size"), &Foliage3DPoint::get_size);
	ClassDB::bind_method(D_METHOD("set_size", "size"), &Foliage3DPoint::set_size);
	ClassDB::bind_method(D_METHOD("get_aabb"), &Foliage3DPoint::get_aabb);
	ClassDB::bind_method(D_METHOD("intersects", "point"), &Foliage3DPoint::intersects);
		
	ADD_PROPERTY(PropertyInfo(Variant::TRANSFORM3D, "transform"), "set_transform", "get_transform");
	ADD_PROPERTY(PropertyInfo(Variant::VECTOR3, "size"), "set_size", "get_size");
}
