#pragma once

#include <godot_cpp/classes/object.hpp>

using namespace godot;

class Foliage3DPoint : public Object
{
	GDCLASS(Foliage3DPoint, Object);

protected:
	static void _bind_methods();
	Transform3D _transform;
	Vector3 _size;
	AABB _aabb;
	void _update_aabb();
	
public:
	Foliage3DPoint();
	// Foliage3DPoint(Transform3D p_transform, Vector3 p_size);
	~Foliage3DPoint();

	Transform3D get_transform() const { return _transform; }
	void set_transform(Transform3D p_transform);
	Vector3 get_size() const { return _size; }
	void set_size(Vector3 p_size);
	AABB get_aabb() const { return _aabb; }
	bool intersects(Foliage3DPoint* p_input);
};
