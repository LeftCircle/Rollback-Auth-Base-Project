extends RangeNetcodeBase
class_name C_RangeNetcodeBase

signal frame_to_reset_to(frame)

@export var is_lag_comp: bool = true

var history

func decompress(frame : int, bit_packer : OutputMemoryBitStream) -> void:
	Logging.log_line("Received data for:")
	log_component(frame)
	if not is_lag_comp:
		var server_hist = netcode.state_compresser.decompress(bit_packer, netcode)
		server_hist.frame = frame
		var matches = history.server_matches_history(server_hist)
		if not matches:
			#print(self.name, " does not match on frame ", frame)
			emit_signal("frame_to_reset_to", frame)
			MissPredictFrameTracker.add_reset_frame(frame)
			Logging.log_line("Missprediction for above component:")
	else:
		var server_hist = netcode.state_compresser.decompress(bit_packer, netcode)
		server_hist.frame = frame
		history.add_data(frame, server_hist)
		#reset_to_frame(frame)
		call_deferred("reset_to_frame", frame)

func reset_to_frame(frame : int) -> void:
	var hist = history.retrieve_data(frame)
	if not hist == BaseModularHistory.NO_DATA_FOR_FRAME:
		hist.set_obj_with_data(self)

func connect_to_entity(connected_entity):
	entity = connected_entity

func disconnect_from_entity():
	#entity = null
	pass

func log_component(frame : int) -> void:
	Logging.log_line("Log data not set up for %s" % [netcode.class_id])
