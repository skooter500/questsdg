extends Area3D

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
		$selected_sound.play()
			# Optional: Hide the mesh when fade completes
		# fade_tween.finished.connect(make_invisible)

func load_frames():
	anim0Frames = SpriteFrames.new()
	anim1Frames = SpriteFrames.new()
	# anim0Frames.add_animation("default")
	# anim1Frames.add_animation("default")

	var path0 = "res://goals/Goal-" + str(goal_num1) + "/Goal " + str(goal_num1) + "/" + str(goal_num1) + "_SDG_MakeEveryDayCount_Gifs_GDU_frames/"
	var path1 = "res://goals/Goal-" + str(goal_num1) + "/Goal " + str(goal_num1) + "/E_GIF_" + "%02d" % goal_num1 + "_frames/"

	add_frames_from_path(anim0Frames, path0)
	add_frames_from_path(anim1Frames, path1)
	
	sprites.push_back($scaler/front)
	sprites.push_back($scaler/bott)
	sprites.push_back($scaler/left)
	sprites.push_back($scaler/top)
	sprites.push_back($scaler/back)
	sprites.push_back($scaler/right)
	
	for i in range(sprites.size()):
		if i == 2 or i == 5: # left and right faces
			sprites[i].sprite_frames = anim1Frames
		else:
			sprites[i].sprite_frames = anim0Frames


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
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# rotate_y(delta)
	# rotate_x(delta)
	pass

func add_frames_from_path(sprite_frames: SpriteFrames, path: String):
	var dir = DirAccess.open(path)
	if dir:
		var files = dir.get_files()
		for file_name in files:
			if file_name.ends_with(".png"):
				var texture = load(path + file_name)
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# print(file_name)
			if file_name.ends_with('.png.import') :
				file_name = file_name.left(len(file_name) - len('.import'))
				var texture = load(path + "/" + file_name)
				sprite_frames.add_frame("default", texture)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path: " + path)
