#include "difference.hpp"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

Foliage3DDifference::Foliage3DDifference()
{
	Foliage3DSlot* inout = memnew(Foliage3DSlot);
	inout->left->type = Foliage3DPort::Type::POINT;
	inout->right->type = Foliage3DPort::Type::POINT;

	_slots.append(inout);
}

Foliage3DDifference::~Foliage3DDifference()
{
}

void Foliage3DDifference::_execute(TypedArray<Foliage3DPoint> p_input, TypedArray<Foliage3DPoint> p_diff)
{
	TypedArray<Foliage3DPoint> points = p_input.duplicate();
	for (int i = p_input.size() - 1; i >= 0; i--) {
		Foliage3DPoint* p1 = cast_to<Foliage3DPoint>(p_input[i]);
		for (int j = 0; j < p_diff.size(); j++) {
			Foliage3DPoint* p2 = cast_to<Foliage3DPoint>(p_diff[j]);
			if (p1->intersects(p2))
			{
				points.remove_at(i); 
				break;
			}
		}
	}

	Array result;
	result.append(points);
	_promise->set_value(result);
}


void Foliage3DDifference::_bind_methods()
{
}

