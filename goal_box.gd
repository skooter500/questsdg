extends Area3D

@export var image:Texture 

func set_texture(mesh:MeshInstance3D):
	var mat:StandardMaterial3D = mesh.get_surface_override_material(0)
	mat = mat.duplicate()
	mat.albedo_texture = image
	mesh.set_surface_override_material(0, mat)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_texture($front)
	set_texture($back)
	set_texture($left)
	set_texture($right)
	set_texture($top)
	set_texture($bot)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(delta)
	pass
