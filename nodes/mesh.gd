@tool
class_name FoliageMesh extends FoliageNode

var scene: PackedScene = preload("res://Assets/PolygonNatureBiomes/PNB_Meadow_Forest/Prefabs/SM_Env_Tree_Fruit_01.prefab.scn")

func _init(props: Dictionary = {}) -> void:
	title = node_name()
	create_port("", "", Type.TRANSFORM, true, false)
	create_port("scene", "Scene", Type.SCENE, false, false)
	super(props)

func gen(transforms: Array[Transform3D]):
	print_debug("adding meshes ", transforms.size())


	var asset = Terrain3DMeshAsset.new()
	asset.scene_file = scene
	foliage.terrain.assets.set_mesh_asset(100, asset)
	foliage.terrain.instancer.add_transforms(100, transforms)

static func node_name():
	return "Mesh"
