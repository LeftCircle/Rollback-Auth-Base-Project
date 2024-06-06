extends RefCounted
class_name FrameLatencyTrackerCompresser

#var bits_for_frame_latency = 20
var server_data

func _init():
	_init_server_data()

func _init_server_data():
	server_data = FrameLatencyTrackerData.new()

func compress(bit_packer : OutputMemoryBitStream, module_data : FrameLatencyTrackerData) -> void:
	#bit_packer.compress_float_into_x_bits(module_data.server_frame_latency, bits_for_frame_latency)
	bit_packer.variable_compress(module_data.eNet_rtt)

func decompress(bit_packer : OutputMemoryBitStream):
	#server_data.server_frame_latency = bit_packer.decompress_float(bits_for_frame_latency)
	server_data.eNet_rtt = bit_packer.variable_decompress(TYPE_FLOAT)
	return server_data
