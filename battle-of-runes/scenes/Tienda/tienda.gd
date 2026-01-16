extends MarginContainer
@onready var sprite = $Vendedor/AnimatedSprite2D
@export var nextRoom: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mejora_velocidad_pressed() -> void:
	sprite.play("Pagado")
	apagarBotones()
	pass # Replace with function body.


func _on_mejora_vida_pressed() -> void:
	sprite.play("Pagado")
	apagarBotones()
	pass # Replace with function body.


func _on_mejora_damaged_pressed() -> void:
	sprite.play("Pagado")
	apagarBotones()
	pass # Replace with function body.


func _on_mejora_recarga_pressed() -> void:
	sprite.play("Pagado")
	apagarBotones()
	pass # Replace with function body.
	
func apagarBotones() -> void:
	$HBoxContainer/VBoxContainer/mejoraVelocidad.disabled = true
	$HBoxContainer/VBoxContainer/mejoraVida.disabled = true
	$HBoxContainer/VBoxContainer3/mejoraDamaged.disabled = true
	$HBoxContainer/VBoxContainer3/mejoraRecarga.disabled = true





func _on_mejora_recarga_mouse_entered() -> void:
	sprite.play("SeleccionarItemDer")
	pass # Replace with function body.


func _on_mejora_recarga_mouse_exited() -> void:
	sprite.play("saludo")
	pass # Replace with function body.


func _on_mejora_damaged_mouse_entered() -> void:
	sprite.play("SeleccionarItemDer")
	pass # Replace with function body.


func _on_mejora_damaged_mouse_exited() -> void:
	sprite.play("saludo")
	pass # Replace with function body.


func _on_mejora_vida_mouse_entered() -> void:
	sprite.play("SeleccionarItemIzq")
	pass # Replace with function body.


func _on_mejora_vida_mouse_exited() -> void:
	sprite.play("saludo")
	pass # Replace with function body.
	



func _on_mejora_velocidad_mouse_entered() -> void:
	sprite.play("SeleccionarItemIzq")
	pass # Replace with function body.


func _on_mejora_velocidad_mouse_exited() -> void:
	sprite.play("saludo")
	pass # Replace with function body.


func _on_salida_pressed() -> void:
	changeScene()

func changeScene():
	get_tree().change_scene_to_packed(nextRoom)
