extends Area2D
class_name BatBullet

var speed: float = 300.0
var direction: Vector2 = Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var life_timer: Timer = $Timer

# --------------------------------------------------

func _ready() -> void:
	life_timer.wait_time = 2.0
	life_timer.one_shot = true
	life_timer.timeout.connect(queue_free)
	life_timer.start()

	body_entered.connect(_on_body_entered)

	sprite.play("fly")



func _process(delta: float) -> void:
	global_position += direction * speed * delta



func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(1)
		queue_free()
