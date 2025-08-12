extends XRCamera3D

var distance_in_front = -1

func _ready() -> void:
	await get_tree().process_frame
	var y = global_position.y
	print("Head pos" + str(global_position))
	var in_front = global_position + (global_basis.z * distance_in_front)
	in_front.y = y
	var goals  = $"../../goals"  
	
	
	goals.global_position = in_front
	
	var y_rotation = global_basis.get_euler().y
	goals.global_basis = Basis(Vector3.UP, y_rotation + PI)
	
	
	
	
	
	
