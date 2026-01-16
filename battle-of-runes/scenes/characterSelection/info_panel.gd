extends Control

@onready var nombre: Label = $Panel/VBoxContainer/Nombre
@onready var desc: Label = $Panel/VBoxContainer/Descripcion

func show_info(n: String, d: String, pos: Vector2) -> void:
	global_position = pos
	nombre.text = n
	desc.text = d
	show()

func hide_info() -> void:
	hide()
