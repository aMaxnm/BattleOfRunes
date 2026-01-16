extends CanvasLayer

signal resume_pressed
signal select_pressed
signal quit_pressed

@onready var resume_btn: TextureButton = $Panel/MarginContainer/VBox/Resume
@onready var select_btn: TextureButton = $Panel/MarginContainer/VBox/Select
@onready var quit_btn: TextureButton = $Panel/MarginContainer/VBox/Quit
@onready var overlay: ColorRect = $Overlay

const BG_NORMAL := Color(0.16, 0.16, 0.16, 0.95)
const BG_HOVER  := Color(0.10, 0.10, 0.10, 0.95)
const BG_PRESS  := Color(0.06, 0.06, 0.06, 0.95)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 500

	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.offset_left = 0
	overlay.offset_top = 0
	overlay.offset_right = 0
	overlay.offset_bottom = 0
	overlay.color = Color(0, 0, 0, 0.55)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	$Panel.mouse_filter = Control.MOUSE_FILTER_STOP

	_setup_button(resume_btn, "resume_pressed")
	_setup_button(select_btn, "select_pressed")
	_setup_button(quit_btn, "quit_pressed")

	hide_menu()

func _setup_button(btn: TextureButton, sig_name: String) -> void:
	if btn == null:
		push_error("PauseMenu: botón NULL para " + sig_name + " (ruta mal)")
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

	btn.pressed.connect(func():
		emit_signal(sig_name)
	)

func show_menu() -> void:
	visible = true

func hide_menu() -> void:
	visible = false
