class_name FoliagePrune extends FoliageNode

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("", "", Type.POINT, true, true)
	super(props)

# removes all points within the extents of self
func gen(input: Array[Foliage3DPoint]) -> Array:
	var prune = Foliage3DPrune.new()
	return prune.gen(input)

	#var points: Array[Foliage3DPoint] = input.duplicate()
	#for i in range(input.size()-1, 0, -1):
		#for j in range(i-1, -1, -1):
			#if input[i].intersects(input[j]):
				#points.remove_at(i)
				#break
	#return [points]

static func node_name():
	return  "Prune"
