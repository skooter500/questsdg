extends Area3D

var fade_tween:Tween = null

var mats = []

func fade_in():
	if fade_tween:
		return
	else:
		fade_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
		$selected_sound.pitch_scale = 0.5
		$selected_sound.play()
		for mat in mats:
			fade_tween.tween_property(mat, "albedo_color:a", 1.0, 2.0)
			fade_tween.set_parallel(true)
			# Optional: Hide the mesh when fade completes
		# fade_tween.finished.connect(make_invisible)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		var mat:StandardMaterial3D = child.get_surface_override_material(0)
		mat = mat.duplicate()
		mat.albedo_color.a = 0
		child.set_surface_override_material(0, mat)
		mats.push_back(mat)
	# fade_in()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# rotate_y(delta)
	# rotate_x(delta)
	pass
