class_name Foliage3DTexturePainter extends Foliage3DNode

func _generate(input: Array[Foliage3DPoint]) -> Array:
	pass
	var region = terrain3d.data.get_region(Vector2i())
	var map = region.get_map(Terrain3DRegion.TYPE_COLOR)

	map.set_pixelv(Vector2i(), Color.RED)

	return []
