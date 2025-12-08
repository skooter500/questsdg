extends Node3D

@export var renewable_assets: Array[PackedScene] = []
@export var spawn_points: Array[Node3D] = []

var spawned: Array[Node3D] = []

func _ready() -> void:
	clear_assets()

func _on_goal_box_animated_7_bounce() -> void:
	print("SDG 7 bounce received")
	spawn_assets()

func spawn_assets() -> void:
	clear_assets()

	print("Spawning SDG 7 test asset")

	var cube := MeshInstance3D.new()
	cube.mesh = BoxMesh.new()
	add_child(cube)
	cube.position = Vector3(0, 1.5, -2)

	spawned.append(cube)

func clear_assets() -> void:
	for node in spawned:
		if node and node.is_inside_tree():
			node.queue_free()
	spawned.clear()
