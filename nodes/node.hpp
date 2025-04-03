#pragma once

#include "slot.hpp"
#include "terrain.hpp"

// #include <future>
#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/variant/builtin_types.hpp>
#include <godot_cpp/core/gdvirtual.gen.inc>

using namespace std;
using namespace godot;

class Foliage3DNode : public Object
{
	GDCLASS(Foliage3DNode, Object);

protected:
	static void _bind_methods();

	// TypedArray<Foliage3DSlot> _slots;
	TypedArray<Foliage3DNode> _inputs;
	Foliage3DTerrain* _terrain;
	
	// promise<Variant>* _promise;
	// shared_future<Variant>* _result;
	Variant _result;

public:
	Foliage3DNode();
	~Foliage3DNode();

	void execute();

	virtual TypedArray<int> get_inputs();
	GDVIRTUAL0R(TypedArray<int>, get_inputs);

	virtual TypedArray<int> get_outputs();
	GDVIRTUAL0R(TypedArray<int>, get_outputs);


	void set_params(Dictionary p_dict);
	// Dictionary get_params();

	void set_input(Variant node, int slot);

	Foliage3DTerrain* get_terrain() { return _terrain; };
	void set_terrain(Foliage3DTerrain* p_terrain) { _terrain = p_terrain; };

	Variant get_result() { return _result; };
};
