extends Area2D
class_name BatBullet

var speed: float = 100.0
var direction: Vector2 = Vector2.ZERO   # se asigna al disparar

func _process(delta: float) -> void:
	# movimiento recto en la dirección calculada al disparar
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	# Solo afecta al Player
	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(1)
		queue_free()
	# Si choca con cualquier otra cosa que no sea Enemy, se destruye

func _on_VisibilityNotifier2D_screen_exited() -> void:
	# cuando la bala sale de la pantalla, se destruye
	queue_free()
