extends CharacterBody2D
class_name Skeleton

enum State { WALK, ATTACK, DEATH }
var current_state = State.WALK

var max_health: int = 3
var health: int = max_health
var move_speed: float = 50.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $HitBox
@onready var attackbox: Area2D = $AttackHitBox
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer

var player: Node2D = null

func _ready():
	hitbox.connect("body_entered", self._on_HitBox_body_entered)
	attackbox.connect("body_entered", self._on_AttackBox_body_entered)
	player = get_tree().get_first_node_in_group("Player")
	attack_timer.wait_time = 1.0
	attack_timer.one_shot = true

	sprite.connect("frame_changed", Callable(self, "_on_sprite_frame_changed"))

func _physics_process(delta):
	match current_state:
		State.WALK:
			sprite.play("walk")
			follow_player()
			if player and position.distance_to(player.position) < 40 and attack_timer.is_stopped():
				current_state = State.ATTACK
				attack_timer.start()

		State.ATTACK:
			sprite.play("walk")  # usa la misma animación
			follow_player()
			if attack_timer.is_stopped():
				current_state = State.WALK

		State.DEATH:
			sprite.play("death")
			velocity = Vector2.ZERO

func follow_player():
	if not player: return
	var dist = position.distance_to(player.position)
	if dist > 40:
		var dir = (player.position - position).normalized()
		velocity = dir * move_speed
		move_and_slide()
		sprite.flip_h = player.position.x < position.x
	else:
		velocity = Vector2.ZERO

# Recibe daño (balas del jugador)
func _on_HitBox_body_entered(body: Node) -> void:
	if body.is_in_group("PlayerBullet"):
		take_damage(1)
		body.queue_free()

# Inflige daño al jugador
func _on_AttackBox_body_entered(body: Node) -> void:
	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(1)

func take_damage(amount: int):
	if current_state == State.DEATH:
		return
	health -= amount
	print("Skeleton recibió daño, salud actual:", health)
	if health <= 0:
		die()

func die():
	current_state = State.DEATH
	velocity = Vector2.ZERO
	print("Skeleton ha muerto")

	collision.call_deferred("set_disabled", true)
	hitbox.call_deferred("queue_free")
	attackbox.call_deferred("queue_free")

	sprite.play("death")

func _on_sprite_frame_changed():
	if current_state == State.DEATH and sprite.animation == "death":
		var total_frames = sprite.sprite_frames.get_frame_count("death")
		if sprite.frame == total_frames - 1:
			queue_free()
