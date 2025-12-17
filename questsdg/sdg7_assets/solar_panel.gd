extends Node3D

signal cleaned(panel: Node3D)

@export var track_turn_speed: float = 200.0
@export var facing_yaw_offset_deg: float = 105

var _sun: Node3D = null

@export var clean_time: float = 1.5
@export var min_alpha: float = 0.0
@export var hide_on_clean: bool = true

@onready var dirt_node: Node = $dirt
@onready var clean_area: Area3D = $CleanArea

@onready var squeak: AudioStreamPlayer3D = $CleaningNoise
var _squeaking: bool = false

var _progress: float = 0.0
var _done: bool = false
var _hands_inside: Dictionary = {} 


func _ready() -> void:
	_sun = get_tree().get_first_node_in_group("sun_node") as Node3D
	_make_dirt_materials_local()

	clean_area.monitoring = true
	clean_area.area_entered.connect(_on_area_entered)
	clean_area.area_exited.connect(_on_area_exited)

	# Squeak setup
	if squeak and squeak.stream:
		if squeak.stream.has_method("set_loop"):
			squeak.stream.set_loop(true)
		elif "loop" in squeak.stream:
			squeak.stream.loop = true
		squeak.volume_db = -18.0
		squeak.max_distance = 3.0
		squeak.unit_size = 1.0

	_apply_alpha(1.0)


func _process(delta: float) -> void:
	if _sun == null:
		_sun = get_tree().get_first_node_in_group("sun_node") as Node3D
	else:
		var to := _sun.global_position - global_position
		to.y = 0.0
		if to.length() > 0.001:
			to = to.normalized()
			var target_yaw := atan2(to.x, to.z) + deg_to_rad(facing_yaw_offset_deg)

			var r := rotation
			r.y = lerp_angle(r.y, target_yaw, clampf(delta * track_turn_speed, 0.0, 1.0))
			rotation = r

	if _done:
		return

	var touching: bool = _hands_inside.size() > 0

	# Squeak while touching (fade in/out)
	if squeak and squeak.stream:
		if touching and not _squeaking:
			_squeaking = true
			squeak.volume_db = -30.0
			squeak.play()
			var t_in := create_tween()
			t_in.tween_property(squeak, "volume_db", -18.0, 0.12)
		elif (not touching) and _squeaking:
			_squeaking = false
			var t_out := create_tween()
			t_out.tween_property(squeak, "volume_db", -40.0, 0.15)
			t_out.tween_callback(Callable(squeak, "stop"))

	if touching:
		_progress += delta / max(clean_time, 0.001)
		_progress = clampf(_progress, 0.0, 1.0)

		var a := lerpf(1.0, min_alpha, _progress)
		_apply_alpha(a)

		if _progress >= 1.0:
			_finish_clean()

func _make_dirt_materials_local() -> void:
	if dirt_node == null:
		return
	var meshes: Array[MeshInstance3D] = []
	if dirt_node is MeshInstance3D:
		meshes.append(dirt_node)
	else:
		for c in dirt_node.get_children():
			if c is MeshInstance3D:
				meshes.append(c)
	for m in meshes:
		var mat := m.get_active_material(0)
		if mat:
			var dup := mat.duplicate()
			if dup is Resource:
				dup.resource_local_to_scene = true
			m.set_surface_override_material(0, dup)

func _finish_clean() -> void:
	_done = true
	_apply_alpha(min_alpha)

	# Stop squeak immediately when finished
	if squeak and squeak.playing:
		squeak.stop()
	_squeaking = false

	if hide_on_clean and dirt_node:
		dirt_node.visible = false

	cleaned.emit(self)


func _on_area_entered(area: Area3D) -> void:
	if _done:
		return
	if not area.name.to_lower().contains("hand"):
		return
	var hand := _find_hand_node(area)
	if hand:
		_hands_inside[hand] = true


func _on_area_exited(area: Area3D) -> void:
	if not area.name.to_lower().contains("hand"):
		return
	var hand := _find_hand_node(area)
	if hand and _hands_inside.has(hand):
		_hands_inside.erase(hand)


func _apply_alpha(alpha: float) -> void:
	if dirt_node == null:
		return

	if dirt_node is MeshInstance3D:
		_set_mesh_alpha(dirt_node as MeshInstance3D, alpha)
	else:
		for c in dirt_node.get_children():
			if c is MeshInstance3D:
				_set_mesh_alpha(c as MeshInstance3D, alpha)


func _set_mesh_alpha(mesh: MeshInstance3D, alpha: float) -> void:
	var mat := mesh.get_active_material(0)
	if mat == null:
		return

	if mat is StandardMaterial3D:
		var m := mat as StandardMaterial3D
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		var col := m.albedo_color
		col.a = alpha
		m.albedo_color = col


func _find_hand_node(hand_area: Area3D) -> Node3D:
	var n: Node = hand_area
	for _i in range(8):
		if n == null:
			return null
		if n is Node3D and "grabbed" in n:
			return n as Node3D
		n = n.get_parent()
	return hand_area.get_parent() as Node3D
