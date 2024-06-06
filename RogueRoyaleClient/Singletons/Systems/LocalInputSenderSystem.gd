extends Node

# This system requires the PlayerInputSystem to get the polled input actions from the player character.
# It cannot execute until the PlayerInputSystem has executed.
# It also shouldn't execute each time that the PlayerInputSystem executes, since the PlayerInputSystem will need
# to execute to get inputs for rollback

# All of this should just be grouped into the InputPollerSystem -- Maybe... We could seperate
# it if we wanted to send in another thread or something?

#func execute(frame : int) -> void:
#	var local_player : Array = get_tree().get_nodes_in_group("LocalPlayer")
#	for player in local_player:
#		_send_local_inputs(frame, player)
#
#func _send_local_inputs(frame : int, player : ClientPlayerCharacter) -> void:
#	var input_sender = player.input_sender
#	var polled_input_actions = InputProcessing.get_action_or_duplicate_for_frame(player.player_id, frame)
#	input_sender.add_action_to_send(frame, polled_input_actions)
#	input_sender.send_sliding_buffer(WorldState.most_recently_received_world_frame, frame)
