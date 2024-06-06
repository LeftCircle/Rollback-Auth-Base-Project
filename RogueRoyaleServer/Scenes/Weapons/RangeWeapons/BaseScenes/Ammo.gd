extends Node
class_name Ammo

@export var max_ammo = 1 # (int, 0, 1000)

@onready var current_ammo = max_ammo

func has_ammo() -> bool:
	return current_ammo > 0

func execute() -> bool:
	if current_ammo > 0:
		use_ammo()
		return true
	else:
		return false

func use_ammo() -> bool:
	if current_ammo > 0:
		_on_ammo_used()
		return true
	return false

func refill_ammo():
	if current_ammo < max_ammo:
		_on_refill_ammo()

func _on_ammo_used():
	current_ammo -= 1

func _on_refill_ammo():
	current_ammo += 1

