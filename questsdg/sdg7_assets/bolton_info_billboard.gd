extends Node3D

@export var off_color: Color = Color(0.12, 0.12, 0.12)
@export var on_color: Color  = Color(0.15, 1.0, 0.4)
@export var emission_color: Color = Color(0.1, 0.8, 0.3)
@export var emission_energy: float = 1.2

@onready var cells: Array[MeshInstance3D] = [
	$Progress/Cell1,
	$Progress/Cell2,
	$Progress/Cell3,
	$Progress/Cell4
]

@onready var progress_label: Label3D = $Progress/ProgressLabel

var _last_progress: int = -1

func _ready() -> void:
	_make_cell_materials_unique()
	set_progress(0, 4)

func _make_cell_materials_unique() -> void:
	for cell in cells:
		if cell == null:
			continue
		var mat := cell.get_active_material(0)
		if mat:
			var dup := mat.duplicate()
			dup.resource_local_to_scene = true
			cell.set_surface_override_material(0, dup)
		else:
			var m := StandardMaterial3D.new()
			m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			cell.set_surface_override_material(0, m)

func set_progress(step: int, total: int) -> void:
	var clamped_step := clampi(step, 0, total)

	# Update label (match your billboard text)
	if progress_label:
		progress_label.text = "Renewable Sources Online: %d / %d" % [clamped_step, total]

	# Light up cells
	for i in range(cells.size()):
		var cell := cells[i]
		if cell == null:
			continue

		var m := cell.get_active_material(0)
		if m == null:
			continue

		# Make sure it’s a unique material per cell
		if not m.resource_local_to_scene:
			m = m.duplicate()
			m.resource_local_to_scene = true
			cell.set_surface_override_material(0, m)

		if i < clamped_step:
			m.albedo_color = on_color
			m.emission = emission_color
			m.emission_energy = emission_energy

			if clamped_step != _last_progress and i == clamped_step - 1:
				_pulse(cell)
		else:
			m.albedo_color = off_color
			m.emission_energy = 0.0

	_last_progress = clamped_step

func _pulse(n: Node3D) -> void:
	n.scale = Vector3.ONE
	var t := create_tween()
	t.tween_property(n, "scale", Vector3.ONE * 1.15, 0.12)
	t.tween_property(n, "scale", Vector3.ONE, 0.18)
