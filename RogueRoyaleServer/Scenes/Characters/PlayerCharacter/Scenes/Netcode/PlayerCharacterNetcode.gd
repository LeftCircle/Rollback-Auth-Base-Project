extends NetcodeBase
class_name PlayerCharacterNetcode

# Depricated?

#func _physics_process(delta):
#	#Logging.log_line("State data for frame " + str(CommandFrame.frame))
#	#state_data.log_state()
#	var compressed_state_data = state_compresser.compress_state(class_instance_id, state_data)
#	var compressed_n_modular_abilities = BaseCompression.compress_int_into_x_bits(modular_abilities_this_frame, BITS_FOR_N_MODULAR_ABILTIES)
#	var compressed_modular_data = _compress_modular_data()
#	var compressed_data = compressed_state_data + compressed_n_modular_abilities + compressed_modular_data
#	WorldState.add_compressed_data(class_id, compressed_data)
#	_reset()
#
#func _reset():
#	# TO DO -> Create a fixed size array instead of this dynamic one
#	modular_abilities_this_frame = 0
#	modular_netcode_to_add.clear()
#
#func _compress_data():
#	var compressed_data = state_compresser.compress_state(class_instance_id, state_data)
#	WorldState.add_compressed_data(class_id, compressed_data)
#
#func _compress_modular_data():
#	var data = []
#	for modular_netcode in modular_netcode_to_add.keys():
#		data += modular_netcode.compress_module()
#	return data
#
#func _receive_modular_netcode_data(modular_netcode) -> void:
#	if not modular_netcode_to_add.has(modular_netcode):
#		modular_netcode_to_add[modular_netcode] = null
#		modular_abilities_this_frame += 1
