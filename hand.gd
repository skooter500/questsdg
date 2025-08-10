class_name Hand

extends XRNode3D

@export var selected = false
@export var grabbed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_hand_pose_detector_pose_started(p_name: String) -> void:
	print(p_name + " started")
	if p_name == "ThumbsUp":
		selected = true
	if p_name == "Pinch":
		grabbed = true
	pass # Replace with function body.


func _on_hand_pose_detector_pose_ended(p_name: String) -> void:
	print(p_name + " ended")
	if p_name == "ThumbsUp":
		selected = false
	if p_name == "Pinch":
		grabbed = false
	pass # Replace with function body.
