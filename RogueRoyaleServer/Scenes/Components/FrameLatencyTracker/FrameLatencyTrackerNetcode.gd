extends NetcodeForModules
class_name FrameLatencyTrackerNetcode

func _init():
#	set_process(false)
#	set_physics_process(false)
	class_instance_id = 0

func _on_ready():
	# All class instance id's of this will be 0, since we are sending only one
	# of these to each player
	class_instance_id = 0

func compress() -> void:
	netcode_bit_stream.reset()
	netcode_bit_stream.compress_class_instance(class_instance_id)
	state_compresser.compress(netcode_bit_stream, state_data)
	netcode_bit_stream.finish_compress()
