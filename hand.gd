class_name Hand

extends XRNode3D

@export var selected = false
@export var grabbed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:	
	if the_box:
		if grabbed:
			var to_target = global_position - the_box.global_position
			the_box.apply_central_force(to_target)
	if not inside  && not grabbed:
		the_box = null
	
	pass


func _on_hand_pose_detector_pose_started(p_name: String) -> void:
	print(p_name + " started")
	if p_name == "ThumbsUp":
		selected = true
	if p_name == "Index Pinch":
		grabbed = true
	pass # Replace with function body.


func _on_hand_pose_detector_pose_ended(p_name: String) -> void:
	print(p_name + " ended")
	if p_name == "ThumbsUp":
		selected = false
	if p_name == "Index Pinch":
		grabbed = false
	pass # Replace with function body.

var the_box = null

func _on_right_hand_area_entered(area: Area3D) -> void:
	if area.is_in_group("ani_box"):
		the_box = area.get_parent()
		inside = true
	pass # Replace with function body.

var inside = false

func _on_right_hand_area_exited(area: Area3D) -> void:
	if area == the_box:
		inside = false
	pass # Replace with function body.
