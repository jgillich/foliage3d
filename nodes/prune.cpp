#include "prune.hpp"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

Foliage3DPrune::Foliage3DPrune()
{
	// Foliage3DSlot* inout = memnew(Foliage3DSlot);
	// inout->left->type = Foliage3DPort::Type::POINT;
	// inout->right->type = Foliage3DPort::Type::POINT;

	// _slots.append(inout);
}

Foliage3DPrune::~Foliage3DPrune()
{
}

TypedArray<int> Foliage3DPrune::get_inputs()
{
  TypedArray<int> inputs;
	inputs.append(Variant::Type::TRANSFORM3D);
  return inputs;
}

TypedArray<int> Foliage3DPrune::get_outputs()
{
  TypedArray<int> outputs;
	outputs.append(Variant::Type::TRANSFORM3D);
  return outputs;
}

Array Foliage3DPrune::_execute(TypedArray<Foliage3DPoint> p_input)
{
	TypedArray<Foliage3DPoint> points = p_input.duplicate();
	for (int i = p_input.size() - 1; i >= 0; i--) {
		Foliage3DPoint* p1 = cast_to<Foliage3DPoint>(p_input[i]);
		for (int j = i - 1; j >= 0; j--) {
			Foliage3DPoint* p2 = cast_to<Foliage3DPoint>(p_input[j]);
			if (p1->intersects(p2))
			{
				points.remove_at(i); 
				break;
			}
		}
	}

	Array result;
	result.append(points);
	return result;
}

void Foliage3DPrune::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("_execute"), &Foliage3DPrune::_execute);
	ClassDB::bind_method(D_METHOD("get_inputs"), &Foliage3DPrune::get_inputs);
	ClassDB::bind_method(D_METHOD("get_outputs"), &Foliage3DPrune::get_outputs);
}
