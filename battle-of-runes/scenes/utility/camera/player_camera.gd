extends Camera2D

@export var player: Node2D

func set_player(p: Node2D) -> void:
	player = p

func _process(_delta: float) -> void:
	if player == null:
		return
	global_position = player.global_position
