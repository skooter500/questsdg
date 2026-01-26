extends Node3D

signal pipe_connected
signal geothermal_activated

@export var pipes_mesh: MeshInstance3D
@export var idle_material: Material
@export var active_material: Material

@export var button_mesh: Node3D
@export var press_distance: float = 0.06
@export var press_time: float = 0.08

@export var steam_particles: Array[GPUParticles3D]

@onready var geo_hum: AudioStreamPlayer3D = $GeoPumpNoise
@onready var denied_sound: AudioStreamPlayer3D = $DeniedSound

@export var pipe_connector_path: NodePath

@export var denied_cooldown: float = 0.35
var _last_denied_time: float = -999.0

var active: bool = false
var pressed: bool = false
var pipe_is_connected: bool = false
var _sent_geo_activated: bool = false
var button_start_pos: Vector3


func _ready() -> void:
	if pipes_mesh and idle_material:
		pipes_mesh.set_surface_override_material(0, idle_material)

	if button_mesh:
		button_start_pos = button_mesh.position

	# Listen to pipe snap
	var pipe := get_node_or_null(pipe_connector_path)
	if pipe and pipe.has_signal("snapped"):
		pipe.snapped.connect(_on_pipe_snapped)


func _on_pipe_snapped() -> void:
	pipe_is_connected = true
	emit_signal("pipe_connected")


func _on_ButtonArea_area_entered(area: Area3D) -> void:
	if not area.name.to_lower().contains("hand"):
		return

	# Block until pipe connected
	if not pipe_is_connected:
		_play_denied()
		return

	if pressed:
		return

	pressed = true
	_press_button()
	_toggle_geothermal()


func _on_ButtonArea_area_exited(area: Area3D) -> void:
	if not area.name.to_lower().contains("hand"):
		return

	_release_button()


func _play_denied() -> void:
	var now: float = float(Time.get_ticks_msec()) / 1000.0
	if now - _last_denied_time < denied_cooldown:
		return
	_last_denied_time = now

	if denied_sound and denied_sound.stream:
		denied_sound.play()


func _toggle_geothermal() -> void:
	active = !active

	var mat := active_material if active else idle_material
	if pipes_mesh:
		pipes_mesh.set_surface_override_material(0, mat)

	if geo_hum:
		if active:
			geo_hum.play()
		else:
			geo_hum.stop()

	for steam in steam_particles:
		if steam:
			steam.emitting = active

	# Emit “activated” once (when turned ON first time)
	if active and not _sent_geo_activated:
		_sent_geo_activated = true
		emit_signal("geothermal_activated")


func _press_button() -> void:
	if not button_mesh:
		return

	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(
		button_mesh,
		"position",
		button_start_pos + Vector3(0, 0, press_distance),
		press_time
	)


func _release_button() -> void:
	if not button_mesh:
		return

	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(button_mesh, "position", button_start_pos, press_time)

	t.finished.connect(func():
		pressed = false
	)
