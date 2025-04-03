#include "node.hpp"

#include <godot_cpp/core/class_db.hpp>

using namespace godot;


Foliage3DNode::Foliage3DNode()
{
  _terrain = memnew(Foliage3DTerrain);

  // promise<Variant> promise;
  // _promise = &promise;
  // future<Variant> future;
  // _result = &future.share();
  
  // int num_inputs;
  // for (int i = 0; i < _slots.size(); i++)
  // {
  //   Foliage3DSlot* slot = cast_to<Foliage3DSlot>(_inputs[i]);
  //   if (slot->left) {
  //     num_inputs++;
  //   }
  // }
  // _inputs.resize(num_inputs);
}

Foliage3DNode::~Foliage3DNode()
{
}

void Foliage3DNode::execute()
{
  if (_inputs.size() != get_inputs().size())
  {
    // TODO optional inputs
    ERR_PRINT("input count mismatch");
    return;
  }

	Array inputs;
	for (int i = _inputs.size() - 1; i >= 0; i--)
	{
		Foliage3DNode* node = cast_to<Foliage3DNode>(_inputs[i]);
    Variant result = node->get_result();
    if (result.get_type() != Variant::Type::ARRAY)
    {
      ERR_PRINT("bad result type");
      return;
    }
    Array arr = result;
    // TODO support multiple out ports
		inputs.append(arr[0]);
	}

  //_result = callv("_execute", inputs);
  // _promise->set_value()
  // _promise->set_value(result);
}


void Foliage3DNode::set_params(Dictionary p_dict)
{
  Array keys = p_dict.keys();
	for (int i = 0; i < keys.size(); i++) {
    String key = keys[i];
    if (key == "node")
    {
      continue;
    }
    set(keys[i], p_dict[keys[i]]);
  }
}

void Foliage3DNode::set_input(Variant p_node, int slot)
{
  // ASSERT(slot > _inputs.size(), void());
  Foliage3DNode* node = cast_to<Foliage3DNode>(p_node);

  _inputs[slot] = node;
}

// void Foliage3DNode::set_slots(TypedArray<Foliage3DSlot> p_slots)
// {
//   _slots = p_slots;
// }

// TypedArray<Foliage3DSlot> Foliage3DNode::get_slots()
// {
//   return _slots;
// }

TypedArray<int> Foliage3DNode::get_inputs()
{
  TypedArray<int> inputs;
  return inputs;
}

TypedArray<int> Foliage3DNode::get_outputs()
{
  TypedArray<int> outputs;
  return outputs;
}


void Foliage3DNode::_bind_methods()
{
  ClassDB::bind_method(D_METHOD("get_terrain"), &Foliage3DNode::get_terrain);
  ClassDB::bind_method(D_METHOD("set_terrain", "terrain"), &Foliage3DNode::set_terrain);

  // ClassDB::bind_method(D_METHOD("get_slots"), &Foliage3DNode::get_slots);
  // ClassDB::bind_method(D_METHOD("set_slots", "slots"), &Foliage3DNode::set_slots);

  // ClassDB::bind_method(D_METHOD("get_params"), &Foliage3DNode::get_params);
  ClassDB::bind_method(D_METHOD("set_params", "params"), &Foliage3DNode::set_params);

  ClassDB::bind_method(D_METHOD("set_input", "node", "slot"), &Foliage3DNode::set_input);
  ClassDB::bind_method(D_METHOD("execute"), &Foliage3DNode::execute);

  GDVIRTUAL_BIND(get_inputs);
  GDVIRTUAL_BIND(get_outputs);

  ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "terrain"), "set_terrain", "get_terrain");
  // ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "slots"), "set_slots", "get_slots");

}
