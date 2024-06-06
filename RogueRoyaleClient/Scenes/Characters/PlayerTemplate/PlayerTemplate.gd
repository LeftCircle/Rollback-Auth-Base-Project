extends ClientBaseCharacter
# ROLLBACK PLAYER TEMPLATE!!!!!
class_name PlayerTemplate

var server_correction_needed = false
var received_compressed_inputs = []
var inputs_received_for_this_frame = false
var predicted_input_actions = {}
var predicted_action_verifier = PredictedActionVerifier.new()
var predicted_actions_frame_array = PredictedActionsLoopingArray.new()

@onready var health_gui = $NodeInterpolater/OverwatchHealth

func _ready():
	super._ready()
	debug_to_log = true
	predicted_action_verifier.init(self)
	add_to_group("RemotePlayers")

func connect_health_to_gui(health_component : ClientHealth) -> void:
	health_component.connect("health_changed", health_gui._on_health_changed)

#func silent_update(frame : int, to_player_state : PlayerState) -> void:
#	super.silent_update(frame, to_player_state)
#	looking_vector = to_player_state.looking_vector

#func _set_input_actions(frame : int):
#	if not InputProcessing.player_action_buffers.has(player_id):
#		return
#	if not InputProcessing.has_received_current_and_previous_for_frame(player_id, frame):
#		input_actions.receive_action(InputProcessing.get_most_recently_received_actions(player_id))
#		_track_predicted_actions(frame)
#	else:
#		InputProcessing.copy_input_actions_for_frame_into(player_id, frame, input_actions)
#
#func _track_predicted_actions(frame : int):
#	var input_actions_to_write = predicted_actions_frame_array.retrieve(frame)
#	input_actions_to_write.duplicate(input_actions)
#	predicted_input_actions[frame] = input_actions_to_write

