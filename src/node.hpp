#pragma once

#include "slot.hpp"
#include "terrain_3d.h"

#include <future>
#include <godot_cpp/classes/object.hpp>

using namespace std;
using namespace godot;

class Foliage3DNode : public Object
{
	GDCLASS(Foliage3DNode, Object);

protected:
	static void _bind_methods();

	TypedArray<Foliage3DSlot> _slots;
	TypedArray<Foliage3DNode> _inputs;
	Terrain3D* _terrain;
	
	promise<Variant>* _promise;
	future<Variant>* _result;

public:
	Foliage3DNode();
	~Foliage3DNode();

	void execute();

	static TypedArray<Foliage3DSlot> get_slots();

	void set_params(Dictionary p_dict);
	// Dictionary get_params();

	void set_input(Foliage3DNode* node, int slot);

	Terrain3D* get_terrain() { return _terrain; };
	void set_terrain(Terrain3D* p_terrain) { _terrain = p_terrain; };

	future<Variant>* get_result() { return _result; };
};


