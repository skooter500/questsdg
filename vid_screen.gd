extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var video_player = $VideoStreamPlayer
	var material = get_surface_override_material(0)
	material.albedo_texture = video_player.get_video_texture()
	material.emission_enabled = true
	material.emission_texture = video_player.get_video_texture()
	material.emission_energy = 1.0
	# Apply material to mesh
	set_surface_override_material(0, material)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
