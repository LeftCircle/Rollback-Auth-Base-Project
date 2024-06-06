extends GutTestRogue
class_name ActionFromClientCompressionTest

var compresser = ActionFromClientCompression.new()

#func test_compress() -> void:
#	var bit_array_reader = BitArrayReader.new()
#	var new_action = ActionFromClient.new()
#	_generate_random_action(new_action)
#	var actions = [new_action, ActionFromClient.new()]
#	var test_frame = CommandFrame.frame
#	for action in actions:
#		var compressed_action = compresser.compress_action(action)
#		bit_array_reader.set_bit_array(compressed_action)
#		var decomp_action = ActionFromClient.new()
#		compresser.decompress_actions_into(decomp_action, bit_array_reader)
#		print("Starting actions")
#		print(action.action_dict)
#		print("Decompressed actions")
#		print(decomp_action.action_dict)
#		assert_true(action.matches_action(decomp_action))
#	#assert_true(decomp_action.frame == test_frame)
#
#func _generate_random_action(action : ActionFromClient):
#	for action_str in action.OTHER_ACTIONS:
#		action.action_dict[action_str] = randi() % 2
#	for action_str in action.VECTOR_ACTIONS:
#		var vec = Vector2(randf(), randf())
#		vec = vec.normalized()
#		action.action_dict[action_str] = vec
