
@tool
class_name Foliage3DGraph extends Resource

@export var nodes: Array[Dictionary]
@export var connections: Array[Dictionary]

#
#class Saver extends ResourceFormatSaver:
	#func _get_recognized_extensions(resource: Resource) -> PackedStringArray:
		#return PackedStringArray(["fol"])
#
	#func _recognize(resource: Resource) -> bool:
		#return resource is FoliageGraph
#
	#func _save(resource: Resource, path: String, flags: int):
		#if not resource:
			#return ERR_INVALID_PARAMETER
#
		#var file = FileAccess.open(path, FileAccess.WRITE)
		#if not file:
			#var err = FileAccess.get_open_error()
			#if err != OK:
				#push_error("Cannot save foliage file %s." % path)
				#return err
#
		#file.store_var(resource.nodes, true)
		#file.store_var(resource.connections, true)
#
		#if (file.get_error() != OK and file.get_error() != ERR_FILE_EOF):
			#return ERR_CANT_CREATE
#
		#return OK
#
#
#class Loader extends ResourceFormatLoader:
	#func _handles_type(type: StringName) -> bool:
		#return ClassDB.is_parent_class(type, "Resource")
		##return type == "Resource"
#
	#func _get_recognized_extensions() -> PackedStringArray:
		#return PackedStringArray(["fol"])
#
	#func _get_resource_type(path: String) -> String:
		#if ["fol"].has(path.get_extension().to_lower()):
			#return "FoliageGraph"
		#return ""
#
	#func _get_resource_script_class(path: String) -> String:
		#if ["fol"].has(path.get_extension().to_lower()):
			#return "FoliageGraph"
		#return ""
#
	##func _recognize_path(path: String, type: StringName) -> bool:
		##return false
#
	#func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
		#var file = FileAccess.open(path, FileAccess.READ)
		#if not file:
			#var err = FileAccess.get_open_error()
			#if err != OK:
				#push_error("Cannot save foliage file %s." % path)
				#return false
#
		#var resource = FoliageGraph.new()
		#resource.nodes = file.get_var(true)
		#resource.connections = file.get_var(true)
#
		#if (file.get_error() != OK and file.get_error() != ERR_FILE_EOF):
			#push_error(file.get_error())
#
		#return resource
