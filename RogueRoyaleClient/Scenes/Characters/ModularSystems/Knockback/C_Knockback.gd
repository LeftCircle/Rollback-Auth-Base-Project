extends Knockback
class_name C_Knockback

func _init_history():
	history = KnockbackHistory.new()

func _init():
	super._init()
	self.name = "C_Knockback"
	Logging.log_line("Init for Knockback %s has been called" % [self.to_string()])

#func execute(frame : int, entity) -> bool:
#	var knockback_occuring = super.execute(frame, entity)
#	# The netcode data is already set in the parent execute function
#	#emit_signal("module_netcode_to_add", netcode)
#	netcode.on_client_update(frame)
#	Logging.log_line("Knockback data for frame " + str(frame))
#	Logging.log_object_vars(data_container)
#	return knockback_occuring
func decompress(frame : int, bit_packer : OutputMemoryBitStream) -> void:
	Logging.log_line("Received data for:")
	log_component(frame)
	if not is_lag_comp:
		var server_hist = netcode.state_compresser.decompress(bit_packer, netcode)
		server_hist.frame = frame
		var matches = history.server_matches_history(server_hist)
		if not matches:
			emit_signal("frame_to_reset_to", frame)
			MissPredictFrameTracker.add_reset_frame(frame)
			Logging.log_line("Missprediction for above component:")
	else:
		#var server_hist = netcode.state_compresser.remote_decompress(bit_packer)
		var server_hist = netcode.state_compresser.decompress(bit_packer, netcode)
		server_hist.frame = frame
		history.add_data(frame, server_hist)
		call_deferred("reset_to_frame", frame)
		#reset_to_frame(frame)

func reset_to_frame(frame : int) -> void:
	var hist = history.retrieve_data(frame)
	if not hist == BaseModularHistory.NO_DATA_FOR_FRAME:
		data_container.set_data_with_obj(hist)
		Logging.log_line("Knockback component RESET to frame %s" % [frame])
		log_component(frame)
	else:
		Logging.log_line("No Knockback data for frame %s" % [frame])
		
#	Logging.log_line("Resetting knockback dat=--=a to frame " + str(frame))
#	Logging.log_object_vars(data_container)

func log_component(frame : int) -> void:
	var player_id = -1 if not is_instance_valid(entity) else entity.player_id
	Logging.log_line("Knockback for player %s | is_from_server = %s, k_speed = %s, k_velocity = %s" % [player_id, netcode.is_from_server, data_container.knockback_speed, data_container.knockback_decay])

#func _exit_tree():
#	if is_instance_valid(entity):
#		entity.remove_from_group("KnockbackEntity")
