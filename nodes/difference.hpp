#pragma once

#include "point.hpp"
#include "node.hpp"

using namespace godot;

class Foliage3DDifference : public Foliage3DNode
{
	GDCLASS(Foliage3DDifference, Foliage3DNode);

protected:
	static void _bind_methods();

	Array _execute(TypedArray<Foliage3DPoint> p_input, TypedArray<Foliage3DPoint> p_diff);

public:
	Foliage3DDifference();
	~Foliage3DDifference();

	TypedArray<int> get_inputs();
	TypedArray<int> get_outputs();
};
