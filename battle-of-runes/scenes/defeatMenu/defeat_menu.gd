extends CanvasLayer

signal resume_pressed
signal select_pressed
signal quit_pressed

@onready var resume_btn: TextureButton = $Panel/MarginContainer/VBox/Resume
@onready var select_btn: TextureButton = $Panel/MarginContainer/VBox/Select
@onready var quit_btn: TextureButton   = $Panel/MarginContainer/VBox/Quit
@onready var overlay: ColorRect = $Overlay

const BG_NORMAL := Color("5a1a1a")
const BG_HOVER  := Color("7a2222")
const BG_PRESS  := Color("3a0f0f")
const OVERLAY_COLOR := Color(0.15, 0.02, 0.02, 0.75)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 500

	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.offset_left = 0
	overlay.offset_top = 0
	overlay.offset_right = 0
	overlay.offset_bottom = 0
	overlay.color = OVERLAY_COLOR
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	$Panel.mouse_filter = Control.MOUSE_FILTER_STOP

	_setup_button(resume_btn, "_on_resume")
	_setup_button(select_btn, "_on_select")
	_setup_button(quit_btn, "_on_quit")

	visible = true

func _setup_button(btn: TextureButton, action: String) -> void:
	if btn == null:
		return

	var bg := btn.get_node("Bg") as ColorRect
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.color = BG_NORMAL

	btn.mouse_filter = Control.MOUSE_FILTER_STOP

	btn.mouse_entered.connect(func():
		bg.color = BG_HOVER
	)

	btn.mouse_exited.connect(func():
		bg.color = BG_NORMAL
	)

	btn.button_down.connect(func():
		bg.color = BG_PRESS
	)

	btn.button_up.connect(func():
		bg.color = BG_HOVER
	)

	btn.pressed.connect(Callable(self, action))

func _on_resume() -> void:
	get_tree().change_scene_to_file("res://scenes/startMenu/startMenu.tscn")

func _on_select() -> void:
	get_tree().change_scene_to_file("res://scenes/characterSelection/characterSelection.tscn")

func _on_quit() -> void:
	get_tree().quit()
