extends CharacterBody2D
class_name SwordBase

@export var speed := 300.0

func _ready():
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	
func _physics_process(delta):
	move_and_slide()

func _on_area_2d_area_entered(area: Area2D) -> void:
	queue_free()

func _on_timer_timeout() -> void:
	queue_free()
