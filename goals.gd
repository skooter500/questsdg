extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	var cols = 6
	var gap = 0.3
	var row = 0
	var col = 0
	for child:Node3D in get_children():
		child.position = Vector3(col * gap, row * gap, 0)
		col += 1
		if col == 6:
			col = 0
			row = row - 1 		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
