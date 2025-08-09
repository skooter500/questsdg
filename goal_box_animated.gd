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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	
	bounce_in()
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# rotate_y(delta)
	# rotate_x(delta)
	pass
