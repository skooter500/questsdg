extends Node3D

signal hydro_progress(step: int, total: int)
signal hydro_completed

@export var gate_mesh: Node3D
@export var gate_open_offset_z: float = -0.8
@export var gate_anim_time: float = 0.6

@export var debris1: Node3D
@export var debris2: Node3D
@export var debris_zone1: Area3D
@export var debris_zone2: Area3D
@export var blades: Node3D   

# Flow scaling when debris is cleared 
@export var flow_min_amount_ratio: float = 0.25
@export var flow_max_amount_ratio: float = 1.0
@export var running_water_min_db: float = -18.0
@export var running_water_max_db: float = -6.0

@onready var _lever: Node3D = $LeverRoot
@onready var _ambient_water: AudioStreamPlayer3D = $AmbientWater
@onready var running_water: AudioStreamPlayer3D = $RunningWater
@onready var water_flow: GPUParticles3D = $WaterFlow

const TOTAL: int = 3

var _gate_start_pos: Vector3
var _gate_open: bool = false
var _cleared_zone1: bool = false
var _cleared_zone2: bool = false
var _completed: bool = false


func _ready() -> void:
	if gate_mesh:
		_gate_start_pos = gate_mesh.position

	# Ambient water always on
	if _ambient_water and _ambient_water.stream:
		_ambient_water.stream.loop = true
		_ambient_water.volume_db = -10.0
		_ambient_water.max_distance = 6.0
		_ambient_water.unit_size = 1.0
		_ambient_water.play()

	# Running water controlled by lever
	if running_water and running_water.stream:
		running_water.stream.loop = true
		running_water.volume_db = running_water_max_db
		running_water.max_distance = 6.0
		running_water.unit_size = 1.0
		running_water.stop()

	# Start blocked visuals
	if water_flow:
		water_flow.emitting = false
		water_flow.amount_ratio = flow_min_amount_ratio

	# Lever signal
	if _lever and _lever.has_signal("lever_state_changed"):
		_lever.lever_state_changed.connect(_on_lever_state_changed)

	# Debris zones use Area overlap 
	if debris_zone1:
		debris_zone1.area_exited.connect(_on_debris_zone_area_exited.bind(1))
	if debris_zone2:
		debris_zone2.area_exited.connect(_on_debris_zone_area_exited.bind(2))

	# Initial UI + blades state
	_emit_progress()
	_update_blades_spin()


func _on_lever_state_changed(is_on: bool) -> void:
	_gate_open = is_on

	# Gate tween
	if gate_mesh:
		var target_pos: Vector3 = _gate_start_pos
		if is_on:
			target_pos.z += gate_open_offset_z
		var twn := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		twn.tween_property(gate_mesh, "position", target_pos, gate_anim_time)

	# Audio
	if running_water:
		if is_on:
			if not running_water.playing:
				running_water.play()
			_apply_flow_strength(_cleared_count())
		else:
			running_water.stop()

	# Particles
	if water_flow:
		water_flow.emitting = is_on
		if is_on:
			_apply_flow_strength(_cleared_count())
		else:
			water_flow.amount_ratio = flow_min_amount_ratio

	# Blades can only spin once gate is open AND debris cleared
	_update_blades_spin()

	# Progress: step 1 is lever open
	_emit_progress()
	_check_completed()


func _on_debris_zone_area_exited(area: Area3D, zone_id: int) -> void:
	
	# Only count if the exiting Area3D is the debris’ GrabArea
	if zone_id == 1:
		if _cleared_zone1:
			return
		if area == _grab_area_of(debris1):
			_cleared_zone1 = true
		else:
			return
	elif zone_id == 2:
		if _cleared_zone2:
			return
		if area == _grab_area_of(debris2):
			_cleared_zone2 = true
		else:
			return

	# Strength only depends on debris cleared (0..2)
	var cleared: int = _cleared_count()
	if _gate_open:
		_apply_flow_strength(cleared)

	# Blades can only spin once gate is open AND debris cleared
	_update_blades_spin()

	# Progress: step 2/3 come from debris cleared
	_emit_progress()
	_check_completed()


func _grab_area_of(debris: Node3D) -> Area3D:
	if debris == null:
		return null
	return debris.get_node_or_null("GrabArea") as Area3D


func _cleared_count() -> int:
	return int(_cleared_zone1) + int(_cleared_zone2)


func _current_step() -> int:
	return int(_gate_open) + _cleared_count()


func _emit_progress() -> void:
	hydro_progress.emit(_current_step(), TOTAL)


func _check_completed() -> void:
	if _completed:
		return
	if _current_step() >= TOTAL:
		_completed = true
		hydro_completed.emit()


func _apply_flow_strength(cleared: int) -> void:
	var t: float = clampf(float(cleared) / 2.0, 0.0, 1.0)

	if water_flow:
		water_flow.amount_ratio = lerpf(flow_min_amount_ratio, flow_max_amount_ratio, t)

	if running_water:
		running_water.volume_db = lerpf(running_water_min_db, running_water_max_db, t)


func _update_blades_spin() -> void:
	# spin only when gate open AND both debris cleared
	var should_spin: bool = _gate_open and (_cleared_count() >= 2)

	if blades == null:
		return

	if blades.has_method("set_spinning"):
		blades.call("set_spinning", should_spin)
		return

	if blades.get("spinning") != null:
		blades.set("spinning", should_spin)
