extends CharacterBody2D
class_name ArrowBase

@export var speed := 1200.0

func _ready():
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	
func _physics_process(delta):
	move_and_slide()

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	queue_free()
