extends Area3D

@export var image:Texture 

func set_texture(mesh:MeshInstance3D):
	var mat:StandardMaterial3D = mesh.get_surface_override_material(0)
	mat = mat.duplicate()
	mat.albedo_texture = image
	mesh.set_surface_override_material(0, mat)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_texture($scaler/front)
	set_texture($scaler/back)
	set_texture($scaler/left)
	set_texture($scaler/right)
	set_texture($scaler/top)
	set_texture($scaler/bot)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# rotate_y(delta)
	# rotate_x(delta)
	pass
