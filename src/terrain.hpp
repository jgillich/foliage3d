#pragma once

#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/core/gdvirtual.gen.inc>
#include <godot_cpp/core/binder_common.hpp>

using namespace godot;

class Foliage3DTerrain : public Object
{
	GDCLASS(Foliage3DTerrain, Object);

protected:
	static void _bind_methods();

public:
	Foliage3DTerrain();
	~Foliage3DTerrain();

	double get_height(Vector3 p_position);
	GDVIRTUAL1R(double, get_height, Vector3);

	Vector3 get_normal(Vector3 p_position);
	GDVIRTUAL1R(Vector3, get_normal, Vector3);

	void add_mesh_xforms(int id, TypedArray<Transform3D> xforms);
	GDVIRTUAL2(add_mesh_xforms, int, TypedArray<Transform3D>);
};
