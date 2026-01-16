extends CharacterBody2D
class_name Bat

enum State { FLY, ATTACK, HURT, DEATH }
var current_state: State = State.FLY

var max_health: int = 3
var health: int = max_health
var move_speed: float = 80.0
var attack_distance: float = 100.0

@export var bullet_scene: PackedScene

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $HitBox
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_marker: Marker2D = $Marker2D

var player: Node2D = null
var has_reported_death := false   #evita avisar dos veces a la room


func _ready() -> void:
	# IMPORTANTE: usa el mismo nombre de grupo siempre
	player = get_tree().get_first_node_in_group("Player")

	shoot_timer.wait_time = 1.2
	shoot_timer.one_shot = false
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()

	sprite.frame_changed.connect(_on_sprite_frame_changed)

	shoot_timer.wait_time = 1.2
	shoot_timer.one_shot = true


func _physics_process(delta):

	match current_state:
		State.FLY:
			sprite.play("fly")
			follow_player()
			if player and position.distance_to(player.position) < attack_distance:
				current_state = State.ATTACK

		State.ATTACK:
			sprite.play("attack")
			velocity = Vector2.ZERO
			if player and position.distance_to(player.position) > attack_distance:
				current_state = State.FLY

		State.HURT:
			sprite.play("hurt")
			velocity = Vector2.ZERO
			if health > 0:
				current_state = State.FLY

		State.DEATH:
			sprite.play("death")
			velocity = Vector2.ZERO

func follow_player():
	if not player: return
	var dist = position.distance_to(player.position)
	if dist > attack_distance:
		var dir = (player.position - position).normalized()
		velocity = dir * move_speed
		move_and_slide()   # en Godot 4 usa velocity internamente
		sprite.flip_h = player.position.x < position.x
	else:
		velocity = Vector2.ZERO
		move_and_slide()

func _on_shoot_timer_timeout():
	if current_state == State.ATTACK and player:
		shoot()


func shoot():
	if not bullet_scene or not player:
		return
	var bullet = bullet_scene.instantiate()
	bullet.global_position = shoot_marker.global_position
	bullet.direction = (player.global_position - shoot_marker.global_position).normalized()
	get_parent().add_child(bullet)


func _on_HitBox_body_entered(body: Node) -> void:
	if body.is_in_group("PlayerBullet"):
		take_damage(1)
		body.queue_free()

func take_damage(amount: int):
	if current_state == State.DEATH:
		return
	health -= amount
	if health > 0:
		current_state = State.HURT
	else:
		die()

func die() -> void:
	if has_reported_death:
		return
	has_reported_death = true
	current_state = State.DEATH
	velocity = Vector2.ZERO
	# Desactivar colisiones
	collision.call_deferred("set_disabled", true)
	hitbox.call_deferred("set_monitoring", false)
	# Avisar a la room
	get_tree().call_group("room", "enemy_died")

func _on_sprite_frame_changed() -> void:
	if current_state == State.DEATH and sprite.animation == "death":
		var total_frames = sprite.sprite_frames.get_frame_count("death")
		if sprite.frame == total_frames - 1:
			queue_free()
