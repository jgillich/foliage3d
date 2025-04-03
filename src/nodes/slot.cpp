#include "slot.hpp"

#include <godot_cpp/core/class_db.hpp>

using namespace godot;

Foliage3DSlot::Foliage3DSlot()
{
	left = memnew(Foliage3DPort);
	right = memnew(Foliage3DPort);
}


Foliage3DSlot::~Foliage3DSlot()
{
}


void Foliage3DSlot::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("get_prop"), &Foliage3DSlot::get_prop);
	ClassDB::bind_method(D_METHOD("set_prop", "prop"), &Foliage3DSlot::set_prop);

	ClassDB::bind_method(D_METHOD("get_name"), &Foliage3DSlot::get_name);
	ClassDB::bind_method(D_METHOD("set_name", "name"), &Foliage3DSlot::set_name);

	ClassDB::bind_method(D_METHOD("get_left"), &Foliage3DSlot::get_left);
	ClassDB::bind_method(D_METHOD("set_left", "slot"), &Foliage3DSlot::set_left);

	ClassDB::bind_method(D_METHOD("get_right"), &Foliage3DSlot::get_right);
	ClassDB::bind_method(D_METHOD("set_right", "slot"), &Foliage3DSlot::set_right);

		
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "prop"), "set_prop", "get_prop");
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "name"), "set_name", "get_name");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "left"), "set_left", "get_left");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "right"), "set_right", "get_right");
}
