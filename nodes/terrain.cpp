#include "terrain.hpp"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

Foliage3DTerrain::Foliage3DTerrain()
{
}

Foliage3DTerrain::~Foliage3DTerrain()
{
}


double Foliage3DTerrain::get_height(Vector3 p_position)
{
	return 0.0;
}

Vector3 Foliage3DTerrain::get_normal(Vector3 p_position)
{
	return Vector3();
}

void Foliage3DTerrain::add_mesh_xforms(int id, TypedArray<Transform3D> xforms)
{
	
}


void Foliage3DTerrain::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("get_height", "position"), &Foliage3DTerrain::get_height);
	ClassDB::bind_method(D_METHOD("get_normal", "position"), &Foliage3DTerrain::get_normal);

	GDVIRTUAL_BIND(get_height, "position");
	GDVIRTUAL_BIND(get_normal, "position");
	GDVIRTUAL_BIND(add_mesh_xforms, "id", "xforms");
}

