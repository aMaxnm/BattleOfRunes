extends Node2D

@onready var mage := $slots/mageCharacter
@onready var archer := $slots/archerCharacter
@onready var paladin := $slots/paladinCharacter
@onready var info_panel := $InfoPanel
@onready var top_info := $TopInfo
@onready var ambience: AudioStreamPlayer2D = $AmbiencePlayer
@onready var sfx: AudioStreamPlayer2D = $SfxPlayer
@onready var ui: AudioStreamPlayer2D = $UiPlayer
@onready var flash: ColorRect = $FxLayer/Flash
@onready var game_manager := get_node("/root/game_manager")
@onready var back_btn: TextureButton = $TextureButton
@onready var back_bg: ColorRect = $TextureButton/ColorRect
@onready var back_label: Label = $TextureButton/Label

@export var gameplay_scene_path := "res://scenes/gameplay/gameplay.tscn"
@export var start_menu_scene_path := "res://scenes/startMenu/startMenu.tscn"
@export var sfx_select: AudioStream
@export var sfx_confirm: AudioStream
@export var sfx_hover: AudioStream

@onready var mage_mat := mage.material as ShaderMaterial
@onready var archer_mat := archer.material as ShaderMaterial
@onready var paladin_mat := paladin.material as ShaderMaterial
const BACK_NORMAL := Color("6e6e6e62")
const BACK_HOVER  := Color("6e6e6e") 

var mage_base_scale: Vector2
var archer_base_scale: Vector2
var paladin_base_scale: Vector2

var mage_img: Image
var archer_img: Image
var paladin_img: Image

const BORDER_PIXELS := 10
const GROW := 1.08
const ALPHA_THRESHOLD := 0.05

var character_data = {
	"mageCharacter": {"name": "Mago", "desc": "Ataque mágico alto\nVida baja\nControl de área"},
	"archerCharacter": {"name": "Arquero", "desc": "Daño a distancia\nAlta velocidad\nBaja defensa"},
	"paladinCharacter": {"name": "Paladin", "desc": "Alta defensa\nDaño medio\nGran resistencia"}
}

var info_offset = {
	"mageCharacter": Vector2(80, -80),
	"archerCharacter": Vector2(200, 50),
	"paladinCharacter": Vector2(160, 170)
}

var top_label_x = {
	"mageCharacter": 550.0,
	"archerCharacter": 530.0,
	"paladinCharacter": 530.0
}

var current_hover := ""
var selected_character := ""
var _transitioning := false

func _play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	sfx.stream = stream
	sfx.play()

func _play_ui(stream: AudioStream) -> void:
	if stream == null:
		return
	ui.stream = stream
	ui.play()

func _go_start_menu() -> void:
	if _transitioning:
		return
	_transitioning = true

	_play_sfx(sfx_select)
	_screen_flash()

	await get_tree().create_timer(0.8).timeout
	get_tree().change_scene_to_file(start_menu_scene_path)


func _screen_flash() -> void:
	flash.modulate.a = 0.0
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	var flashes := 6
	var on_time := 0.05
	var off_time := 0.08

	for i in range(flashes):
		tw.tween_property(flash, "modulate:a", 0.55, on_time)
		tw.tween_property(flash, "modulate:a", 0.0, off_time)

func _go_gameplay(char_key: String) -> void:
	if _transitioning:
		return
	_transitioning = true

	game_manager.selected_character = char_key
	_play_sfx(sfx_select)
	_screen_flash()

	await get_tree().create_timer(0.8).timeout
	get_tree().change_scene_to_file(gameplay_scene_path)

func _ready():
	flash.modulate.a = 0.0

	mage_base_scale = mage.scale
	archer_base_scale = archer.scale
	paladin_base_scale = paladin.scale

	mage_mat.set_shader_parameter("enabled", false)
	archer_mat.set_shader_parameter("enabled", false)
	paladin_mat.set_shader_parameter("enabled", false)

	mage_img = mage.texture_normal.get_image()
	archer_img = archer.texture_normal.get_image()
	paladin_img = paladin.texture_normal.get_image()
	back_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	back_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back_bg.color = BACK_NORMAL
	back_btn.mouse_entered.connect(func():
		back_bg.color = BACK_HOVER
		_play_ui(sfx_hover)
	)

	back_btn.mouse_exited.connect(func():
		back_bg.color = BACK_NORMAL
	)

	back_btn.pressed.connect(func():
		_go_start_menu()
	)

	top_info.set_label_x(300.0)
	top_info.set_text("Selecciona personaje")
	info_panel.hide_info()
	if has_node("/root/game_manager"):
		get_node("/root/game_manager").pause_enabled = false

func _process(_delta):
	_handle_hover(mage, mage_mat, mage_base_scale, mage_img)
	_handle_hover(archer, archer_mat, archer_base_scale, archer_img)
	_handle_hover(paladin, paladin_mat, paladin_base_scale, paladin_img)

func _handle_hover(btn: TextureButton, mat: ShaderMaterial, base_scale: Vector2, img: Image):
	var pos = btn.get_local_mouse_position()
	var size = btn.size
	var hovered := false

	if pos.x >= -BORDER_PIXELS and pos.y >= -BORDER_PIXELS and pos.x < size.x + BORDER_PIXELS and pos.y < size.y + BORDER_PIXELS:
		var uv = pos / size
		var px = int(uv.x * img.get_width())
		var py = int(uv.y * img.get_height())

		for dx in range(-BORDER_PIXELS, BORDER_PIXELS + 1):
			for dy in range(-BORDER_PIXELS, BORDER_PIXELS + 1):
				var x = px + dx
				var y = py + dy
				if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
					if img.get_pixel(x, y).a > ALPHA_THRESHOLD:
						hovered = true
						break
			if hovered:
				break

	if hovered:
		mat.set_shader_parameter("enabled", true)
		btn.scale = base_scale * GROW

		if current_hover != btn.name:
			_play_ui(sfx_hover)
			current_hover = btn.name
			var data = character_data[btn.name]

			top_info.set_label_x(top_label_x.get(btn.name, 300.0))
			top_info.set_text(data.name)

			var offset = info_offset.get(btn.name, Vector2(120, -20))
			var panel_size = info_panel.size
			var target_pos = btn.global_position + offset

			target_pos.x -= panel_size.x * 0.5
			target_pos.y -= panel_size.y * 0.5

			var viewport_size = get_viewport_rect().size
			target_pos.x = clamp(target_pos.x, 12.0, viewport_size.x - panel_size.x - 12.0)
			target_pos.y = clamp(target_pos.y, 12.0, viewport_size.y - panel_size.y - 12.0)

			info_panel.show_info(data.name, data.desc, target_pos)
	else:
		mat.set_shader_parameter("enabled", false)
		btn.scale = base_scale

		if current_hover == btn.name:
			current_hover = ""
			info_panel.hide_info()
			top_info.set_label_x(300.0)
			top_info.set_text("Selecciona personaje")

func _on_mage_character_pressed() -> void:
	_go_gameplay("mageCharacter")

func _on_archer_character_pressed() -> void:
	_go_gameplay("archerCharacter")

func _on_paladin_character_pressed() -> void:
	_go_gameplay("paladinCharacter")

func _on_ambience_player_finished() -> void:
	ambience.play()
