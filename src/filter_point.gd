@tool
class_name Foliage3DFilterPoint extends Foliage3DNode

#@export var position_min: Vector3:
	#set(value):
		#position_min = value
		#changed.emit()
#
#@export var position_max: Vector3:
	#set(value):
		#position_max = value
		#changed.emit()

@export var rotation_min: Vector3:
	set(value):
		rotation_min = value
		changed.emit()

@export var rotation_max: Vector3:
	set(value):
		rotation_max = value
		changed.emit()

func get_inputs() -> Array[int]:
	return [TYPE_POINT]

func get_outputs() -> Array[int]:
	return [TYPE_POINT, TYPE_POINT]

func _generate(input: Array[Foliage3DPoint]) -> Array:
	var result: Array[Foliage3DPoint]
	var rest: Array[Foliage3DPoint]

	for point in input:
		#if point.transform.origin.clamp(position_min, position_max) != point.transform.origin:
			#rest.append(point)
			#continue
		if rotation_min != Vector3.ZERO or rotation_max != Vector3.ZERO:
			var euler = point.transform.basis.get_euler()
			euler *= rad_to_deg(1)
			if euler.clamp(rotation_min, rotation_max) != euler:
				rest.append(point)
				continue
			result.append(point)

	return [result, rest]
