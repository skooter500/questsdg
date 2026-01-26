extends Node3D

@export var follow_smooth_speed: float = 18.0
const HAND_LOCK_KEY := "held_object"

@onready var _grab_area: Area3D = $GrabArea

var _hand_inside: bool = false
var _hand: Node3D = null  
var _grab_hand: Node3D = null 

var _was_grabbed: bool = false
var _is_grabbing: bool = false
var _hold_offset: Transform3D = Transform3D.IDENTITY


func _ready() -> void:
	_grab_area.monitoring = true
	_grab_area.area_entered.connect(_on_grab_area_entered)
	_grab_area.area_exited.connect(_on_grab_area_exited)


func _process(delta: float) -> void:
	# While grabbing: follow regardless of "inside"
	if _is_grabbing and _grab_hand:
		if not _grab_hand.grabbed:
			_end_grab()
			return
		_follow_hand(delta)
		return

	# Not grabbing: can only start if a hand is inside
	if _hand_inside and _hand:
		var grabbed_now: bool = _hand.grabbed
		if grabbed_now and not _was_grabbed:
			_start_grab()
		_was_grabbed = grabbed_now


func _on_grab_area_entered(area: Area3D) -> void:
	if not area.name.to_lower().contains("hand"):
		return

	var hand: Node3D = _find_hand_node(area)
	if hand == null:
		return

	# Lock check MUST use local 'hand' (not _hand)
	var held: Object = hand.get_meta(HAND_LOCK_KEY, null) as Object
	if held != null and not is_instance_valid(held):
		hand.set_meta(HAND_LOCK_KEY, null)
		held = null

	if held != null and held != self:
		return

	_hand_inside = true
	_hand = hand


func _on_grab_area_exited(area: Area3D) -> void:
	if not area.name.to_lower().contains("hand"):
		return

	# If we’re grabbing with this same hand, keep grab alive until fist opens
	if _is_grabbing and _grab_hand and _grab_hand.grabbed:
		return

	_hand_inside = false
	_hand = null
	_was_grabbed = false


func _start_grab() -> void:
	if _hand == null:
		return

	var held: Object = _hand.get_meta(HAND_LOCK_KEY, null) as Object
	if held != null and not is_instance_valid(held):
		_hand.set_meta(HAND_LOCK_KEY, null)
		held = null

	if held != null and held != self:
		return

	_hand.set_meta(HAND_LOCK_KEY, self)
	_grab_hand = _hand

	_is_grabbing = true
	_hold_offset = _grab_hand.global_transform.affine_inverse() * global_transform


func _end_grab() -> void:
	if not _is_grabbing:
		return

	_is_grabbing = false

	if _grab_hand:
		var held: Object = _grab_hand.get_meta(HAND_LOCK_KEY, null) as Object
		if held == self:
			_grab_hand.set_meta(HAND_LOCK_KEY, null)

	_grab_hand = null
	_hand = null
	_hand_inside = false
	_was_grabbed = false


func _follow_hand(delta: float) -> void:
	if _grab_hand == null:
		return

	var held: Object = _grab_hand.get_meta(HAND_LOCK_KEY, null) as Object
	if held != self:
		_end_grab()
		return

	var target: Transform3D = _grab_hand.global_transform * _hold_offset
	var alpha: float = clampf(delta * follow_smooth_speed, 0.0, 1.0)
	global_transform = global_transform.interpolate_with(target, alpha)

func _find_hand_node(hand_area: Area3D) -> Node3D:
	var n: Node = hand_area
	for _i in range(8):
		if n == null:
			return null
		if n is Node3D and "grabbed" in n:
			return n as Node3D
		n = n.get_parent()
	return hand_area.get_parent() as Node3D
