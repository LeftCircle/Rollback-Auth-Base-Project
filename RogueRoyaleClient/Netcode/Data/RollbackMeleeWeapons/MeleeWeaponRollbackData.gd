extends RefCounted
class_name MeleeWeaponRollbackData

# I don't think this class is used?

var frame : int
var frames_since_attack = 0
var attack_sequence = 0
var is_executing = false
var attack_direction : Vector2 = Vector2.ZERO

func set_data(new_frame : int, weapon) -> void:
	frame = new_frame
	frames_since_attack = weapon.frames_since_attack
	is_executing = weapon.is_executing
	attack_direction = weapon.attack_direction
