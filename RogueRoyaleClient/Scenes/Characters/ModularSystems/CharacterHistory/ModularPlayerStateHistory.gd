extends BaseModularHistory
class_name ModularPlayerStateHistory

func _init():
	history.resize(size)
	for i in range(size):
		history[i] = PlayerState.new()

#func server_matches_history(server_hist) -> bool:
#	#mutex.lock()
#	var old_data = retrieve_data(server_hist.frame)
#	if old_data == NO_DATA_FOR_FRAME:
#		Logging.log_line("Does not match because no data for frame " + str(server_hist.frame))
#		#server_hist.set_obj_with_data(history[server_hist.frame % size])
#		history[server_hist.frame % size].set_data_with_obj(server_hist)
#		# TO DO -> we could check to see if the frame is in the past or future. If the frame is in the
#		# past, we need to slow down. if in the future speed up?
#		#mutex.unlock()
#		return false
#	var matches = old_data.matches(server_hist)
#	if not matches:
#		Logging.log_line("Missmatch in data for server frame " + str(server_hist.frame))
#		Logging.log_line("Server:")
#		Logging.log_object_vars(server_hist)
#		Logging.log_line("Client:")
#		Logging.log_object_vars(old_data)
#		#server_hist.set_obj_with_data(old_data)
#		old_data.set_data_with_obj(server_hist)
#		#mutex.unlock()
#		return false
#	#mutex.unlock()
#	return true
