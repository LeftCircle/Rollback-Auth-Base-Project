extends BaseNetcodeModule
class_name AmmoBase

@export var ammo_to_refill_on_hit: int = 1

var max_ammo = 1

@onready var current_ammo = max_ammo

func _netcode_init():
	netcode.init(self, "AMO", AmmoData.new(), AmmoCompresser.new())

func _ready():
	add_to_group("Ammo")

func has_ammo() -> bool:
	return current_ammo > 0

func execute(frame : int) -> bool:
	if current_ammo > 0:
		use_ammo(frame)
		return true
	else:
		return false

func use_ammo(frame : int) -> bool:
	if current_ammo > 0:
		_on_ammo_used(frame)
		return true
	return false

func refill_ammo(frame : int):
	if current_ammo < max_ammo:
		_on_refill_ammo(frame)

func set_max_and_current(frame : int, new_max : int, new_current : int) -> void:
	max_ammo = new_max
	current_ammo = new_current
	#_on_refill_ammo(frame)

func _on_ammo_used(frame : int):
	current_ammo = max(current_ammo - 1, 0)

func _on_refill_ammo(frame : int):
	current_ammo = min(current_ammo + ammo_to_refill_on_hit, max_ammo)
