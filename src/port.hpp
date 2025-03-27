#pragma once

#include <godot_cpp/classes/object.hpp>


#include <godot_cpp/classes/global_constants.hpp>
#include <godot_cpp/core/binder_common.hpp>

using namespace godot;

class Foliage3DPort : public Object
{
	GDCLASS(Foliage3DPort, Object);

  public:
    enum Type {
      POINT,
      VECTOR3,
      FLOAT,
      INT,
      BOOL,
      STRING,
    };
    
    enum TypeHint {
      NONE,
      POSITION,
      ROTATION
    };
    
  protected:
	  static void _bind_methods();

	public:
    Foliage3DPort();
    ~Foliage3DPort();

		Type type;
		String name;
		TypeHint hint;

    Type get_type() const { return type; }
    void set_type(Type p_type)  { type = p_type; };

    String get_name() const { return name; }
    void set_name(String p_name)  { name = p_name; };

    TypeHint get_hint() const { return hint; }
    void set_hint(TypeHint p_hint) { hint = p_hint; };
};

VARIANT_ENUM_CAST(Foliage3DPort::Type);
VARIANT_ENUM_CAST(Foliage3DPort::TypeHint);
