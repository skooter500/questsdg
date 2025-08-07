extends MeshInstance3D

func _process(delta):
	var material := get_active_material(0)
	if material is ShaderMaterial:
		material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
