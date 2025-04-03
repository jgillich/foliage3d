#pragma once

#include "point.hpp"
#include "node.hpp"

using namespace godot;

class Foliage3DPrune : public Foliage3DNode
{
	GDCLASS(Foliage3DPrune, Foliage3DNode);

protected:
	static void _bind_methods();

	Array _execute(TypedArray<Foliage3DPoint> p_input);

public:
	Foliage3DPrune();
	~Foliage3DPrune();

	TypedArray<int> get_inputs();
	TypedArray<int> get_outputs();
};
