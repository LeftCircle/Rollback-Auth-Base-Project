extends Node2D
class_name BaseNetcodeModule2D

signal frame_to_reset_to(frame)

@export var is_lag_comp: bool = true

var netcode = NetcodeForModules.new()
var history
var component_data = ComponentData.new()

# This is needed for the data setters
var frame : int = 0
var data_container = null
#var execution_frame : int = 0
var entity
var is_entity = false

func _init():
	_netcode_init()
	_data_container_init()
	_init_history()

func _data_container_init():
	#print("No data container for ", self.name)
	pass

func _netcode_init():
	assert(false) #,"Child classes must override _netcode_init()")

func reset_to(data) -> void:
	if is_instance_valid(data_container):
		data_container.set_data_with_obj(data)

func _init_history():
	#assert(false) #,"Must be overwritten!")
	pass

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
			Logging.log_line("Missmatch Detected for below component!")
	else:
		#var server_hist = netcode.state_compresser.remote_decompress(bit_packer)
		var server_hist = netcode.state_compresser.decompress(bit_packer, netcode)
		server_hist.frame = frame
		history.add_data(frame, server_hist)
		call_deferred("reset_to_frame", frame)
		#reset_to_frame(frame)

func receive_test_history_for_frame(frame : int, data, trigger_rollback : bool) -> void:
	if trigger_rollback:
		MissPredictFrameTracker.add_reset_frame(frame)
	history.add_data(frame, data)

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

func connect_to_entity(connected_entity):
	entity = connected_entity

func disconnect_from_entity():
	#entity = null
	pass

func log_component(frame : int) -> void:
	Logging.log_line("log_component not set up for %s" % [name])
