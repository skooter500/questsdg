extends Area3D

var fade_tween:Tween = null


@export var goal_num:int = 6
@export var videos:Array[VideoStream]
var players:Array[VideoStreamPlayer]

var vid_screens:Array[MeshInstance3D]

func get_all_mesh_instances() -> Array[MeshInstance3D]:
	# Built-in method - finds all MeshInstance3D children recursively
	var mesh_nodes = find_children("*", "MeshInstance3D", true, false)
	
	# Convert to typed array
	var typed_array: Array[MeshInstance3D] = []
	for node in mesh_nodes:
		typed_array.append(node as MeshInstance3D)
	
	return typed_array

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
	for video in videos:		
		var video_player:VideoStreamPlayer = VideoStreamPlayer.new()
		video_player.stream = video
		video_player.expand = false
		video_player.loop = true
		video_player.autoplay = true
		var svp = SubViewport.new()
		svp.size = video_player.get_video_texture().get_size()
		svp.add_child(video_player)
		
		players.push_back(video_player)
		video_player.play()
		video_player.loop = true
	var player_id = 0
	
	vid_screens = get_all_mesh_instances()
	for vid_screen in vid_screens:	
		var material = vid_screen.get_surface_override_material(0)
		material.albedo_texture = players[player_id].get_video_texture()
		material.emission_enabled = true
		material.emission_texture = players[player_id].get_video_texture()
		material.emission_energy = 1.0
		# Apply material to mesh
		vid_screen.set_surface_override_material(0, material)
		player_id = (player_id + 1) % players.size()
	
	
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
