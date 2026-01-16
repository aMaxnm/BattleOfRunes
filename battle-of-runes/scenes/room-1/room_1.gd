extends Node2D

@onready var spawn_point: Node2D = $SpawnPoint
@onready var cam: Camera2D = $PlayerCamera

@export var mage_scene: PackedScene
@export var archer_scene: PackedScene
@export var paladin_scene: PackedScene

func _ready() -> void:
	var key := ""
	if has_node("/root/game_manager"):
		key = get_node("/root/game_manager").selected_character

	var scene_to_spawn: PackedScene = mage_scene
	match key:
		"mageCharacter":
			scene_to_spawn = mage_scene
		"archerCharacter":
			scene_to_spawn = archer_scene
		"paladinCharacter":
			scene_to_spawn = paladin_scene

	if scene_to_spawn == null:
		return

	var player := scene_to_spawn.instantiate() as Node2D
	add_child(player)
	player.global_position = spawn_point.global_position

	if cam and cam.has_method("set_player"):
		cam.call("set_player", player)
	if has_node("/root/game_manager"):
		get_node("/root/game_manager").pause_enabled = true
	cam.make_current()
