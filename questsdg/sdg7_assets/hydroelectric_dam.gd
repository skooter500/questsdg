extends Node3D

@export var gate_mesh: Node3D
@export var gate_open_offset_z: float = -1.0   # how far down the gate moves when open
@export var gate_anim_time: float = 0.6

@onready var _lever: Node3D = $LeverRoot
@onready var _ambient_water: AudioStreamPlayer3D = $AmbientWater
@onready var running_water: AudioStreamPlayer3D = $RunningWater
@onready var water_flow: GPUParticles3D = $WaterFlow

var _gate_start_pos: Vector3

func _ready() -> void:
	if gate_mesh:
		_gate_start_pos = gate_mesh.position

	# Spatial ambient water, always on
	if _ambient_water:
		_ambient_water.stream.loop = true
		_ambient_water.volume_db = -10.0
		_ambient_water.max_distance = 6.0
		_ambient_water.unit_size = 1.0
		_ambient_water.play()

	# Spatial spill / running water, controlled by lever
	if running_water:
		running_water.stream.loop = true
		running_water.volume_db = -6.0
		running_water.max_distance = 6.0
		running_water.unit_size = 1.0
		running_water.stop()

	# Listen to the lever
	if _lever:
		_lever.lever_state_changed.connect(_on_lever_state_changed)


func _on_lever_state_changed(is_on: bool) -> void:
	# Move the gate
	if gate_mesh:
		var target_pos := _gate_start_pos
		if is_on:
			target_pos.z += gate_open_offset_z  # open (move down)
		# tween the gate to its new position
		var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(gate_mesh, "position", target_pos, gate_anim_time)

	# Control the spill water audio
	if running_water:
		if is_on:
			if not running_water.playing:
				running_water.play()
		else:
			running_water.stop()
		
	if water_flow: 
		water_flow.emitting = is_on
