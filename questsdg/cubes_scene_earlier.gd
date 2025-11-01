extends Node3D

var player:TaloPlayer

func _on_identified(player: TaloPlayer) -> void:
	self.player = player 
	Talo.events.track("Player is identified!", {
	})
	Talo.events.flush()
	
func _ready() -> void:
	
	Talo.players.identify("Quest SDG", Talo.players.generate_identifier())
	Talo.players.identified.connect(_on_identified)
	
