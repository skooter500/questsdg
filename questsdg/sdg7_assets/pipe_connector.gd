extends Node3D

signal snapped

@export var snap_area_path: NodePath 
@export var snap_point_path: NodePath 
@export var follow_smooth_speed: float = 18.0

var _hand_inside: bool = false
var _hand: Node3D = null
var _was_grabbed: bool = false
var _is_grabbing: bool = false
var _locked: bool = false

var _hold_offset: Transform3D = Transform3D.IDENTITY
var _snap_area: Area3D = null
var _snap_point: Node3D = null

@onready var _grab_area: Area3D = $GrabArea
@onready var _snap_sound: AudioStreamPlayer3D = $SnapSound


func _ready() -> void:
	_snap_area = get_node_or_null(snap_area_path) as Area3D
	_snap_point = get_node_or_null(snap_point_path) as Node3D

	_grab_area.area_entered.connect(_on_grab_area_entered)
	_grab_area.area_exited.connect(_on_grab_area_exited)

	_grab_area.monitoring = true

	if _snap_area:
		_snap_area.monitoring = true
		# Autosnap when our GrabArea enters the snap area
		_snap_area.area_entered.connect(_on_snap_area_entered)


func _process(delta: float) -> void:
	if _locked:
		return

	if (_hand_inside or _is_grabbing) and _hand:
		var grabbed_now: bool = _hand.grabbed

		if grabbed_now and not _was_grabbed:
			_start_grab()
		elif (not grabbed_now) and _was_grabbed:
			_end_grab()

		_was_grabbed = grabbed_now

		if _is_grabbing:
			_follow_hand(delta)


func _on_grab_area_entered(area: Area3D) -> void:
	if _locked:
		return
	if area.name.to_lower().contains("hand"):
		_hand_inside = true
		_hand = area.get_parent() as Node3D


func _on_grab_area_exited(area: Area3D) -> void:
	if _locked:
		return
	if area.name.to_lower().contains("hand"):
		_hand_inside = false

		# Keep grab alive until fist opens
		if _hand and _hand.grabbed:
			return

		_hand = null
		_was_grabbed = false
		_end_grab()


func _start_grab() -> void:
	if _hand == null:
		return
	_is_grabbing = true

	# Store how the pipe sits relative to the hand at grab moment (prevents jumping)
	_hold_offset = _hand.global_transform.affine_inverse() * global_transform


func _end_grab() -> void:
	if not _is_grabbing:
		return
	_is_grabbing = false

	if _is_in_snap_area():
		_snap_and_lock()


func _follow_hand(delta: float) -> void:
	if _hand == null:
		return

	var target: Transform3D = _hand.global_transform * _hold_offset
	var alpha: float = clamp(delta * follow_smooth_speed, 0.0, 1.0)
	global_transform = global_transform.interpolate_with(target, alpha)

	# Auto-snap while holding too 
	if _is_in_snap_area():
		_snap_and_lock()


func _is_in_snap_area() -> bool:
	if _locked or _snap_area == null:
		return false
	# GrabArea is our “probe” area; HeatPocket is the snap area
	return _snap_area.overlaps_area(_grab_area)


func _on_snap_area_entered(area: Area3D) -> void:
	if _locked:
		return
	# Only snap when our probe enters
	if area == _grab_area:
		_snap_and_lock()


func _snap_and_lock() -> void:
	if _locked:
		return
	if _snap_point == null:
		push_warning("PipeConnector: snap_point_path not set")
		return

	_locked = true
	_is_grabbing = false
	_hand_inside = false
	_was_grabbed = false
	_hand = null

	global_transform = _snap_point.global_transform

	if _snap_sound and _snap_sound.stream:
		_snap_sound.play()

	snapped.emit()
