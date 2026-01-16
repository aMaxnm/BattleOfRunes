extends Area2D

@export var nextRoom: String




func _on_body_entered(body: CharacterBody2D) -> void:
	if body.name == "Arquero":
		print("Cambio")
		changeScene()

func changeScene():
	get_tree().change_scene_to_file(nextRoom)
