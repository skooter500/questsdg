extends Node3D

signal wind_all_activated

@export var wind_turbine_scene: PackedScene
@export var geothermal_scene: PackedScene
@export var hydro_dam_scene: PackedScene
@export var sun_rig_scene: PackedScene
@export var solar_panel_scene: PackedScene
@export var energy_box_scene: PackedScene
@export var energy_box_spawn_point: Node3D
@export var bolton_fog_particles: GPUParticles3D
@export var fog_fade_time: float = 0.6
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
var _bolton_billboards: Array[Node3D] = []

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

#final
var _energy_box: Node3D = null

var _bolton_pressed := {
	"wind": false,
	"solar": false,
	"hydro": false,
	"geo": false,
}


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

	# Reset Bolton pressed state + fog
	_bolton_pressed["wind"] = false
	_bolton_pressed["solar"] = false
	_bolton_pressed["hydro"] = false
	_bolton_pressed["geo"] = false
	_set_bolton_fog_strength(1.0, true)

	_billboards.clear()
	_wind_billboards.clear()
	_geo_billboards.clear()
	_hydro_billboards.clear()
	_solar_billboards.clear()
	_bolton_billboards.clear()

	_spawn_billboards()
	_update_wind_billboards_progress()
	_update_geo_billboards_progress()
	_update_hydro_billboards_progress()
	_update_solar_billboards_progress()
	_update_bolton_billboards_progress()

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

			if panel.has_signal("cleaned"):
				panel.cleaned.connect(_on_solar_panel_cleaned)
			else:
				push_warning("SDG7: Solar panel scene missing 'cleaned' signal")

	# --- Spawn Bolton Energy Box ---
	_spawn_energy_box()
	_update_energy_box_unlocks()
	_connect_energy_box_switches()
	_update_bolton_fog_from_pressed()

	print("SDG7: Spawned %d total renewable assets" % spawned.size())


func _spawn_energy_box() -> void:
	_energy_box = null

	if energy_box_scene == null:
		push_warning("SDG7: Energy box scene not set")
		return
	if energy_box_spawn_point == null:
		push_warning("SDG7: Energy box spawn point not set")
		return

	var box := energy_box_scene.instantiate() as Node3D
	energy_box_spawn_point.add_child(box)
	box.global_transform = energy_box_spawn_point.global_transform

	spawned.append(box)
	_energy_box = box


func _update_energy_box_unlocks() -> void:
	if _energy_box == null or not is_instance_valid(_energy_box):
		return

	var wind_sw  := _energy_box.get_node_or_null("Interactions/Wind_Switch")
	var solar_sw := _energy_box.get_node_or_null("Interactions/Solar_Switch")
	var hydro_sw := _energy_box.get_node_or_null("Interactions/Hydro_Switch")
	var geo_sw   := _energy_box.get_node_or_null("Interactions/Geo_Switch")

	if wind_sw and wind_sw.has_method("set_unlocked"):
		wind_sw.call("set_unlocked", _wind_completed)

	if solar_sw and solar_sw.has_method("set_unlocked"):
		solar_sw.call("set_unlocked", _solar_completed)

	if hydro_sw and hydro_sw.has_method("set_unlocked"):
		hydro_sw.call("set_unlocked", _hydro_completed)

	if geo_sw and geo_sw.has_method("set_unlocked"):
		geo_sw.call("set_unlocked", _geo_completed)


func _connect_energy_box_switches() -> void:
	if _energy_box == null or not is_instance_valid(_energy_box):
		return

	_try_connect_switch("Interactions/Wind_Switch", "wind")
	_try_connect_switch("Interactions/Solar_Switch", "solar")
	_try_connect_switch("Interactions/Hydro_Switch", "hydro")
	_try_connect_switch("Interactions/Geo_Switch", "geo")


func _try_connect_switch(node_path: String, key: String) -> void:
	var sw := _energy_box.get_node_or_null(node_path)
	if sw == null:
		push_warning("SDG7: Missing switch node at %s" % node_path)
		return

	var handler := Callable(self, "_on_bolton_switch_pressed")
	if sw.has_signal("activated") and not sw.is_connected("activated", handler):
		sw.connect("activated", handler)
	else:
		push_warning("SDG7: Switch '%s' missing 'activated' signal" % key)


func _on_bolton_switch_pressed(key: String) -> void:
	print("Switch pressed:", key, "state before", _bolton_pressed) # debug
	if not _bolton_pressed.has(key):
		return
	if _bolton_pressed[key] == true:
		return

	_bolton_pressed[key] = true
	_update_bolton_billboards_progress()
	_update_bolton_fog_from_pressed()
	
	var all_pressed := true
	for k in _bolton_pressed.keys():
		if not _bolton_pressed[k]:
			all_pressed = false
			break
	if all_pressed:
		var chime := $"../../../maps/Bolton/sdg_spawn_assets/sdg7/AudioStreamPlayer3D"
		if chime:
			chime.play()


func _update_bolton_fog_from_pressed() -> void:
	# 0 pressed full fog, 4 pressed  no fog
	var count := 0
	for k in _bolton_pressed.keys():
		if _bolton_pressed[k]:
			count += 1

	var t := clampf(float(count) / 4.0, 0.0, 1.0)
	var strength := 1.0 - t
	_set_bolton_fog_strength(strength, false)


func _set_bolton_fog_strength(strength: float, immediate: bool) -> void:
	if bolton_fog_particles == null:
		return

	strength = clampf(strength, 0.0, 1.0)

	# Ensure it's on when strength > 0
	if strength > 0.001:
		if not bolton_fog_particles.emitting:
			bolton_fog_particles.emitting = true

	# Fade amount_ratio down/up
	if immediate:
		bolton_fog_particles.amount_ratio = strength
	else:
		var twn := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		twn.tween_property(bolton_fog_particles, "amount_ratio", strength, fog_fade_time)

	# Fully off when cleared
	if strength <= 0.001:
		if immediate:
			bolton_fog_particles.emitting = false
		else:
			var twn2 := create_tween()
			twn2.tween_interval(fog_fade_time)
			twn2.tween_callback(func():
				if bolton_fog_particles:
					bolton_fog_particles.emitting = false
			)


func _spawn_billboards() -> void:
	_billboards.clear()
	_wind_billboards.clear()
	_geo_billboards.clear()
	_hydro_billboards.clear()
	_solar_billboards.clear()
	_bolton_billboards.clear()

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

		var path := String(scene.resource_path).to_lower()
		if path.contains("grange_info_billboard"):
			_geo_billboards.append(board)
		elif path.contains("tallaght_info_billboard"):
			_hydro_billboards.append(board)
		elif path.contains("aungier_info_billboard"):
			_solar_billboards.append(board)
		elif path.contains("bolton_info_billboard"):
			_bolton_billboards.append(board)
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

func _update_bolton_billboards_progress() -> void:
	if _bolton_billboards.is_empty():
		return
	var count := 0
	for k in _bolton_pressed.keys(): 
		if _bolton_pressed[k]:
			count += 1
	for board in _bolton_billboards:
		if board and board.has_method("set_progress"):
			board.call("set_progress", count, 4)


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

		_update_energy_box_unlocks()
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

		_update_energy_box_unlocks()


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

	_update_energy_box_unlocks()


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

		_update_energy_box_unlocks()


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
	_bolton_billboards.clear()

	_energy_box = null
	
	_set_bolton_fog_strength(0.0, true)	
