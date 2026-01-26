extends MeshInstance3D

@export var rotation_speed: float = 3.0
@export var spinning: bool = false # start OFF

func set_spinning(on: bool) -> void:
	spinning = on

func _process(delta: float) -> void:
	if not spinning:
		return
	rotate_x(rotation_speed * delta)
