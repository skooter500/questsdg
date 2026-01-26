class_name Hand

extends XRNode3D

@export var selected = false
@export var grabbed := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HandPoseDetector.connect("pose_started", _on_hand_pose_detector_pose_started)
	$HandPoseDetector.connect("pose_ended", _on_hand_pose_detector_pose_ended)
	pass # Replace with function body.

var force = Vector3.ZERO
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:	
	
	pass


func _on_hand_pose_detector_pose_started(p_name: String) -> void:
	print(p_name + " started")
	if p_name == "ThumbsUp":
		selected = true
	if p_name == "Fist":
		grabbed = true
	pass # Replace with function body.


func _on_hand_pose_detector_pose_ended(p_name: String) -> void:
	print(p_name + " ended")
	if p_name == "ThumbsUp":
		selected = false
	if p_name == "Fist":
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
	if area.get_parent() == the_box:
		inside = false
	pass # Replace with function body.
	
