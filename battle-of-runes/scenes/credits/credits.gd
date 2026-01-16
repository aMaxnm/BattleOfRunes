extends CanvasLayer

@onready var panel: Control = $Panel
@onready var parchment: TextureRect = $Panel/TextureRect
@onready var root_margin: MarginContainer = $Panel/MarginContainer
@onready var root_vbox: VBoxContainer = $Panel/MarginContainer/VBoxContainer

@onready var back_btn: TextureButton = $Panel/MarginContainer/VBoxContainer/TextureButton
@onready var back_bg: ColorRect = $Panel/MarginContainer/VBoxContainer/TextureButton/ColorRect2
@onready var back_label: Label = $Panel/MarginContainer/VBoxContainer/TextureButton/Label

const BG_NORMAL := Color("d1be9b")
const BG_HOVER  := Color("bfa982")
const BG_PRESS  := Color("a8926b")

func _ready() -> void:
	# 1) Que NADA se trague mouse excepto el boton
	_set_ignore_mouse($ColorRect) # overlay
	_set_ignore_mouse(panel)
	_set_ignore_mouse(parchment)
	_set_ignore_mouse(root_margin)
	_set_ignore_mouse(root_vbox)

	# Ignorar labels del contenido (título + nombres)
	_ignore_all_labels(root_vbox)

	# 2) El boton SI debe capturar mouse
	back_btn.mouse_filter = Control.MOUSE_FILTER_STOP

	# Hijos del boton deben ignorar mouse
	back_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 3) Asegura hitbox real del boton (solo el botón, NO el bg)
	back_btn.custom_minimum_size = Vector2(100, 30)
	back_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# !!! IMPORTANTE: NO tocamos anchors/offsets del back_bg !!!

	# Color inicial
	back_bg.color = BG_NORMAL

	# Hover + press
	back_btn.mouse_entered.connect(func():
		back_bg.color = BG_HOVER
	)

	back_btn.mouse_exited.connect(func():
		back_bg.color = BG_NORMAL
	)

	back_btn.button_down.connect(func():
		back_bg.color = BG_PRESS
	)

	back_btn.button_up.connect(func():
		back_bg.color = BG_HOVER
	)

	back_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/startMenu/startMenu.tscn")
	)


func _set_ignore_mouse(n: Node) -> void:
	if n is Control:
		(n as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ignore_all_labels(n: Node) -> void:
	for c in n.get_children():
		if c is Label:
			(c as Label).mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ignore_all_labels(c)
