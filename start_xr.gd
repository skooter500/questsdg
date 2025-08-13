extends Node

var xr_interface: XRInterface
@onready var environment:Environment = $"../WorldEnvironment".environment

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
	# get_viewport().transparent_bg = true
	# environment.background_mode = Environment.BG_CLEAR_COLOR
	# environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	


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
<<<<<<< HEAD
		
=======
		#
		#
	##Tweens for the floors of each cammpus to change color
>>>>>>> last_day
	#var blanchMat = $Blanchardstown/BlanchardstownFloor.get_surface_override_material(0)
	#var blanchTween = get_tree().create_tween()
	#blanchTween.tween_property(blanchMat, "albedo_color", Color(0.158, 0.298, 0.074), 20).set_trans(Tween.TRANS_QUAD)
	#
	#var tallaghtMat = $Tallaght/TallaghtFloor.get_surface_override_material(0)
	#var tallaghtTween = get_tree().create_tween()
	#tallaghtTween.tween_property(tallaghtMat, "albedo_color", Color(0.158, 0.298, 0.074), 20).set_trans(Tween.TRANS_QUAD)
	#
	#var grangeMat = $Grangegorman/GrangegormanFloor.get_surface_override_material(0)
	#var grangeTween = get_tree().create_tween()
	#grangeTween.tween_property(grangeMat, "albedo_color", Color(0.158, 0.298, 0.074), 20).set_trans(Tween.TRANS_QUAD)
	#
<<<<<<< HEAD
=======
	#var boltonMat = $Bolton/BoltonStreetFloor.get_surface_override_material(0)
	#var boltonTween = get_tree().create_tween()
	#boltonTween.tween_property(boltonMat, "albedo_color", Color(0.158, 0.298, 0.074), 20).set_trans(Tween.TRANS_QUAD)
	#
	##Tweens for the libraries and geothermal building to change color
>>>>>>> last_day
	#var tallaghtLibMat = $Tallaght/TallaghtLibrary.get_surface_override_material(0)
	#var tallaghtLibTween = get_tree().create_tween()
	#tallaghtLibTween.tween_property(tallaghtLibMat, "albedo_color", Color(0.78, 0.663, 0.235), 20).set_trans(Tween.TRANS_QUAD)
	#
	#var blanchLibMat = $Blanchardstown/BlanchardstownLibrary.get_surface_override_material(0)
	#var blanchLibTween = get_tree().create_tween()
	#blanchLibTween.tween_property(blanchLibMat, "albedo_color", Color(0.78, 0.663, 0.235), 20).set_trans(Tween.TRANS_QUAD)
<<<<<<< HEAD
	
	#$Blanchardstown/Trees/Tree/AnimationPlayer.play("Tree_Growth")
	#$Blanchardstown/Trees/Tree2/AnimationPlayer.play("Tree_Growth")
	#$Blanchardstown/Trees/Tree3/AnimationPlayer.play("Tree_Growth")
	#$Blanchardstown/Trees/Tree4/AnimationPlayer.play("Tree_Growth")
	#$Blanchardstown/Trees/Tree5/AnimationPlayer.play("Tree_Growth")
	#$Grangegorman/Trees/Tree/AnimationPlayer.play("Tree_Growth")
	#$Grangegorman/Trees/Tree2/AnimationPlayer.play("Tree_Growth")
	#$Grangegorman/Trees/Tree3/AnimationPlayer.play("Tree_Growth")
	#$Tallaght/Trees/Tree/AnimationPlayer.play("Tree_Growth")
	#$Tallaght/Trees/Tree2/AnimationPlayer.play("Tree_Growth")
	#$Tallaght/Trees/Tree3/AnimationPlayer.play("Tree_Growth")
	#
	#$Grangegorman/Crane/AnimationPlayer.play("Crane_Growth")
	#$Grangegorman/Crane/AnimationPlayer.queue("Crane_Rotation")
	#
=======
	#
	#var grangeGeoMat = $Grangegorman/GrangegormanGeothermal.get_surface_override_material(0)
	#var grangeGeoTween = get_tree().create_tween()
	#grangeGeoTween.tween_property(grangeGeoMat, "albedo_color", Color(0.577, 0.159, 0.128), 20).set_trans(Tween.TRANS_QUAD)
	#
	#
	##Tweens for changing the building colors on each campus
	#var blanchBuildMat = $Blanchardstown/BlanchardstownBuildings.get_surface_override_material(0)
	#var blanchBuildTween = get_tree().create_tween()
	#blanchBuildTween.tween_property(blanchBuildMat, "albedo_color", Color(0.49, 0.337, 0.22), 20).set_trans(Tween.TRANS_QUAD)
	#
	#var tallaghtBuildMat = $Tallaght/TallaghtBuildings.get_surface_override_material(0)
	#var tallaghtBuildTween = get_tree().create_tween()
	#tallaghtBuildTween.tween_property(tallaghtBuildMat, "albedo_color", Color(0.49, 0.337, 0.22), 20).set_trans(Tween.TRANS_QUAD)
	#
	#var grangeBuildMat = $Grangegorman/GrangegormanBuildings.get_surface_override_material(0)
	#var grangeBuildTween = get_tree().create_tween()
	#grangeBuildTween.tween_property(grangeBuildMat, "albedo_color", Color(0.49, 0.337, 0.22), 20).set_trans(Tween.TRANS_QUAD)
	#
	#var boltonBuildMat0 = $Bolton/BoltonStreetCampus.get_surface_override_material(0)
	#var boltonBuildMat1 = $Bolton/BoltonStreetCampus.get_surface_override_material(1)
	#var boltonBuildMat2 = $Bolton/BoltonStreetCampus.get_surface_override_material(2)
	#var boltonBuildTween0 = get_tree().create_tween()
	#var boltonBuildTween1 = get_tree().create_tween()
	#var boltonBuildTween2 = get_tree().create_tween()
	#boltonBuildTween0.tween_property(boltonBuildMat0, "albedo_color", Color(0.49, 0.337, 0.22), 20).set_trans(Tween.TRANS_QUAD)
	#boltonBuildTween1.tween_property(boltonBuildMat1, "albedo_color", Color(0.49, 0.337, 0.22), 20).set_trans(Tween.TRANS_QUAD)
	#boltonBuildTween2.tween_property(boltonBuildMat2, "albedo_color", Color(0.49, 0.337, 0.22), 20).set_trans(Tween.TRANS_QUAD)
	#
	#
#
	#
	##Book Animation Players
>>>>>>> last_day
	#$Tallaght/Book/AnimationPlayer.play("Book_Rise")
	#$Tallaght/Book/AnimationPlayer.queue("Book Rotation")
	#
	#$Blanchardstown/Book/AnimationPlayer.play("Book_Rise")
	#$Blanchardstown/Book/AnimationPlayer.queue("Book Rotation")
	#
<<<<<<< HEAD
	#$Grangegorman/UNFlag/AnimationPlayer.play("Flag_Wave")
	#
	
=======
	##Flag Animation Player
	#$Grangegorman/UNFlag/AnimationPlayer.play("Flag_Wave")
	#
	#
>>>>>>> last_day
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _on_hand_pose_detector_pose_ended(p_name: String) -> void:
	pass # Replace with function body.
