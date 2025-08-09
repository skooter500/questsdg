extends Node3D

var ani_boxes = []

# var ani_scene = preload("res://goal_box_animated.tscn")

#func load_ani_box(goal):
	#print("Loading ani box: " + str(goal))
	#var ani_box = ani_scene.instantiate()
	#ani_box.goal_num = goal
	#ani_box.load_sprites()
	#ani_boxes.push_back(ani_box)
	#print("Completed: " + str(goal))
	#
#var thread
#
#func load_ani_boxes():
	#for i in 17:
		#load_ani_box(i + 1)
		
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	
	#thread = Thread.new()
	#thread.start(load_ani_boxes)		
	var cols = 6
	var gap = 0.3
	var row = 0
	var col = 0
	var interval = 0.3
	var t = create_tween() \
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)		
	for child:Node3D in get_children():
		child.scale = Vector3.ZERO
		child.position = Vector3(col * gap, row * gap, 0)
		t.tween_property(child, "scale", Vector3.ONE, interval)		
		col += 1
		if col == 6:
			col = 0
			row = row - 1 		
	pass # Replace with function body.

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
