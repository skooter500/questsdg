extends RigidBody3D

var fade_tween:Tween = null

var sprites = []
var mats = []
var anim0Frames:SpriteFrames
var anim1Frames:SpriteFrames

@export var goal_num1:int = 2

func bounce_in():
	$Area3D.monitoring = true
	$Area3D/scaler/front.play("default")
	$Area3D/scaler/bott.play("default")
	$Area3D/scaler/left.play("default")
	$Area3D/scaler/top.play("default")
	$Area3D/scaler/back.play("default")
	$Area3D/scaler/right.play("default")
	
	
	if fade_tween:
		return
	else:
		scale = Vector3.ZERO
		fade_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
		fade_tween.tween_property(self, "scale", Vector3.ONE,2)
		theme_sound.volume_db = -100
		$playlist_looper.play()
		fade_tween.set_parallel(true)
		fade_tween.tween_property(theme_sound, "volume_db", -20, 2)
			# Optional: Hide the mesh when fade completes
		# fade_tween.finished.connect(make_invisible)

var theme_sound:AudioStreamPlayer3D

var lerp_target:Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area3D.monitoring = false
	anim0Frames = $Area3D/scaler/front.sprite_frames
	anim1Frames = $Area3D/scaler/bott.sprite_frames
	
	sprites.push_back($Area3D/scaler/front)
	sprites.push_back($Area3D/scaler/bott)
	sprites.push_back($Area3D/scaler/left)
	sprites.push_back($Area3D/scaler/top)
	sprites.push_back($Area3D/scaler/back)
	sprites.push_back($Area3D/scaler/right)
	
	for i in range(sprites.size()):
		if i == 2 or i == 5: # left and right faces
			sprites[i].sprite_frames = anim1Frames
		else:
			sprites[i].sprite_frames = anim0Frames
		# sprites[i].play("default")
	
	lerp_target = global_position
	
	theme_sound = $playlist_looper/AudioStreamPlayer3D
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		pass
# Replace with function body.
