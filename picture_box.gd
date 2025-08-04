extends MeshInstance3D

func _ready():
	fix_box_mesh_uvs()

func fix_box_mesh_uvs():
	# Make sure we have a BoxMesh
	if not mesh is BoxMesh:
		print("This script requires a BoxMesh!")
		return
	
	var box_mesh = mesh as BoxMesh
	
	# Get the surface data from the BoxMesh
	var arrays = box_mesh.surface_get_arrays(0)
	
	# Extract the UV array
	var uvs = arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array
	
	# Fix UVs - each face should get proper 0,0 to 1,1 mapping
	# BoxMesh has 24 vertices (4 per face * 6 faces)
	var new_uvs = PackedVector2Array()
	
	# For each face (6 faces total), set proper UV coordinates
	for face in range(6):
		var base_index = face * 4
		# Each face gets these UV coordinates:
		new_uvs.append(Vector2(0, 1))  # bottom-left
		new_uvs.append(Vector2(1, 1))  # bottom-right  
		new_uvs.append(Vector2(1, 0))  # top-right
		new_uvs.append(Vector2(0, 0))  # top-left
	
	# Update the UV array
	arrays[Mesh.ARRAY_TEX_UV] = new_uvs
	
	# Create new ArrayMesh with fixed UVs
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	# Replace the mesh
	mesh = array_mesh
