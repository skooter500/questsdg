extends RigidBody3D

var fade_tween:Tween = null

var sprites = []
var mats = []
var anim0Frames:SpriteFrames
var anim1Frames:SpriteFrames

@export var goal_num1:int = 2

func bounce_in():
	if fade_tween:
		return
	else:
		scale = Vector3.ZERO
		fade_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
		fade_tween.tween_property(self, "scale", Vector3.ONE,2)
		$selected_sound.pitch_scale = 0.6
		# $selected_sound.play()
		# theme_sound.volume_db = -100
		fade_tween.set_parallel(true)
		fade_tween.tween_property(theme_sound, "volume_db", -46.021, 2)
			# Optional: Hide the mesh when fade completes
		# fade_tween.finished.connect(make_invisible)

var theme_sound:AudioStreamPlayer3D

func load_frames():
	anim0Frames = SpriteFrames.new()
	anim1Frames = SpriteFrames.new()
	anim0Frames.add_animation("default")
	anim1Frames.add_animation("default")

	var spritesheet0_path = "res://goals/Goal-" + str(goal_num1) + "/Goal " + str(goal_num1) + "/" + str(goal_num1) + "_SDG_MakeEveryDayCount_Gifs_GDU.png"
	var spritesheet1_path = "res://goals/Goal-" + str(goal_num1) + "/Goal " + str(goal_num1) + "/E_GIF_" + "%02d" % goal_num1 + ".png"

	add_frames_from_spritesheet(anim0Frames, spritesheet0_path, 20, 11)
	add_frames_from_spritesheet(anim1Frames, spritesheet1_path, 25, 13)
	
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

var lerp_target:Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
		# sprites[i].play("default")
	
	#for sprite in sprites:
		#var mat:StandardMaterial3D = sprite.get_surface_override_material(0)
		#mat = mat.duplicate()
		#mat.albedo_color.a = 0
		#sprites.set_surface_override_material(0, mat)
		#mats.push_back(mat)
	bounce_in()
	lerp_target = global_position
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# rotate_y(delta)
	# rotate_x(delta)
	# print("hand " + str(hand))
	
		pass

func add_frames_from_spritesheet(sprite_frames: SpriteFrames, spritesheet_path: String, h_frames: int, v_frames: int):
	var spritesheet = load(spritesheet_path)
	if spritesheet:
		var frame_width = spritesheet.get_width() / h_frames
		var frame_height = spritesheet.get_height() / v_frames
		
		for y in range(v_frames):
			for x in range(h_frames):
				var atlas = AtlasTexture.new()
				atlas.atlas = spritesheet
				atlas.region = Rect2(x * frame_width, y * frame_height, frame_width, frame_height)
				sprite_frames.add_frame("default", atlas)
	else:
		print("An error occurred when trying to load the spritesheet: " + spritesheet_path)

var hand = null

# Replace with function body.
