extends CharacterBody2D
class_name Skeleton

enum State { WALK, ATTACK, DEATH }
var current_state: State = State.WALK

var max_health: int = 3
var health: int = max_health
var move_speed: float = 12.0
var attack_distance: float = 40.0   # rango para ataque cuerpo a cuerpo

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var attack_timer: Timer = $Timer

var player: Node2D = null

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	attack_timer.wait_time = 1.0
	attack_timer.one_shot = true
	sprite.frame_changed.connect(_on_sprite_frame_changed)

	# 🔹 Volteo horizontal por defecto


func _physics_process(delta):
	match current_state:
		State.WALK:
			sprite.play("walk")
			follow_player()
			if player and position.distance_to(player.position) < attack_distance and attack_timer.is_stopped():
				current_state = State.ATTACK
				attack_timer.start()

		State.ATTACK:
			sprite.play("attack")   # si no tienes animación de ataque, puedes usar "walk"
			velocity = Vector2.ZERO
			if attack_timer.is_stopped():
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

func die():
	current_state = State.DEATH
	velocity = Vector2.ZERO
	collision.call_deferred("set_disabled", true)
	sprite.play("death")

func _on_sprite_frame_changed():
	if current_state == State.DEATH and sprite.animation == "death":
		var total_frames = sprite.sprite_frames.get_frame_count("death")
		if sprite.frame == total_frames - 1:
			queue_free()
