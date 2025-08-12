extends Node3D

var ani_boxes = []
var goal_boxes = []

@export var sounds:Array[AudioStream] 

var ani_box_scene = preload("res://goal_box_animated.tscn")

func spawn_box(i):
	var t = create_tween() \
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)		
	var box = goal_boxes[i]
	box.scale = Vector3.ZERO
	var a:AudioStreamPlayer3D = box.get_node("AudioStreamPlayer3D")
	a.pitch_scale = randf_range(0.5, 1.5)
	box.get_node("AudioStreamPlayer3D").play()
	var interval = 0.3
	t.tween_property(box, "scale", Vector3.ONE, interval)		
	

func load_ani_boxes(start, end):
	for i in range(start, end):
		print("Loading " + str(i))
		var ani_box = ani_box_scene.instantiate()
		ani_box.goal_num1 = i + 1
		ani_box.load_frames()
		
		if i < sounds.size():
			var sound:AudioStreamPlayer3D = AudioStreamPlayer3D.new()
			sound.visible = true
			ani_box.theme_sound = sound
			ani_box.add_child(sound)
			sound.stream = sounds[i]
			sound.position = Vector3.ZERO
			sound.max_distance = 1
			# sound.volume_linear = 0.005
			sound.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
			sound.autoplay = true
		ani_boxes.push_back(ani_box)
		print("Loaded " + str(i))
		call_deferred("spawn_box", i)
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	
	var cols = 6
	var gap = 0.3
	var row = 0
	var col = 0
	
	
	for child:Node3D in get_children():
		goal_boxes.push_back(child)
		child.scale = Vector3.ZERO
		child.position = Vector3(col * gap, row * gap, 0)
		col += 1
		if col == 6:
			col = 0
			row = row - 1 
	
	var thread = Thread.new()
	thread.start(load_ani_boxes.bind(0, 17))
	
	
				
	pass # Replace with function body.

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
