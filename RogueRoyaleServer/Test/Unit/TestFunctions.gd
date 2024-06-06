extends RefCounted
class_name TestFunctions

const character_path = "res://Scenes/Characters/PlayerCharacter/ServerPlayerCharacter.tscn"
const dagger_path = "res://Scenes/Weapons/MeleeWeapons/Primary/Dagger/S_DaggerSimple.tscn"

static func arrays_match(array1, array2) -> bool:
	if array1.size() != array2.size():
		return false
	for i in range(array1.size()):
		if array1[i] != array2[i]:
			return false
	return true

static func queue_scenes_free(scenes : Array) -> void:
	for i in range(scenes.size()):
		if is_instance_valid(scenes[i]):
			scenes[i].queue_free()

static func get_random_direction() -> Vector2:
	randomize()
	var angle = randf() * 2 * PI
	return Vector2(cos(angle), sin(angle))

static func average_array(arr : Array) -> float:
	var sum = 0.0
	for i in arr:
		sum += i
	return sum / arr.size()

static func get_array_of_random_values(n_values : int, min_val : float, max_val : float) -> Array:
	var all_values = []
	randomize()
	for _i in range(n_values):
		var rand_f : float = randf() * (max_val - min_val) + min_val
		all_values.append(rand_f)
	return all_values

static func create_release_and_aimed_action(direction : Vector2) -> InputActions:
	var input_actions = InputActions.new()
	var attack_action = ActionFromClient.new()
	var directed_action = ActionFromClient.new()
	directed_action.action_data.looking_vector = direction
	attack_action.action_data.attack_primary = true
	input_actions.previous_actions.duplicate(attack_action)
	input_actions.current_actions.duplicate(directed_action)
	return input_actions

static func init_player_character(player_id : int = 0):
	var character = load(character_path).instantiate()
	character.player_id = player_id
	ObjectCreationRegistry.add_child(character)
	return character

static func instance_scene(scene_path : String):
	var scene = load(scene_path).instantiate()
	ObjectCreationRegistry.add_child(scene)
	return scene

static func create_attack_pressed_action(is_pressed : bool) -> InputActions:
	var input_actions = InputActions.new()
	var attack_action = ActionFromClient.new()
	attack_action.action_data.attack_primary = true
	if is_pressed:
		input_actions.receive_action(attack_action)
	else:
		input_actions.previous_actions.duplicate(attack_action)
	return input_actions

static func create_attack_secondary_pressed_action(is_pressed : bool) -> InputActions:
	var input_actions = InputActions.new()
	var attack_action = ActionFromClient.new()
	attack_action.action_data.attack_secondary = true
	if is_pressed:
		input_actions.receive_action(attack_action)
	else:
		input_actions.previous_actions.duplicate(attack_action)
	return input_actions

static func register_input_for_frame(frame : int, player_id : int, input_actions : InputActions) -> void:
	var previous_frame = CommandFrame.get_previous_frame(frame)
	InputProcessing.receive_action_for_player(previous_frame, player_id, input_actions.previous_actions)
	InputProcessing.receive_action_for_player(frame, player_id, input_actions.current_actions)

static func random_frame():
	randomize()
	return randi() % CommandFrame.MAX_FRAME_NUMBER

static func register_input_and_execute_frame(frame : int, player, input_actions : InputActions) -> int:
	register_input_for_frame(frame, player.player_id, input_actions)
	SystemController.entity_frame_updates(frame, [player])
	return CommandFrame.get_next_frame(frame)

static func execute_frame_for_entity(frame : int, entity) -> int:
	SystemController.entity_frame_updates(frame, [entity])
	return CommandFrame.get_next_frame(frame)

static func set_stamina_to_zero(character) -> void:
	var stamina = character.get_component("Stamina")
	stamina.reset_stamina_to_x_active_nodes(0)
