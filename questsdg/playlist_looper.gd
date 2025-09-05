extends Node3D

@export var sounds:Array[AudioStream]

@export var auto_play:bool = false 

var i:int = 0

@onready var player = $AudioStreamPlayer3D


func rewind():
	i = 0
	play()
	
func stop():
	player.stop()

func next():
	i = (i + 1) % sounds.size()
	play()
	pass
	
func _ready() -> void:
	player.finished.connect(next)
	if auto_play:
		play()
		

func play():
	player.stream = sounds[i]
	player.play()
	
	
