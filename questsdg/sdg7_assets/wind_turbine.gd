extends Node3D
signal activated(turbine: Node3D)

@export var min_speed := 1.0
@export var max_speed := 3.0
@export var boost_speed := 10.0
@export var particles_normal_speed_scale: float = 1.0
@export var particles_boost_speed_scale: float = 2.0


var base_speed: float = 0.0 # will be set on activation
var target_speed: float = 0.0
var current_speed: float = 0.0

var is_active: bool = false # latch: stays on after first interaction

@onready var blades := $Tower/Blades
@onready var wind_sound := $WindSound
@onready var activated_particles: GPUParticles3D = $ActivatedParticles

var hand: Node3D = null

func _ready() -> void:
	# Start OFF: no movement, particles off
	target_speed = 0.0
	current_speed = 0.0

	if activated_particles:
		activated_particles.emitting = false
		activated_particles.speed_scale = particles_normal_speed_scale

	if wind_sound:
		wind_sound.stream.loop = true
		wind_sound.volume_db = -10
		wind_sound.max_distance = 3.0
		wind_sound.unit_size = 1.0
		wind_sound.play()

func _process(delta: float) -> void:
	# Smooth speed change
	current_speed = lerp(current_speed, target_speed, delta * 3.0)

	# Rotate blades (only if spinning)
	if blades and current_speed > 0.0001:
		blades.rotate_x(current_speed * delta)

	# Tie pitch to speed for immersion
	if wind_sound:
		var pitch: float = clampf(max(current_speed, 0.0) / 2.0, 0.8, 1.5)
		wind_sound.pitch_scale = pitch

func _physics_process(_delta: float) -> void:
	if !is_active:
		target_speed = 0.0
		return

	if hand:
		target_speed = boost_speed
	else:
		target_speed = base_speed

	if activated_particles:
		activated_particles.speed_scale = particles_boost_speed_scale if hand else particles_normal_speed_scale


func _on_interact_area_area_entered(area: Area3D) -> void:
	if area.name.contains("hand"):
		hand = area.get_parent()

		# First time activation
		if !is_active:
			is_active = true
			base_speed = randf_range(min_speed, max_speed)  # random normal speed
			target_speed = base_speed

			if activated_particles:
				activated_particles.emitting = true
			
			activated.emit(self)

func _on_interact_area_area_exited(area: Area3D) -> void:
	if area.name.contains("hand"):
		hand = null
		# Particles stay on permanently once active
