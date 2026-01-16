extends Node

enum CharacterType {
	ARCHER,
	SWORD,
	MAGE
}

func fire(character_type: int, rotation: float, spawn_pos: Vector2) -> void:
	match character_type:
		CharacterType.ARCHER:
			ArrowUpgradeManager.fire(rotation, spawn_pos)
			pass
		CharacterType.SWORD:
			SwordUpgradeManager.fire(rotation, spawn_pos)
			pass
		CharacterType.MAGE:
			SpellUpgradeManager.fire(rotation, spawn_pos)
			pass
