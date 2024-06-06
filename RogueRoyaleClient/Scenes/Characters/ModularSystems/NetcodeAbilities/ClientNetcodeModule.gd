extends BaseNetcodeModule
class_name ClientNetcodeModule

signal frame_to_reset_to(frame)

@export var is_lag_comp: bool = true
#export var to_log: bool = false

var history
#var mutex = Mutex.new()

func _init():
	super._init()
	_init_history()

func _init_history():
	assert(false) #,"Must be overwritten!")

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
		if is_instance_valid(data_container):
			hist.set_obj_with_data(data_container)
		else:
			# TO DO -> get all modules to use the data container
			hist.set_obj_with_data(self)

func save_history(frame : int) -> void:
	if is_instance_valid(data_container):
		history.add_data(frame, data_container)
	else:
		history.add_data(frame, self)

func log_component(frame : int) -> void:
	Logging.log_line("Log data not set up for %s" % [netcode.class_id])
