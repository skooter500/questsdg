extends Area3D

@export var image:Texture 

func set_texture(mesh:MeshInstance3D):
	var mat:StandardMaterial3D = mesh.get_surface_override_material(0)
	mat = mat.duplicate()
	mat.albedo_texture = image
	mesh.set_surface_override_material(0, mat)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_texture($scaler/front)
	set_texture($scaler/back)
	set_texture($scaler/left)
	set_texture($scaler/right)
	set_texture($scaler/top)
	set_texture($scaler/bot)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# rotate_y(delta)
	# rotate_x(delta)
	pass


func _on_area_entered(area: Area3D) -> void:
	play_sound()
	if area.name.contains("hand"):
		var t = create_tween() \
			.set_ease(Tween.EASE_IN_OUT) \
			.set_trans(Tween.TRANS_QUINT)
		scale = Vector3.ONE
		t.tween_property(self, "scale", big_scale, 1)
	pass # Replace with function body.

var big_scale = Vector3(1.25, 1.25, 1.25)

func play_sound():
	$AudioStreamPlayer3D.pitch_scale = randf_range(0.8, 1.2)
	$AudioStreamPlayer3D.play()

func _on_area_exited(area: Area3D) -> void:
	play_sound()
	if area.name.contains("hand"):
		var t = create_tween() \
			.set_ease(Tween.EASE_IN_OUT) \
			.set_trans(Tween.TRANS_QUINT)
		scale = big_scale
		t.tween_property(self, "scale", Vector3.ONE, 1)
	pass # Replace with function body.
