extends MultiMeshInstance3D

@export var num_trees := 200
@export var area_size := Vector3(100, 0, 100)

func _ready():
	var mm = MultiMesh.new()
	mm.mesh = preload("res://Models/tree_default_dark.obj") # the extracted mesh resource
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = num_trees
	self.multimesh = mm
	
	for i in range(num_trees):
		var x = randf_range(-area_size.x, area_size.x)
		var z = randf_range(-area_size.z, area_size.z)
		var scale = randf_range(0.8, 1.2)
		var transform = Transform3D(
			Basis().scaled(Vector3(scale, scale, scale)),
			Vector3(x, 0, z)
		)
		mm.set_instance_transform(i, transform)
