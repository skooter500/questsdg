extends Node3D

@export var min_speed := 1.0
@export var max_speed := 3.0
@export var boost_speed := 10.0

var base_speed: float
var target_speed: float
var current_speed: float

@onready var blades := $Tower/Blades
@onready var wind_sound := $WindSound

var hand: Node3D = null

func _ready() -> void:
	# Randomize each turbine speed so they look more varied 
	base_speed = randf_range(min_speed, max_speed)
	target_speed = base_speed
	current_speed = base_speed

	if wind_sound:
		wind_sound.stream.loop = true
		wind_sound.volume_db = -10
		wind_sound.max_distance = 3.0
		wind_sound.unit_size = 1.0
		wind_sound.play()


func _process(delta: float) -> void:
	# Smooth speed change
	current_speed = lerp(current_speed, target_speed, delta * 3.0)

	# Rotate blades
	if blades:
		blades.rotate_x(current_speed * delta)

	# Tie pitch to speed for immersion
	if wind_sound:
		var pitch: float = clampf(current_speed / 2.0, 0.8, 1.5)
		wind_sound.pitch_scale = pitch


func _physics_process(_delta: float) -> void:
	# Pinch interaction
	if hand:
		target_speed = boost_speed
	else:
		target_speed = base_speed


func _on_interact_area_area_entered(area: Area3D) -> void:
	if area.name.contains("hand"):
		hand = area.get_parent()


func _on_interact_area_area_exited(area: Area3D) -> void:
	if area.name.contains("hand"):
		hand = null
