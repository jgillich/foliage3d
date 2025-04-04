@tool
class_name Foliage3DSlice extends Foliage3DNode

@export_range(0.0, 1.0) var weight: float = 0.5:
	set(value):
		weight = value
		changed.emit()

@export var randomize: bool = true:
	set(value):
		randomize = value
		changed.emit()

@export var seed: int:
	set(value):
		seed = value
		changed.emit()

func get_inputs() -> Array[int]:
	return [TYPE_POINT]

func get_outputs() -> Array[int]:
	return [TYPE_POINT, TYPE_POINT]

func _generate(input: Array[Foliage3DPoint]) -> Array:
	var result = input.duplicate()
	if randomize:
		var rng = RandomNumberGenerator.new()
		rng.seed = seed
		array_shuffle(result, rng)

	var index = roundi(remap(weight, 0.0, 1.0, 0, input.size()))
	return [result.slice(0, index), result.slice(index, result.size())]

func array_shuffle(array: Array, rng: RandomNumberGenerator) -> void:
	for i in range(array.size() - 2):
		var j := rng.randi_range(i, array.size() - 1)
		var tmp = array[i]
		array[i] = array[j]
		array[j] = tmp
