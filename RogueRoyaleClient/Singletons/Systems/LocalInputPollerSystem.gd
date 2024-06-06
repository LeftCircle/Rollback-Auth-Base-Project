extends Node


var input_buffer = ProjectSettings.get_setting("global/input_buffer")


func execute(frame : int) -> void:
	var local_player = get_tree().get_nodes_in_group("LocalPlayer")
	for player in local_player:
		_poll_input_for_local_player(frame, player)

func _poll_input_for_local_player(frame : int, player : ClientPlayerCharacter) -> void:
	var inputs = player.inputs
	var input_sender : InputHistoryCompresser = player.input_sender
	inputs.track_inputs(player)
	InputProcessing.receive_unbuffered_action_for_player(frame, player.player_id, inputs)
	input_sender.add_action_to_send(frame, inputs)
	input_sender.send_sliding_buffer(WorldState.most_recently_received_world_frame, frame)
