extends Node3D

signal wind_all_activated

@export var wind_turbine_scene: PackedScene
@export var geothermal_scene: PackedScene
@export var hydro_dam_scene: PackedScene
@export var sun_rig_scene: PackedScene
@export var solar_panel_scene: PackedScene   

@export var wind_spawn_points: Array[Node3D]
@export var geothermal_spawn_point: Node3D
@export var hydro_spawn_point: Node3D
@export var sun_rig_spawn_point: Node3D
@export var solar_spawn_points: Array[Node3D] = []   

@export var billboard_spawn_points: Array[Node3D]
@export var billboard_scenes: Array[PackedScene]

var spawned: Array[Node3D] = []
var _billboards: Array[Node3D] = []

# Billboard buckets
var _wind_billboards: Array[Node3D] = []
var _geo_billboards: Array[Node3D] = []
var _hydro_billboards: Array[Node3D] = []
var _solar_billboards: Array[Node3D] = []   

var _wind_target: int = 0
var _wind_activated: int = 0
var _wind_completed: bool = false

# Geothermal progress: 2 steps (pipe connected, then button activated)
var _geo_step: int = 0
const GEO_TOTAL: int = 2
var _geo_completed: bool = false

# Hydro progress: 3 steps (lever + 2 debris)
var _hydro_step: int = 0
const HYDRO_TOTAL: int = 3
var _hydro_completed: bool = false

# Solar progress: clean N panels
var _solar_target: int = 0               
var _solar_cleaned: int = 0              
var _solar_completed: bool = false       


func _ready() -> void:
	clear_assets()


func _on_goal_box_animated_7_bounce() -> void:
	print("SDG 7 bounce received")
	spawn_assets()


func spawn_assets() -> void:
	clear_assets()

	# Reset wind progress each time we spawn
	_wind_target = wind_spawn_points.size()
	_wind_activated = 0
	_wind_completed = false

	# Reset geothermal progress
	_geo_step = 0
	_geo_completed = false

	# Reset hydro progress
	_hydro_step = 0
	_hydro_completed = false

	# Reset solar progress
	_solar_target = solar_spawn_points.size()   
	_solar_cleaned = 0                          
	_solar_completed = false                    

	_billboards.clear()
	_wind_billboards.clear()
	_geo_billboards.clear()
	_hydro_billboards.clear()
	_solar_billboards.clear()                   

	_spawn_billboards()
	_update_wind_billboards_progress()
	_update_geo_billboards_progress()
	_update_hydro_billboards_progress()
	_update_solar_billboards_progress()         

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

			# Listen for first time activation from each turbine
			if turbine.has_signal("activated"):
				turbine.activated.connect(_on_wind_turbine_activated)
			else:
				push_warning("SDG7: Spawned turbine has no 'activated' signal")

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

		# Hook geothermal milestones
		if geo.has_signal("pipe_connected"):
			geo.pipe_connected.connect(_on_geo_pipe_connected)
		else:
			push_warning("SDG7: Geothermal scene missing 'pipe_connected' signal")

		if geo.has_signal("geothermal_activated"):
			geo.geothermal_activated.connect(_on_geo_activated)
		else:
			push_warning("SDG7: Geothermal scene missing 'geothermal_activated' signal")

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

		# Hook hydro progress -> billboards
		if dam.has_signal("hydro_progress"):
			dam.hydro_progress.connect(_on_hydro_progress)
		else:
			push_warning("SDG7: Hydroelectric dam scene missing 'hydro_progress' signal")

		if dam.has_signal("hydro_completed"):
			dam.hydro_completed.connect(_on_hydro_completed)
		else:
			push_warning("SDG7: Hydroelectric dam scene missing 'hydro_completed' signal")

	# --- Spawn Sun Rig (Solar) ---
	if sun_rig_scene == null:
		push_warning("SDG7: Sun rig scene not set")
	elif sun_rig_spawn_point == null:
		push_warning("SDG7: Sun rig spawn point not set")
	else:
		var rig := sun_rig_scene.instantiate() as Node3D
		sun_rig_spawn_point.add_child(rig)
		rig.global_transform = sun_rig_spawn_point.global_transform
		spawned.append(rig)

	# --- Spawn Solar Panels ---
	if solar_panel_scene == null:
		push_warning("SDG7: Solar panel scene not set")
	else:
		for point in solar_spawn_points:
			if point == null:
				continue

			var panel := solar_panel_scene.instantiate() as Node3D
			point.add_child(panel)
			panel.global_transform = point.global_transform
			spawned.append(panel)

			# Hook cleaning completion
			if panel.has_signal("cleaned"):
				panel.cleaned.connect(_on_solar_panel_cleaned)
			else:
				push_warning("SDG7: Solar panel scene missing 'cleaned' signal")

	print("SDG7: Spawned %d total renewable assets" % spawned.size())


