extends Node

var selected_character: String = ""

var pause_menu_scene: PackedScene = preload("res://scenes/pauseMenu/pauseMenu.tscn")
var pause_menu: CanvasLayer = null
var pause_enabled := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)

	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return

	if event.is_action_pressed("ui_cancel"):
		if not pause_enabled:
			return
		_toggle_pause()
		get_viewport().set_input_as_handled()

func _ensure_pause_menu() -> void:
	if not is_instance_valid(pause_menu):
		pause_menu = pause_menu_scene.instantiate() as CanvasLayer

		pause_menu.resume_pressed.connect(Callable(self, "_resume"))
		pause_menu.select_pressed.connect(Callable(self, "_go_character_select"))
		pause_menu.quit_pressed.connect(Callable(self, "_quit"))

		pause_menu.hide_menu()

	if pause_menu.get_parent() == null:
		get_tree().current_scene.add_child(pause_menu)

func _toggle_pause() -> void:
	if not pause_enabled:
		return

	_ensure_pause_menu()

	if get_tree().paused:
		get_tree().paused = false
		pause_menu.hide_menu()
	else:
		pause_menu.show_menu()
		get_tree().paused = true

func _resume() -> void:
	get_tree().paused = false
	if is_instance_valid(pause_menu):
		pause_menu.hide_menu()

func _go_character_select() -> void:
	get_tree().paused = false
	pause_enabled = false
	selected_character = ""

	if is_instance_valid(pause_menu):
		pause_menu.hide_menu()

	get_tree().change_scene_to_file("res://scenes/characterSelection/characterSelection.tscn")

func _quit() -> void:
	get_tree().quit()
