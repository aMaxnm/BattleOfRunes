extends Node
var projectile_scene = preload("res://scenes/proyectiles/arquero/arrow_base.tscn")

func fire(rotation: float, spawn_pos: Vector2) -> void:
	if projectile_scene == null:
		push_error("ArrowUpgradeManager: projectile_scene not assigned")
		return

	var projectile = projectile_scene.instantiate()
	projectile.global_position = spawn_pos
	projectile.rotation = rotation

	get_tree().current_scene.add_child(projectile)
