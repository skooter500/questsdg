extends Node3D

var ani_boxes = []
var goal_boxes = []

func spawn_box(i):
	var t = create_tween() \
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)		
	var box = goal_boxes[i]
	box.scale = Vector3.ZERO
	box.visible = true
	box.monitoring = true
	var a:AudioStreamPlayer3D = box.get_node("AudioStreamPlayer3D")
	a.pitch_scale = randf_range(0.9, 1.5)
	box.get_node("AudioStreamPlayer3D").play()
	var interval = 0.5
	t.tween_property(box, "scale", Vector3.ONE, interval)		

		
func spawn_boxes():
	for i in 17:
		spawn_box(i)
		await get_tree().create_timer(0.6).timeout
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	
	var cols = 6
	var gap = 0.3
	var row = 0
	var col = 0
	
	
	for child:Node3D in get_children():
		goal_boxes.push_back(child)
		child.visible = false
		child.position = Vector3(col * gap, row * gap, 0)
		col += 1
		if col == 6:
			col = 0
			row = row - 1 
	var i = 0
	for child:Node3D in $"../ani_goals".get_children():
		child.visible = false
		# child.get_node("AudioStreamPlayer3D").stream = sounds[i]
		ani_boxes.push_back(child)
		i = i + 1
	#var thread = Thread.new()
	#thread.start(load_ani_boxes.bind(0, 17))
	
	
				
	pass # Replace with function body.

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
