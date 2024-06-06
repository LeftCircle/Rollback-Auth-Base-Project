extends RefCounted
class_name SafeUDPMessage

var packet_data : Array

func set_data(frame : int, compressed_array : Array) -> void:
	packet_data = compressed_array
	var frame_bits = BaseCompression.compress_frame_into_3_bytes(frame)
	packet_data += compressed_array

func send_packet() -> void:
	Server.send_reliable_data(packet_data)
