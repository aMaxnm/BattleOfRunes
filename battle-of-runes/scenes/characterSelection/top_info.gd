extends Control

@onready var label: Label = $Panel/TextureRect/Label

var _tween: Tween
var _x_target := 300.0

func set_label_x(x: float) -> void:
	_x_target = x
	label.position.x = x

func set_text(text: String) -> void:
	if label.text == text:
		return

	if _tween and _tween.is_running():
		_tween.kill()

	label.text = text
	label.position.x = _x_target
	label.scale = Vector2(0.92, 0.92)
	label.modulate.a = 0.0

	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(label, "modulate:a", 1.0, 0.10)
	_tween.tween_property(label, "scale", Vector2(1.06, 1.06), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	_tween.set_parallel(false)
	_tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
