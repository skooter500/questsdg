extends Node3D

@export var min_speed := 1.0
@export var max_speed := 3.0

var rotation_speed := 2.0
@onready var blades := $Tower/Blades

func _ready() -> void:
	# Pick a random speed per turbine when it spawns
	rotation_speed = randf_range(min_speed, max_speed)

func _process(delta: float) -> void:
	if blades:
		blades.rotate_x(rotation_speed * delta)
