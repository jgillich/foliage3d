@tool
class_name FoliageFilter extends FoliageNode

var expression: String = "true"

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("", "", Type.POINT, true, true)
	create_port("", "Rest", Type.POINT, false, true)
	create_port("expression", "Expression", Type.STRING, false, false)
	super(props)


func gen(input: Array[Foliage3DPoint]) -> Array:
	var exp = Expression.new()
	exp.parse(expression, ["p"])
	var out: Array[Foliage3DPoint]
	var rest: Array[Foliage3DPoint]
	for point in input:
		var res = exp.execute([point])
		if res is bool:
			if res:
				out.append(point)
			else:
				rest.append(point)
		else:
			push_warning("foliage: bad expression '%s'" % expression)

	return [out, rest]

static func node_name():
	return  "Filter"
