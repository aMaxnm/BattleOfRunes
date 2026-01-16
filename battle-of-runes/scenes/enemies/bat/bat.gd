extends CharacterBody2D
class_name Bat

enum State { FLY, ATTACK, HURT, DEATH }
var current_state: State = State.FLY

@export var bullet_scene: PackedScene

var max_health: int = 1
var health: int = max_health
var move_speed: float = 80.0
var attack_distance: float = 200.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $HitBox
@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_marker: Marker2D = $Marker2D

var player: Node2D = null



func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

	hitbox.body_entered.connect(_on_hitbox_body_entered)
	sprite.frame_changed.connect(_on_sprite_frame_changed)

	shoot_timer.wait_time = 1.2
	shoot_timer.one_shot = true



func _physics_process(delta: float) -> void:
	match current_state:
		State.FLY:
			sprite.play("fly")
			follow_player()
			check_attack()

		State.ATTACK:
			sprite.play("attack")
			velocity = Vector2.ZERO

		State.HURT:
			sprite.play("hit")
			velocity = Vector2.ZERO

		State.DEATH:
			sprite.play("death")
			velocity = Vector2.ZERO

# --------------------------------------------------

func follow_player() -> void:
	if not player:
		return

	var dir := (player.global_position - global_position).normalized()
	velocity = dir * move_speed
	move_and_slide()

	sprite.flip_h = player.global_position.x < global_position.x



func check_attack() -> void:
	if not player or not shoot_timer.is_stopped():
		return

	var dist := global_position.distance_to(player.global_position)
	if dist <= attack_distance:
		current_state = State.ATTACK
		shoot()
		shoot_timer.start()



func shoot() -> void:
	if not bullet_scene or not player:
		return

	var bullet := bullet_scene.instantiate()
	bullet.global_position = shoot_marker.global_position
	bullet.direction = (player.global_position - shoot_marker.global_position).normalized()

	get_parent().add_child(bullet)



func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("PlayerBullet"):
		take_damage(1)
		body.queue_free()



func take_damage(amount: int) -> void:
	if current_state == State.DEATH:
		return

	health -= amount
	current_state = State.HURT

	if health <= 0:
		die()



func die() -> void:
	current_state = State.DEATH
	velocity = Vector2.ZERO

	collision.call_deferred("set_disabled", true)
	hitbox.call_deferred("queue_free")



func _on_sprite_frame_changed() -> void:
	if current_state == State.DEATH and sprite.animation == "death":
		var total_frames := sprite.sprite_frames.get_frame_count("death")
		if sprite.frame == total_frames - 1:
			queue_free()
