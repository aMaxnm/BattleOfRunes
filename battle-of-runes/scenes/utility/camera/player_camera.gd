extends Camera2D

@export var player: Player

func _process(delta: float) -> void:
	position = player.position
