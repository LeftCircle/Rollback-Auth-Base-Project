extends RefCounted
# Replaced by MeleeWeaponHistory
#class_name WeaponHistory
#
#var array = []
#var size = 120
#
##func init(data_type : Resource = WeaponHistoryData.new()):
##	for i in range(size):
##		array.append(data_type.duplicate(true))
#
#func _init():
#	_init_array()
#
#func _init_array():
#	for i in range(size):
#		array.append(WeaponHistoryData.new())
#
#func add_data(frame : int, weapon_node) -> void:
#	var old_hist = array[frame % size]
#	old_hist.set_data(weapon_node)
#
#func retrieve(frame : int):
#	return array[frame % size]
#
#func log_data(frame : int) -> void:
#	var data = retrieve(frame)
#	data.log_data()
