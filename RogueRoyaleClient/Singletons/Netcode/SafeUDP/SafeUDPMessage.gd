extends RefCounted
class_name SafeUDPMessage

var packet_data : Array
var frame_sent : int

func set_data(frame : int, compressed_array : Array) -> void:
	packet_data = compressed_array
	# The frame has to be packed in here somehow

func check_for_resend(frame : int, player_id, resend_after_x_frames : int, average_player_latency : int) -> void:
	var frame_diff = CommandFrame.frame_difference(frame, frame_sent)
	if frame_diff > resend_after_x_frames + average_player_latency:
		send_packet(frame, player_id)

func send_packet(on_frame : int, to_player_id : int) -> void:
	frame_sent = on_frame
	# Send the packet to the palyer!

func _send_packet(scene_tree : SceneTree) -> void:
	scene_tree.multiplayer.send_bytes(packet_data, 0, MultiplayerPeer.TRANSFER_MODE_RELIABLE)
