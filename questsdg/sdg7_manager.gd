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

	if renewable_assets.is_empty():
		push_warning("SDG7: no renewable assets set in Inspector")
		return

	if spawn_points.is_empty():
		push_warning("SDG7: no spawn points set")
		return

	# We just use the first renewable asset (your wind_turbine.tscn)
	var scene: PackedScene = renewable_assets[0]

	for point in spawn_points:
		var instance := scene.instantiate() as Node3D
		point.add_child(instance)

		# Align the turbine with the spawn point
		instance.global_transform = point.global_transform

		spawned.append(instance)

	print("SDG7: Spawned %d wind turbines" % spawned.size())

func clear_assets() -> void:
	for node in spawned:
		if node and node.is_inside_tree():
			node.queue_free()
	spawned.clear()
