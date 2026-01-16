extends MarginContainer

@onready var startLabel: Label = $VBoxContainer/Start/startLabel
@onready var creditsLabel: Label = $VBoxContainer/Credits/creditsLabel
@onready var exitLabel: Label = $VBoxContainer/Exit/exitLabel
@onready var ui_player: AudioStreamPlayer2D = $UiPlayer
@onready var flash: ColorRect = $FxLayer/Flash

@export var sfx_hover: AudioStream
@export var sfx_click: AudioStream

const COLOR_NORMAL := Color(1, 1, 1, 0.85)
const COLOR_HOVER  := Color(1.0, 0.90, 0.35, 1.0)
const COLOR_GLOW_A := Color(1.0, 0.85, 0.25, 0.9)
const COLOR_GLOW_B := Color(1.0, 1.0, 0.65, 1.0)

const T_IN := 0.08
const T_OUT := 0.10
const PULSE_TIME := 0.35

var _tweens := {}
var _pulse := {}
var _hovered := {}
var _transitioning := false

func _ready() -> void:
	for lbl in [startLabel, creditsLabel, exitLabel]:
		lbl.modulate = COLOR_NORMAL
		_hovered[lbl] = false
	flash.modulate.a = 0.0

func _play_ui(stream: AudioStream) -> void:
	if stream == null:
		return
	ui_player.stream = stream
	ui_player.play()

func _kill(map: Dictionary, key) -> void:
	if map.has(key):
		var tw: Tween = map[key]
		if is_instance_valid(tw):
			tw.kill()
		map.erase(key)

func _tween_label(lbl: Label, target: Color, time: float) -> void:
	_kill(_tweens, lbl)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(lbl, "modulate", target, time)
	_tweens[lbl] = tw

func _start_pulse(lbl: Label) -> void:
	_kill(_pulse, lbl)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.set_loops()
	tw.tween_property(lbl, "modulate", COLOR_GLOW_B, PULSE_TIME)
	tw.tween_property(lbl, "modulate", COLOR_GLOW_A, PULSE_TIME)
	_pulse[lbl] = tw

func _hover_on(active: Label) -> void:
	if _transitioning:
		return
	_play_ui(sfx_hover)

	for lbl in [startLabel, creditsLabel, exitLabel]:
		_hovered[lbl] = false
		_kill(_pulse, lbl)
		_tween_label(lbl, COLOR_NORMAL, T_OUT)

	_hovered[active] = true
	_tween_label(active, COLOR_HOVER, T_IN)

	var tw := create_tween()
	tw.tween_interval(0.05)
	tw.tween_callback(func():
		if _hovered.get(active, false):
			_start_pulse(active)
	)

func _hover_off(lbl: Label) -> void:
	if _transitioning:
		return
	_hovered[lbl] = false
	_kill(_pulse, lbl)
	_tween_label(lbl, COLOR_NORMAL, T_OUT)

func _on_start_mouse_entered(): _hover_on(startLabel)
func _on_start_mouse_exited(): _hover_off(startLabel)
func _on_credits_mouse_entered(): _hover_on(creditsLabel)
func _on_credits_mouse_exited(): _hover_off(creditsLabel)
func _on_exit_mouse_entered(): _hover_on(exitLabel)
func _on_exit_mouse_exited(): _hover_off(exitLabel)

func _selection_fx(lbl: Label) -> void:
	_transitioning = true

	for l in [startLabel, creditsLabel, exitLabel]:
		_kill(_pulse, l)

	flash.modulate.a = 0.0

	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tw.set_parallel(true)
	tw.tween_property(flash, "modulate:a", 0.35, 0.06)
	tw.set_parallel(false)

	for i in range(6):
		tw.tween_property(lbl, "modulate:a", 0.0, 0.05)
		tw.tween_property(lbl, "modulate:a", 1.0, 0.05)

	tw.set_parallel(true)
	tw.tween_property(flash, "modulate:a", 0.0, 0.35)
	tw.set_parallel(false)

func _on_start_pressed() -> void:
	if _transitioning:
		return
	_play_ui(sfx_click)
	_selection_fx(startLabel)
	await get_tree().create_timer(0.8).timeout
	get_tree().change_scene_to_file("res://scenes/characterSelection/characterSelection.tscn")

func _on_credits_pressed() -> void:
	if _transitioning:
		return
	_play_ui(sfx_click)
	_selection_fx(creditsLabel)

func _on_exit_pressed() -> void:
	if _transitioning:
		return
	_play_ui(sfx_click)
	_selection_fx(exitLabel)
	await get_tree().create_timer(0.8).timeout
	get_tree().quit()
