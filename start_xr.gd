extends Node3D

var xr_interface: XRInterface
@onready var environment:Environment = $WorldEnvironment.environment

func enable_passthrough() -> bool:
	if xr_interface and xr_interface.is_passthrough_supported():		
		return xr_interface.start_passthrough()
	else:
		var modes = xr_interface.get_supported_environment_blend_modes()
		if xr_interface.XR_ENV_BLEND_MODE_ALPHA_BLEND in modes:
			xr_interface.set_environment_blend_mode(xr_interface.XR_ENV_BLEND_MODE_ALPHA_BLEND)
			return true
		else:
			return false
	get_viewport().transparent_bg = true
	environment.background_mode = Environment.BG_CLEAR_COLOR
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$Grass/AnimationPlayer.play("grass_growing")
	#$Crane/AnimationPlayer.play("Crane_Rotation")
	#$Book/AnimationPlayer.play("Book_Rise")
	#$Book/AnimationPlayer.queue("Book Rotation")
	#$Trees/Tree/AnimationPlayer.play("Tree_Growth")
	#$Trees/Tree2/AnimationPlayer.play("Tree_Growth")
	#$Trees/Tree3/AnimationPlayer.play("Tree_Growth")
	#$UNFlag/AnimationPlayer.play("Flag_Wave")
	#$Scales/AnimationPlayer.play("Scale_Growth")
	#
	#await get_tree().create_timer(3.0).timeout
	#var my_scene = load("res://Cloud.tscn")
	#var instance = my_scene.instantiate()
	#add_child(instance)
	#instance.position = Vector3(2.628, 1.5, -0.314)
	#var anim_player = instance.get_node("AnimationPlayer")
	#anim_player.play("Cloud_Movement")
	#
	#await get_tree().create_timer(5.0).timeout
	#var rain_particles = instance.get_node("RainParticles")
	#rain_particles.emitting = true
	
	

	xr_interface = XRServer.primary_interface	
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialised successfully")

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
		enable_passthrough()	
		
	var blanchMat = $Blanchardstown/BlanchardstownFloor.get_surface_override_material(0)
	var blanchTween = get_tree().create_tween()
	blanchTween.tween_property(blanchMat, "albedo_color", Color(0.158, 0.298, 0.074), 20).set_trans(Tween.TRANS_QUAD)
	
	var tallaghtMat = $Tallaght/TallaghtFloor.get_surface_override_material(0)
	var tallaghtTween = get_tree().create_tween()
	tallaghtTween.tween_property(tallaghtMat, "albedo_color", Color(0.158, 0.298, 0.074), 20).set_trans(Tween.TRANS_QUAD)
	
	var grangeMat = $Grangegorman/GrangegormanFloor.get_surface_override_material(0)
	var grangeTween = get_tree().create_tween()
	grangeTween.tween_property(grangeMat, "albedo_color", Color(0.158, 0.298, 0.074), 20).set_trans(Tween.TRANS_QUAD)
	
	$Blanchardstown/Trees/Tree/AnimationPlayer.play("Tree_Growth")
	$Blanchardstown/Trees/Tree2/AnimationPlayer.play("Tree_Growth")
	$Blanchardstown/Trees/Tree3/AnimationPlayer.play("Tree_Growth")
	$Blanchardstown/Trees/Tree4/AnimationPlayer.play("Tree_Growth")
	$Blanchardstown/Trees/Tree5/AnimationPlayer.play("Tree_Growth")
	$Grangegorman/Trees/Tree/AnimationPlayer.play("Tree_Growth")
	$Grangegorman/Trees/Tree2/AnimationPlayer.play("Tree_Growth")
	$Grangegorman/Trees/Tree3/AnimationPlayer.play("Tree_Growth")
	$Tallaght/Trees/Tree/AnimationPlayer.play("Tree_Growth")
	$Tallaght/Trees/Tree2/AnimationPlayer.play("Tree_Growth")
	$Tallaght/Trees/Tree3/AnimationPlayer.play("Tree_Growth")
	
	$Grangegorman/Crane/AnimationPlayer.play("Crane_Growth")
	$Grangegorman/Crane/AnimationPlayer.queue("Crane_Rotation")
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
