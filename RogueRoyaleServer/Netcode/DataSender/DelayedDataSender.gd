extends RefCounted
class_name DelayedDataSender

var send_after_x_frames = 0
var _frames_since_last_send = 0

func send_data(netcode, player_ids : Array) -> void:
	if _frames_since_last_send >= send_after_x_frames:
		_frames_since_last_send = 0
		PlayerStateSync.add_netcode_to_compress(netcode, player_ids)
	else:
		_frames_since_last_send += 1
