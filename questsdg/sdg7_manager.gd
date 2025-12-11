extends Node3D

@export var wind_turbine_scene: PackedScene
@export var geothermal_scene: PackedScene
@export var hydro_dam_scene: PackedScene

@export var wind_spawn_points: Array[Node3D]
@export var geothermal_spawn_point: Node3D
@export var hydro_spawn_point: Node3D

var spawned: Array[Node3D] = []

func _ready() -> void:
	clear_assets()

func _on_goal_box_animated_7_bounce() -> void:
	print("SDG 7 bounce received")
	spawn_assets()

func spawn_assets() -> void:
	clear_assets()

	# --- Spawn Wind Turbines ---
	if wind_turbine_scene == null:
		push_warning("SDG7: Wind turbine scene not set")
	else:
		for point in wind_spawn_points:
			if point == null:
				continue

			var turbine := wind_turbine_scene.instantiate() as Node3D
			point.add_child(turbine)
			turbine.global_transform = point.global_transform
			spawned.append(turbine)

	# --- Spawn Geothermal Plant ---
	if geothermal_scene == null:
		push_warning("SDG7: Geothermal scene not set")
	elif geothermal_spawn_point == null:
		push_warning("SDG7: Geothermal spawn point not set")
	else:
		var geo := geothermal_scene.instantiate() as Node3D
		geothermal_spawn_point.add_child(geo)
		geo.global_transform = geothermal_spawn_point.global_transform
		spawned.append(geo)
		
	# --- Spawn Hydroelectric Dam --- 	
	if hydro_dam_scene == null:
		push_warning("SDG7: Hydroelectric dam scene not set")
	elif hydro_spawn_point == null:
		push_warning("SDG7: Hydroelectric spawn point not set")
	else:
		var dam := hydro_dam_scene.instantiate() as Node3D
		hydro_spawn_point.add_child(dam)
		dam.global_transform = hydro_spawn_point.global_transform
		spawned.append(dam)

	print("SDG7: Spawned %d total renewable assets" % spawned.size())

func clear_assets() -> void:
	for node in spawned:
		if node and node.is_inside_tree():
			node.queue_free()
	spawned.clear()
