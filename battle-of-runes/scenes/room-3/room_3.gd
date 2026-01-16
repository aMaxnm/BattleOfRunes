extends Node2D

@export var mage_scene: PackedScene
@export var archer_scene: PackedScene
@export var paladin_scene: PackedScene
@onready var spawn_point: Node2D = $SpawnPoint
@onready var cam: Camera2D = $PlayerCamera
var enemies_alive := 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
# Desactivar salida

	# Instanciar jugador según selección
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
	if has_node("/root/game_manager"):
		get_node("/root/game_manager").pause_enabled = true
	var player := scene_to_spawn.instantiate() as Node2D
	add_child(player)
	player.global_position = spawn_point.global_position
	player.add_to_group("Player")

	if cam and cam.has_method("set_player"):
		cam.call("set_player", player)
	cam.make_current()

	# Contar enemigos al inicio
	var enemies := get_tree().get_nodes_in_group("enemies")
	enemies_alive = 0
	for e in enemies:
		if e.is_inside_tree():
			enemies_alive += 1
		print("Enemigos activos en room2:", enemies_alive)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
