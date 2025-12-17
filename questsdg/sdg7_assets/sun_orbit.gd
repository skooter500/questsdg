extends Node3D

@export var orbit_radius: float = 6.0
@export var orbit_height: float = 4.0
@export var orbit_speed_deg_per_sec: float = 12.0
@export var start_angle_deg: float = 0.0

@onready var orbit_pivot: Node3D = $OrbitPivot
@onready var sun: Node3D = $OrbitPivot/Sun
@onready var sun_hum: AudioStreamPlayer3D = $OrbitPivot/Sun/SunHum

var _angle: float = 0.0

func _ready() -> void:
	_angle = deg_to_rad(start_angle_deg)

	# Put the Sun node on the orbit arm 
	sun.position = Vector3(orbit_radius, orbit_height, 0.0)

	# Make it easy for panels to find without NodePaths
	add_to_group("sun_rig")
	sun.add_to_group("sun_node")
	
	if sun_hum and sun_hum.stream:
		sun_hum.stream.loop = true
		sun_hum.volume_db = -14.0
		sun_hum.max_distance = 0.5
		sun_hum.unit_size = 1.0
		sun_hum.play()

func _process(delta: float) -> void:
	_angle += deg_to_rad(orbit_speed_deg_per_sec) * delta
	orbit_pivot.rotation.y = _angle
