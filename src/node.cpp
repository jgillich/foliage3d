#include "node.hpp"

#include <godot_cpp/core/class_db.hpp>

using namespace godot;


Foliage3DNode::Foliage3DNode()
{

  promise<Variant> promise;
  _promise = &promise;
  future<godot::Variant> future;
  _result = &future;
  
  int num_inputs;
  for (int i = 0; i < _slots.size(); i++)
  {
    Foliage3DSlot* slot = cast_to<Foliage3DSlot>(_inputs[i]);
    if (slot->left) {
      num_inputs++;
    }
  }
  _inputs.resize(num_inputs);
}


Foliage3DNode::~Foliage3DNode()
{
}

void Foliage3DNode::execute()
{
	Array inputs;
	for (int i = _inputs.size() - 1; i >= 0; i--)
	{
		Foliage3DNode* node = cast_to<Foliage3DNode>(_inputs[i]);
    node->get_result()->wait();
    Array result = node->get_result()->get();
    // TODO support multiple out ports
		inputs.append(result[0]);
	}

  callv("_execute", inputs);
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

void Foliage3DNode::set_input(Foliage3DNode* node, int slot)
{
  ASSERT(slot > _inputs.size(), void());
  _inputs[slot] = node;
}

void Foliage3DNode::_bind_methods()
{
  // ClassDB::bind_method(D_METHOD("get_params"), &Foliage3DNode::get_params);
  ClassDB::bind_method(D_METHOD("set_params", "params"), &Foliage3DNode::set_params);

  ClassDB::bind_method(D_METHOD("set_input", "node", "slot"), &Foliage3DNode::set_input);
  ClassDB::bind_method(D_METHOD("execute"), &Foliage3DNode::execute);
}
