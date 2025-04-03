class_name Foliage3DEditorInspectorPlugin extends EditorInspectorPlugin

func _can_handle(object):
	return true

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
		return false
