extends Node2D

@export var nextRoom: PackedScene
@onready var door_sprite: AnimatedSprite2D = $StaticBody2D/AnimatedSprite2D
@onready var exit_area_collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var door_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D

var enemies_alive := 0
var door_opened := false

func _ready() -> void:
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
