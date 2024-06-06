extends Node


func execute(frame : int) -> void:
	var players = get_tree().get_nodes_in_group("Players")
	for player in players:
		_collect_input_for_player(frame, player)

func _collect_input_for_player(frame : int, player : ServerPlayerCharacter) -> void:
	var frame_actions = InputProcessing.get_action_or_duplicate_for_frame(player.player_id, frame)
	player.input_actions.receive_action(frame_actions)
	Logging.log_line("Inputs for frame " + str(frame) + " are ")
	player.input_actions.log_input_actions()
