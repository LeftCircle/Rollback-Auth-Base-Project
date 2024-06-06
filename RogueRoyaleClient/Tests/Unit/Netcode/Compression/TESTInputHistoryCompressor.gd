extends GutTestRogue

var input_hist_comp = InputHistoryCompresser.new()

var n_actions = 50
var starting_frame = CommandFrame.MAX_FRAME_NUMBER - 20
var last_frame_acknowledged = starting_frame + 10
var current_frame = starting_frame
var bit_packer = OutputMemoryBitStream.new()
#var action_dict = {}
#var decomp_action_dict = {}

#func test_single_input_compression():
#	var action_dict = {}
#	var decomp_action_dict = {}
#	var action = _generate_random_action()
#	var single_frame = 10
#	action_dict[single_frame] = action
#	input_hist_comp.add_action_to_send(single_frame, action)
#	var sliding_buffer = input_hist_comp._build_sliding_buffer(9, 10)
#	receive_action_history_sliding_buffer(sliding_buffer, decomp_action_dict)
#	assert_true(_check_actions(action_dict, decomp_action_dict))

func test_input_history_compression():
	randomize()
	var action_dict = {}
	var decomp_action_dict = {}
	queue_actions(action_dict)
	var sliding_buffer = input_hist_comp._build_sliding_buffer(last_frame_acknowledged, current_frame)
	receive_action_history_sliding_buffer(sliding_buffer, decomp_action_dict)
	assert_true(_check_actions(action_dict, decomp_action_dict))

func _check_actions(action_dict : Dictionary, decomp_action_dict : Dictionary) -> bool:
	# We search the decomp action dict because not all actions get compressed
	# We should confirm how many are not supposed to be compressed though
	for frame in decomp_action_dict.keys():
		var action = action_dict[frame] as ActionFromClient
		var decomp_action = decomp_action_dict[frame] as ActionFromClient
		var matches = action.action_data.matches(decomp_action.action_data)
		if not matches:
			return false
	return true

func queue_actions(action_dict : Dictionary):
	current_frame = starting_frame
	for i in range(n_actions):
		var action = ActionFromClient.new()
		action.action_data.input_vector = Vector2.UP
		#var action = _generate_random_action()
		input_hist_comp.add_action_to_send(current_frame, action)
		action_dict[current_frame] = action
		current_frame = CommandFrame.get_next_frame(current_frame)
	current_frame = CommandFrame.get_previous_frame(current_frame)

func _generate_random_action():
	var action = ActionFromClient.new()
	action.random_input()
	return action

# Functions from the server...
func receive_action_history_sliding_buffer(sliding_buffer : Array, decomp_action_dict : Dictionary) -> void:
	print("Received hist")
	bit_packer.init_read(sliding_buffer)
	var client_frame = bit_packer.decompress_frame()
	var client_world_state = bit_packer.decompress_frame()
	var acked_frames = FrameAckCompresser.decompress_acked_frames(bit_packer)
	var n_received_frames = 1
	input_hist_comp.set_decompression_frame(client_frame)
	# TO DO -> safeguard with an early out
	while true:
		if bit_packer.is_finished():
			break
		var decomp_action = ActionFromClient.new()
		input_hist_comp.decompress_actions_and_frame_into(decomp_action, bit_packer)
		decomp_action_dict[decomp_action.frame] = decomp_action
		n_received_frames += 1
	


