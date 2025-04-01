#include "register_types.h"

#include <gdextension_interface.h>
#include <godot_cpp/classes/engine.hpp>

#include "point.hpp"
#include "prune.hpp"
#include "difference.hpp"
#include "terrain.hpp"


void gdextension_initialize(ModuleInitializationLevel p_level)
{
	if (p_level == MODULE_INITIALIZATION_LEVEL_SCENE)
	{
		ClassDB::register_class<Foliage3DTerrain>();
		ClassDB::register_class<Foliage3DPort>();
		ClassDB::register_class<Foliage3DSlot>();
		ClassDB::register_class<Foliage3DNode>();
		ClassDB::register_class<Foliage3DPoint>();
		ClassDB::register_class<Foliage3DPrune>();
		ClassDB::register_class<Foliage3DDifference>();
	}
}

void gdextension_terminate(ModuleInitializationLevel p_level)
{
	if (p_level == MODULE_INITIALIZATION_LEVEL_SCENE)
	{

	}
}

extern "C"
{
	GDExtensionBool GDE_EXPORT gdextension_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization)
	{
		godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

		init_obj.register_initializer(gdextension_initialize);
		init_obj.register_terminator(gdextension_terminate);
		init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

		return init_obj.init();
	}
}
