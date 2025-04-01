@tool
class_name Foliage3DSlice extends Foliage3DNode

@export var weight: float = 0.5:
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

func _generate(input: Array[Foliage3DPoint]) -> Array:
	var result = input.duplicate()
	if randomize:
		var rng = RandomNumberGenerator.new()
		rng.seed = seed
		array_shuffle(result, rng)

	result = result.slice(0, remap(weight, 0.0, 1.0, 0, input.size()))
	return [result]

func array_shuffle(array: Array, rng: RandomNumberGenerator) -> void:
	for i in array.size() - 2:
		var j := rng.randi_range(i, array.size() - 1)
		var tmp = array[i]
		array[i] = array[j]
		array[j] = tmp
