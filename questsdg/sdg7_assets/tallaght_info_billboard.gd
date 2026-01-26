extends Node3D

@export var off_color: Color = Color(0.12, 0.12, 0.12)
@export var on_color: Color  = Color(0.15, 1.0, 0.4)
@export var emission_color: Color = Color(0.1, 0.8, 0.3)
@export var emission_energy: float = 1.2

@onready var cells: Array[MeshInstance3D] = [
	$Progress/Cell1,
	$Progress/Cell2,
	$Progress/Cell3,
]

@onready var progress_label: Label3D = $Progress/ProgressLabel

var _last_progress: int = -1

func set_progress(step: int, total: int = 3) -> void:
	var clamped_step: int = clampi(step, 0, cells.size())

	if progress_label:
		progress_label.text = "Hydroelectric System Setup: %d / %d" % [clamped_step, total]

	for i in range(cells.size()):
		var cell := cells[i]
		if cell == null:
			continue

		var mat := cell.get_active_material(0)
		if mat == null:
			var new_mat := StandardMaterial3D.new()
			new_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			cell.set_surface_override_material(0, new_mat)
			mat = new_mat

		if mat is StandardMaterial3D:
			var m := mat as StandardMaterial3D
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
