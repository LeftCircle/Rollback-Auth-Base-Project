extends RefCounted
class_name CombatBoxTypes

enum {HIT, BLOCK, PARRY}

static func get_str(type : int) -> String:
	if type == HIT:
		return "Hitbox"
	elif type == BLOCK:
		return "BlockBox"
	elif type == PARRY:
		return "ParryBox"
	return "NO_COMBAT_BOX_TYPE"

static func get_box_types() -> Array:
	return ["Hitbox", "BlockBox", "ParryBox"]
