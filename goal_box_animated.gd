extends Area3D

var fade_tween:Tween = null

var sprites = []
var mats = []

func bounce_in():
	if fade_tween:
		return
	else:
		scale = Vector3.ZERO
		fade_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
		fade_tween.tween_property(self, "scale", Vector3.ONE,2)
		$selected_sound.pitch_scale = 0.6
		$selected_sound.play()
			# Optional: Hide the mesh when fade completes
		# fade_tween.finished.connect(make_invisible)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	sprites.push_back($scaler/front)
	sprites.push_back($scaler/bott)
	sprites.push_back($scaler/left)
	sprites.push_back($scaler/top)
	sprites.push_back($scaler/back)
	sprites.push_back($scaler/right)
	
	#for sprite in sprites:
		#var mat:StandardMaterial3D = sprite.get_surface_override_material(0)
		#mat = mat.duplicate()
		#mat.albedo_color.a = 0
		#sprites.set_surface_override_material(0, mat)
		#mats.push_back(mat)
	bounce_in()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# rotate_y(delta)
	# rotate_x(delta)
	pass
