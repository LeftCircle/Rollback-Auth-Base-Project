extends Node

# TO DO -> Create an array of a fixed size so that this is not dynamically resized all the time
#var compressed_data_to_pack = []
#
#func _ready():
#	process_priority = ProjectSettings.get_setting("global/PROCESS_LAST")
#
#func _physics_process(_delta):
#	if not compressed_data_to_pack.is_empty():
#		_create_and_send_message()
#	_reset()
#
#func queue_compressed_data_to_send(compressed_data : Array) -> void:
#	compressed_data_to_pack += compressed_data
#
#func _create_and_send_message() -> void:
#	var frame_bits = BaseCompression.compress_frame_into_3_bytes(CommandFrame.frame)
#	compressed_data_to_pack += frame_bits
#	Server.send_reliable_data(compressed_data_to_pack)
#
#func _reset():
#	compressed_data_to_pack.clear()
