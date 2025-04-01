@tool
class_name Foliage3DFilter extends Foliage3DNode

var expression: String = "true":
	set(value):
		expression = value
		changed.emit()

# TODO accept any object type
func get_inputs() -> Array[int]:
	return [TYPE_POINT]

func get_outputs() -> Array[int]:
	return [TYPE_POINT, TYPE_POINT]

func gen(input: Array[Foliage3DPoint]) -> Array:
	var out: Array[Foliage3DPoint]
	var rest: Array[Foliage3DPoint]

	var exp = Expression.new()
	var err = exp.parse(expression, ["p"])
	if err != OK:
		push_warning("foliage: bad expression '%s'" % expression)
		return [out, rest]

	for point in input:
		var res = exp.execute([point])
		if res is bool:
			if res:
				out.append(point)
			else:
				rest.append(point)
		else:
			push_warning("foliage: bad expression '%s'" % expression)
			break

	return [out, rest]
