extends Area3D

var fade_tween:Tween = null
@export var goal_num:int = 6


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

func setup_vid_screen(vid_screen, view_port):
	var m:StandardMaterial3D = vid_screen.get_surface_override_material(0)
	var t:ViewportTexture = m.albedo_texture
	var p = "animated_goals/" + name + "/" + view_port
	print(t.viewport_path)
	print(p)
	t.viewport_path = p
	vid_screen.set_surface_override_material(0, m)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	setup_vid_screen($scaler/vid_screen, "SubViewport")
	setup_vid_screen($scaler/vid_screen2, "SubViewport2")
	setup_vid_screen($scaler/vid_screen3, "SubViewport")
	setup_vid_screen($scaler/vid_screen4, "SubViewport2")
	setup_vid_screen($scaler/vid_screen5, "SubViewport")
	setup_vid_screen($scaler/vid_screen6, "SubViewport2")
	bounce_in()
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(delta)
	rotate_x(delta)
	pass
