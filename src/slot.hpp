#pragma once

#include "port.hpp"

#include <godot_cpp/classes/object.hpp>

using namespace godot;


class Foliage3DSlot : public Object
{
	GDCLASS(Foliage3DSlot, Object);

  protected:
	  static void _bind_methods();

	public:
		Foliage3DSlot();
		~Foliage3DSlot();

		String prop;
		String name;
		Foliage3DPort *left;
		Foliage3DPort *right;

    String get_prop() const { return prop; }
    void set_prop(String p_prop) { prop = p_prop; };


		String get_name() const { return name; }
    void set_name(String p_name) { name = p_name; };

		Foliage3DPort* get_left() const { return left; }
    void set_left(Foliage3DPort *p_left) { left = p_left; };


		Foliage3DPort* get_right() const { return right; }
    void set_right(Foliage3DPort *p_right) { right = p_right; };
};