func _spawn_billboards() -> void:
	_billboards.clear()
	_wind_billboards.clear()
	_geo_billboards.clear()
	_hydro_billboards.clear()
	_solar_billboards.clear()  

	if billboard_spawn_points.is_empty():
		return

	var count: int = min(billboard_spawn_points.size(), billboard_scenes.size())

	if billboard_scenes.size() != billboard_spawn_points.size():
		push_warning("SDG7: billboard_scenes and billboard_spawn_points should be the same length (using %d pairs)" % count)

	for i in range(count):
		var point := billboard_spawn_points[i]
		var scene := billboard_scenes[i]

		if point == null:
			continue
		if scene == null:
			push_warning("SDG7: Billboard scene missing for index %d" % i)
			continue

		var board := scene.instantiate() as Node3D
		point.add_child(board)
		board.global_transform = point.global_transform

		spawned.append(board)
		_billboards.append(board)

		# Bucket by scene resource path
		var path := String(scene.resource_path).to_lower()
		if path.contains("grange_info_billboard"):
			_geo_billboards.append(board)
		elif path.contains("tallaght_info_billboard"):
			_hydro_billboards.append(board)
		elif path.contains("aungier_info_billboard"):     
			_solar_billboards.append(board)              
		else:
			_wind_billboards.append(board)


func _update_wind_billboards_progress() -> void:
	if _wind_billboards.is_empty():
		return

	for board in _wind_billboards:
		if board and board.has_method("set_progress"):
			board.call("set_progress", _wind_activated, _wind_target)


func _update_geo_billboards_progress() -> void:
	if _geo_billboards.is_empty():
		return

	for board in _geo_billboards:
		if board and board.has_method("set_progress"):
			board.call("set_progress", _geo_step, GEO_TOTAL)


func _update_hydro_billboards_progress() -> void:
	if _hydro_billboards.is_empty():
		return

	for board in _hydro_billboards:
		if board and board.has_method("set_progress"):
			board.call("set_progress", _hydro_step, HYDRO_TOTAL)


func _update_solar_billboards_progress() -> void:   
	if _solar_billboards.is_empty():
		return

	for board in _solar_billboards:
		if board and board.has_method("set_progress"):
			board.call("set_progress", _solar_cleaned, _solar_target)


func _on_wind_turbine_activated(_turbine: Node3D) -> void:
	if _wind_completed:
		return

	_wind_activated += 1
	_update_wind_billboards_progress()
	print("SDG7: Wind turbines activated %d/%d" % [_wind_activated, _wind_target])

	if _wind_activated >= _wind_target:
		_wind_completed = true
		print("SDG7: All wind turbines activated!")

		var chime := $"../../../maps/Blanchardstown/sdg_spawn_points/sdg7/CompletionSound"
		if chime:
			chime.play()

		emit_signal("wind_all_activated")


func _on_geo_pipe_connected() -> void:
	if _geo_completed:
		return

	_geo_step = max(_geo_step, 1)
	_update_geo_billboards_progress()
	print("SDG7: Geothermal pipe connected (%d/%d)" % [_geo_step, GEO_TOTAL])


func _on_geo_activated() -> void:
	if _geo_completed:
		return

	_geo_step = max(_geo_step, 2)
	_update_geo_billboards_progress()
	print("SDG7: Geothermal activated (%d/%d)" % [_geo_step, GEO_TOTAL])

	if _geo_step >= GEO_TOTAL:
		_geo_completed = true
		print("SDG7: Geothermal completed!")

		var chime := $"../../../maps/Grangegorman/sdg_spawn_points/sdg7/CompletionSound"
		if chime:
			chime.play()


func _on_hydro_progress(step: int, _total: int) -> void:
	if _hydro_completed:
		return

	_hydro_step = clamp(step, 0, HYDRO_TOTAL)
	_update_hydro_billboards_progress()
	print("SDG7: Hydro progress %d/%d" % [_hydro_step, HYDRO_TOTAL])


func _on_hydro_completed() -> void:
	if _hydro_completed:
		return

	_hydro_completed = true
	_hydro_step = HYDRO_TOTAL
	_update_hydro_billboards_progress()
	print("SDG7: Hydro completed!")

	var chime := $"../../../maps/Tallaght/sdg_spawn_points/sdg7/CompletionSound"
	if chime:
		chime.play()


func _on_solar_panel_cleaned(_panel: Node3D) -> void:   
	if _solar_completed:
		return

	_solar_cleaned += 1
	_update_solar_billboards_progress()
	print("SDG7: Solar panels cleaned %d/%d" % [_solar_cleaned, _solar_target])

	if _solar_cleaned >= _solar_target:
		_solar_completed = true
		print("SDG7: Solar completed!")

		var chime := $"../../../maps/aungier/sdg_spawn_points/sdg7/CompletionSound"
		if chime:
			chime.play()


func clear_assets() -> void:
	for node in spawned:
		if node and node.is_inside_tree():
			node.queue_free()

	spawned.clear()
	_billboards.clear()
	_wind_billboards.clear()
	_geo_billboards.clear()
	_hydro_billboards.clear()
	_solar_billboards.clear()  
