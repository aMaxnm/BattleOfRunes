extends CharacterBody2D
class_name Player
@onready var sprite: Sprite2D = $Sprite2D
@onready var arm_pivot = $ArmPivot
@onready var arm_sprite = $ArmPivot/Arm
@onready var marker = $ArmPivot/Marker2D
@export var move_speed = 100.0
@onready var shoot_timer: Timer = $Timer
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var arm_position
var facing_right := true
var can_shoot = true
var screen_size

func _ready() -> void:
	screen_size = get_viewport_rect()

func _process(delta: float) -> void:
	update_facing_by_mouse()
	aim_arms()

func _physics_process(delta: float) -> void:
	handle_movement()

func handle_movement():
	var move_input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_speed * move_input
	if not(velocity.x == 0) or not(velocity.y == 0):
		anim_player.play("run")
	else:
		anim_player.play("idle")
	move_and_slide()

func update_facing_by_mouse() -> void:
	var mouse_x := get_global_mouse_position().x
	var self_x := global_position.x
	var face_left := mouse_x < self_x
	sprite.flip_h = face_left
	arm_sprite.flip_v = face_left

func aim_arms() -> void:
	var mouse_pos := get_global_mouse_position()
	var dir = mouse_pos - arm_pivot.global_position
	arm_pivot.rotation = dir.angle()
	
	if Input.is_action_pressed("shoot") and can_shoot:
		can_shoot = false
		#BulletManager.create_player_bullet(left_arm_pivot.rotation, left_marker.global_position)
		#BulletManager.create_player_bullet(right_arm_pivot.rotation, right_marker.global_position)
		shoot_timer.start()

func _on_timer_timeout() -> void:
	can_shoot = true
