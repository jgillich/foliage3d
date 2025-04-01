#include "port.hpp"

#include <godot_cpp/core/class_db.hpp>

using namespace godot;

Foliage3DPort::Foliage3DPort()
{
}


Foliage3DPort::~Foliage3DPort()
{
}

void Foliage3DPort::_bind_methods()
{
	BIND_ENUM_CONSTANT(POINT);
	BIND_ENUM_CONSTANT(VECTOR3);
	BIND_ENUM_CONSTANT(FLOAT);
	BIND_ENUM_CONSTANT(INT);
	BIND_ENUM_CONSTANT(BOOL);
	BIND_ENUM_CONSTANT(STRING);

	BIND_ENUM_CONSTANT(NONE);
	BIND_ENUM_CONSTANT(POSITION);
	BIND_ENUM_CONSTANT(ROTATION);


	ClassDB::bind_method(D_METHOD("get_type"), &Foliage3DPort::get_type);
	ClassDB::bind_method(D_METHOD("set_type", "type"), &Foliage3DPort::set_type);
	ClassDB::bind_method(D_METHOD("get_name"), &Foliage3DPort::get_name);
	ClassDB::bind_method(D_METHOD("set_name", "name"), &Foliage3DPort::set_name);
	ClassDB::bind_method(D_METHOD("get_hint"), &Foliage3DPort::get_hint);
	ClassDB::bind_method(D_METHOD("set_hint", "hint"), &Foliage3DPort::set_hint);

	ADD_PROPERTY(PropertyInfo(Variant::INT, "type"), "set_type", "get_type");
	ADD_PROPERTY(PropertyInfo(Variant::INT, "hint"), "set_hint", "get_hint");
}
