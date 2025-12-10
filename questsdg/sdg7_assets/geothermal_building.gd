extends Node3D

@export var pipes_mesh: MeshInstance3D
@export var idle_material: Material
@export var active_material: Material

@export var button_mesh: Node3D
@export var press_distance: float = 0.06
@export var press_time: float = 0.08

@export var steam_particles: Array[GPUParticles3D]
@onready var geo_hum: AudioStreamPlayer3D = $GeoPumpNoise

var active := false
var pressed := false
var button_start_pos: Vector3


func _ready() -> void:
	if pipes_mesh and idle_material:
		pipes_mesh.set_surface_override_material(0, idle_material)

	if button_mesh:
		button_start_pos = button_mesh.position


func _on_ButtonArea_area_entered(area: Area3D) -> void:
	if not area.name.to_lower().contains("hand"):
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
	t.tween_property(
		button_mesh,
		"position",
		button_start_pos,
		press_time
	)

	t.finished.connect(func():
		pressed = false
	)
