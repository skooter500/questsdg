extends MeshInstance3D

@export var rotation_speed := 3.0

func _process(delta: float) -> void:
	rotate_x(rotation_speed * delta)
