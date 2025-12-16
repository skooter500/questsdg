extends Node3D

signal lever_state_changed(is_on: bool)

@export var off_angle_deg: float = -45.0
@export var on_angle_deg: float = 45.0
@export var tween_time: float = 0.2

# How far the hand needs to move (meters) to go fully OFF→ON (or ON→OFF)
@export var hand_travel_distance: float = 0.25    # smaller = more sensitive
@export var hand_smooth_speed: float = 15.0       # higher = snappier, lower = smoother

var is_on: bool = false

var _hand_inside: bool = false
var _hand: Node3D = null
var _was_grabbed: bool = false
var _is_grabbing: bool = false

var _grab_from_on: bool = false # were we ON or OFF when the grab started?
var _hand_start_axis: float = 0.0 # starting hand position along X
var _smoothed_axis: float = 0.0 # filtered axis position

@onready var _pivot: Node3D = $Hinge
@onready var _area: Area3D = $Hinge/Area3D


func _ready() -> void:
	_area.area_entered.connect(_on_area_entered)
	_area.area_exited.connect(_on_area_exited)
	_apply_angle()


func _on_area_entered(area: Area3D) -> void:
	if area.name.to_lower().contains("hand"):
		_hand_inside = true
		_hand = area.get_parent()


func _on_area_exited(area: Area3D) -> void:
	if area.name.to_lower().contains("hand"):
		_hand_inside = false
		# If we’re currently grabbing, keep the grab alive until fist opens
		if _hand and _hand.grabbed:
			return
		_hand = null
		_was_grabbed = false
		_end_grab()


func _process(delta: float) -> void:
	if (_hand_inside or _is_grabbing) and _hand:
		var grabbed_now: bool = _hand.grabbed  

		if grabbed_now and not _was_grabbed:
			_start_grab()
		elif not grabbed_now and _was_grabbed:
			_end_grab()
		_was_grabbed = grabbed_now

		if _is_grabbing:
			_update_angle_from_hand(delta)


func _start_grab() -> void:
	_is_grabbing = true
	_grab_from_on = is_on # remember which state we started in
	_hand_start_axis = _hand_axis()
	_smoothed_axis = _hand_start_axis


func _end_grab() -> void:
	if not _is_grabbing:
		return
	_is_grabbing = false

	# Decide ON/OFF based on where the lever ended up
	var angle: float = _pivot.rotation_degrees.z
	var mid: float = (off_angle_deg + on_angle_deg) * 0.5
	is_on = angle >= mid
	lever_state_changed.emit(is_on)
	_animate_to_target()


func _update_angle_from_hand(delta: float) -> void:
	var raw_axis: float = _hand_axis()

	# Smooth the axis to kill jitter
	var alpha: float = clamp(delta * hand_smooth_speed, 0.0, 1.0)
	_smoothed_axis = lerp(_smoothed_axis, raw_axis, alpha)

	# How far have we moved since grab start?
	var delta_axis: float = _smoothed_axis - _hand_start_axis

	# Direction of movement: forward to turn ON, backward to turn OFF
	# (we already inverted X in _hand_axis, so no extra invert here)
	var dir: float = -1.0 if _grab_from_on else 1.0
	var t: float = delta_axis * dir / hand_travel_distance
	t = clamp(t, 0.0, 1.0)

	# If we started OFF, move OFF→ON; if started ON, move ON→OFF
	var from_angle: float = on_angle_deg if _grab_from_on else off_angle_deg
	var to_angle: float = off_angle_deg if _grab_from_on else on_angle_deg

	var angle: float = lerp(from_angle, to_angle, t)

	var rot: Vector3 = _pivot.rotation_degrees
	rot.z = angle
	_pivot.rotation_degrees = rot


func _hand_axis() -> float:
	# Hand position in pivot’s local space
	var local: Vector3 = _pivot.to_local(_hand.global_transform.origin)
	# Use local X, inverted so pushing "forward" drives lever forward
	return -local.x


func _apply_angle() -> void:
	var target: float = off_angle_deg if not is_on else on_angle_deg
	var rot: Vector3 = _pivot.rotation_degrees
	rot.z = target
	_pivot.rotation_degrees = rot


func _animate_to_target() -> void:
	var target: float = off_angle_deg if not is_on else on_angle_deg
	var rot: Vector3 = _pivot.rotation_degrees
	rot.z = target

	var t: Tween = create_tween()
	t.tween_property(_pivot, "rotation_degrees", rot, tween_time) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_IN_OUT)
