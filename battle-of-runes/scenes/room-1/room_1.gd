extends Node2D


@export var nextRoom: PackedScene
@onready var door_sprite: AnimatedSprite2D = $StaticBody2D/AnimatedSprite2D
@onready var exit_area_collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var door_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var spawn_point: Node2D = $SpawnPoint
@onready var cam: Camera2D = $PlayerCamera

var enemies_alive := 0
var door_opened := false

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

	cam.make_current()
	# Desactivar salida
	exit_area_collision.disabled = true

	# Contar enemigos al inicio
	enemies_alive = get_tree().get_nodes_in_group("enemies").size()


func changeScene():
	get_tree().change_scene_to_packed(nextRoom)

func enemy_died():
	enemies_alive -= 1
	if enemies_alive <= 0 and not door_opened:
		door_opened = true
		open_door()

func open_door():
	door_sprite.play("open")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Cambio")
		changeScene()

func _on_animated_sprite_2d_animation_finished() -> void:
	if door_sprite.animation == "open":
		exit_area_collision.disabled = false
		door_collision.disabled = true
