extends Node

var input_buffer = ProjectSettings.get_setting("global/input_buffer")

func execute(frame : int) -> void:
	var players = get_tree().get_nodes_in_group("Players")
	var previous_frame = CommandFrame.get_previous_frame(frame)
	for player in players:
		_collect_input_for_player(frame, previous_frame, player)
		if player.is_in_group("RemotePlayers"):
			Logging.log_line("Remote input for player %s frame %s" % [player.player_id, frame])
			player.input_actions.log_input_actions()

func _collect_input_for_player(frame : int, previous_frame : int, player) -> void:
	var previous_frame_actions : ActionFromClient = InputProcessing.get_action_or_duplicate_for_frame(previous_frame, player.player_id)
	var frame_actions = InputProcessing.get_action_or_duplicate_for_frame(frame, player.player_id)
	var player_input_actions : InputActions = player.input_actions
	player_input_actions.set_previous_actions(previous_frame_actions)
	player_input_actions.set_current_actions(frame_actions)
	Logging.log_line("Inputs for frame " + str(frame) + " are ")
	player_input_actions.log_input_actions()
