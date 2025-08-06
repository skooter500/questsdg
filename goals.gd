extends Node3D
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
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
func _process(delta: float) -> void:
	pass
