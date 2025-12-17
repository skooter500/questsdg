extends Node3D

signal activated(key: String)

@export var key: String = "wind" # wind/solar/hydro/geo
@export var unlocked: bool = false # manager sets this true/false

@export var press_distance: float = -0.02
@export var press_time: float = 0.08

@export var denied_cooldown: float = 0.35

@export var red_color: Color = Color(1.0, 0.15, 0.15)
@export var green_color: Color = Color(0.15, 1.0, 0.4)
@export var emission_energy: float = 1.6

@onready var button_mesh: Node3D = $ButtonRoot/ButtonMesh
@onready var button_area: Area3D = $ButtonRoot/ButtonArea
@onready var status_light: MeshInstance3D = $StatusLight
@onready var denied_sound: AudioStreamPlayer3D = $"../DeniedSound"

var _pressed: bool = false
var _is_on: bool = false
var _sent_once: bool = false
var _button_start_pos: Vector3
var _last_denied_time: float = -999.0

func _ready() -> void:
	if button_mesh:
		_button_start_pos = button_mesh.position

	if button_area:
		button_area.monitoring = true
		button_area.area_entered.connect(_on_button_area_entered)
		button_area.area_exited.connect(_on_button_area_exited)

	_apply_light_color(red_color) # starts red

func set_unlocked(v: bool) -> void:
	unlocked = v
	# Keep red until pressed (even when unlocked)
	if not _is_on:
		_apply_light_color(red_color)

func _on_button_area_entered(area: Area3D) -> void:
	if not area.name.to_lower().contains("hand"):
		return

	# Locked => deny
	if not unlocked:
		_play_denied()
		return

	# Already pressed/latched => ignore (optional)
	if _is_on:
		return

	if _pressed:
		return

	_pressed = true
	_press_button()

	# Latch ON once
	_is_on = true
	_apply_light_color(green_color)

	if not _sent_once:
		_sent_once = true
		activated.emit(key)

func _on_button_area_exited(area: Area3D) -> void:
	if not area.name.to_lower().contains("hand"):
		return
	_release_button()

func _press_button() -> void:
	if not button_mesh:
		return
	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(
		button_mesh,
		"position",
		_button_start_pos + Vector3(0, 0, press_distance),
		press_time
	)

func _release_button() -> void:
	if not button_mesh:
		return
	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(button_mesh, "position", _button_start_pos, press_time)
	t.finished.connect(func(): _pressed = false)

func _play_denied() -> void:
	var now: float = float(Time.get_ticks_msec()) / 1000.0
	if now - _last_denied_time < denied_cooldown:
		return
	_last_denied_time = now
	if denied_sound and denied_sound.stream:
		denied_sound.play()

func _apply_light_color(c: Color) -> void:
	if status_light == null:
		return

	var mat := status_light.get_active_material(0)
	if mat == null:
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		status_light.set_surface_override_material(0, m)
		mat = m

	if mat is StandardMaterial3D:
		var m := mat as StandardMaterial3D
		m.albedo_color = c
		m.emission = c
		m.emission_energy = emission_energy
