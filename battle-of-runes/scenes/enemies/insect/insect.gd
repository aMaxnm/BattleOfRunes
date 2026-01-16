extends CharacterBody2D
class_name Insect

enum State { WALK, ATTACK, HURT, DEATH }
var current_state: State = State.WALK   # arranca caminando

var max_health: int = 8
var health: int = max_health
var move_speed: float = 70.0
var attack_distance: float = 40.0   # rango para ataque cuerpo a cuerpo

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var attack_timer: Timer = $Timer
@onready var hitbox: Area2D = $HitBox
@onready var attackbox: Area2D = $AttackHitBox

var player: Node2D = null

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	attack_timer.wait_time = 1.0
	attack_timer.one_shot = true
	sprite.connect("frame_changed", Callable(self, "_on_sprite_frame_changed"))
	call_deferred("_find_player")

func _find_player():
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta):
	match current_state:
		State.WALK:
			sprite.play("walk")
			follow_player()
			if player and position.distance_to(player.position) < attack_distance and attack_timer.is_stopped():
				current_state = State.ATTACK
				attack_timer.start()

		State.ATTACK:
			sprite.play("attack")
			velocity = Vector2.ZERO
			if attack_timer.is_stopped():
				current_state = State.WALK

		State.HURT:
			sprite.play("hurt")
			velocity = Vector2.ZERO
			if health > 0:
				current_state = State.WALK

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

func take_damage(amount: int):
	if current_state == State.DEATH:
		return
	health -= amount
	print("Orc recibió daño, salud actual:", health)
	if health > 0:
		current_state = State.HURT
	else:
		die()

func die():
	current_state = State.DEATH
	velocity = Vector2.ZERO

	collision.call_deferred("set_disabled", true)
	hitbox.call_deferred("set_monitoring", false)
	attackbox.call_deferred("set_monitoring", false)

	sprite.play("hit")

	# Avisar a la room UNA SOLA VEZ
	get_tree().call_group("room", "enemy_died")

func _on_sprite_frame_changed():
	if current_state == State.DEATH and sprite.animation == "hit":
		var total_frames = sprite.sprite_frames.get_frame_count("hit")
		if sprite.frame == total_frames - 1:
			queue_free()


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("PlayerBullet"):
		take_damage(1)
		body.queue_free() # opcional: destruir la bala al impactar


func _on_attack_hit_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		die()
