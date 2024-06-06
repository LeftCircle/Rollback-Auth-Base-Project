extends Node
class_name RollbackMeleeWeaponHistory

#var size = 120
#var array = []
#
#func _init():
#	for i in range(size):
#		array.append(MeleeWeaponRollbackData.new())
#
#func add_data(frame, weapon : BaseClientWeapon) -> void:
#	array[frame % size].set_data(frame, weapon)
#
#func get_data(frame : int) -> MeleeWeaponRollbackData:
#	var data = array[frame % size] as MeleeWeaponRollbackData
#	if not data.frame == frame:
#		data.set_to_reset(frame)
#	return data
