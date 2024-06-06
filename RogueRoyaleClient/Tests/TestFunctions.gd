extends Node
class_name TestFunctions

const character_path = "res://Scenes/Characters/PlayerCharacter/ClientPlayerCharacter.tscn"
const remote_char_path = "res://Scenes/Characters/PlayerTemplate/PlayerTemplate.tscn"
const stamina_path = "res://Scenes/Characters/ModularSystems/Stamina/C_Stamina.tscn"
const dagger_path = "res://Scenes/Weapons/MeleeWeapons/Primary/Dagger/C_Dagger.tscn"
const shield_path = "res://Scenes/Weapons/MeleeWeapons/Secondary/Shields/StarterShield/C_StarterShieldAnimationTree.tscn"
const system_component_path = "res://Scenes/Characters/ModularSystems/StateSystem/StateSystem.tscn"
const character_server_data = [128, 9, 16, 64, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 45, 0, 1]
const character_server_frame = 1
const move_server_data = [219, 159, 18, 96, 12, 0, 48, 1, 20, 0, 26, 83, 111, 76, 93, 233, 179, 0, 0, 128, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 186, 0, 1]
const server_character_instance_id = 10
const move_server_frame = 8
const server_move_instance_id = 99


static func arrays_match(array1, array2) -> bool:
	if array1.size() != array2.size():
		return false
	for i in range(array1.size()):
		if array1[i] != array2[i]:
			return false
	return true

static func queue_scenes_free(scenes : Array) -> void:
	for i in range(scenes.size()):
		scenes[i].queue_free()

func free_scenes_await(scenes : Array) -> void:
	for i in range(scenes.size()):
		scenes[i].queue_free()
	await get_tree().process_frame

static func get_random_direction() -> Vector2:
	randomize()
	var angle = randf() * 2 * PI
	return Vector2(cos(angle), sin(angle))

static func create_release_and_aimed_action(direction : Vector2) -> InputActions:
	var input_actions = InputActions.new()
	var attack_action = ActionFromClient.new()
	var directed_action = ActionFromClient.new()
	directed_action.action_data.looking_vector = direction
	attack_action.action_data.attack_primary = true
	input_actions.previous_actions.duplicate(attack_action)
	input_actions.current_actions.duplicate(directed_action)
	return input_actions

static func init_player_character(player_id : int = 0) -> ClientPlayerCharacter:
	var character = load(character_path).instantiate()
	character.player_id = player_id
	add_all_components_to_player(character)
	Logging.add_child(character)
	_register_character_to_initial_systems(character)
	return character

func instance_character_await(player_id : int = 0) -> ClientPlayerCharacter:
	var character = TestFunctions.init_player_character(player_id)
	await get_tree().process_frame
	return character

func instance_remote_character_await(player_id : int = 0) -> PlayerTemplate:
	var remote_char = load(remote_char_path).instantiate()
	remote_char.player_id = player_id
	add_all_components_to_player(remote_char)
	_register_character_to_initial_systems(remote_char)
	Logging.add_child(remote_char)
	await get_tree().process_frame
	return remote_char

static func _register_character_to_initial_systems(character) -> void:
	MoveStateSystem.queue_entity(0, character)
	InputProcessing._on_player_connected(character.player_id)
	InputProcessing.register_local_player(character.player_id)

static func add_all_components_to_player(character) -> void:
	var stamina = instance_scene_by_id("STM")
	var dagger = instance_scene_by_id("DGR")
	var shield = instance_scene_by_id("SHD")
	var system_component = instance_scene_by_id("SSS")
	var move = instance_scene_by_id("MVE")
	var input_queue = instance_scene_by_id("IQU")
	character.call_deferred("add_component", CommandFrame.execution_frame, input_queue)
	character.call_deferred("add_component", CommandFrame.execution_frame, stamina)
	character.call_deferred("add_component", CommandFrame.execution_frame, move)
	character.call_deferred("add_weapon", CommandFrame.execution_frame, dagger)
	character.call_deferred("add_weapon", CommandFrame.execution_frame, shield)
	character.call_deferred("add_component", CommandFrame.execution_frame, system_component)

static func instance_scene(scene_path : String):
	var scene = load(scene_path).instantiate()
	#ObjectCreationRegistry.call_deferred("add_child", scene)
	Logging.add_child(scene)
	return scene

static func instance_scene_by_id(class_id : String):
	var loaded_scene = ObjectCreationRegistry.int_id_to_loaded_scene[ObjectCreationRegistry.class_id_to_int_id[class_id]]
	var scene = loaded_scene.instantiate()
	Logging.add_child(scene)
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

static func create_directional_input(direction : Vector2) -> InputActions:
	var input_actions = InputActions.new()
	var directed_action = ActionFromClient.new()
	directed_action.action_data.looking_vector = direction
	directed_action.action_data.input_vector = direction
	input_actions.receive_action(directed_action)
	input_actions.receive_action(directed_action)
	return input_actions

static func register_input_for_frame(frame : int, player_id : int, input_actions : InputActions) -> void:
	var previous_frame = CommandFrame.get_previous_frame(frame)
	InputProcessing.receive_action_for_player(previous_frame, player_id, input_actions.previous_actions)
	InputProcessing.receive_action_for_player(frame, player_id, input_actions.current_actions)

static func random_frame():
	randomize()
	var rand_frame = randi() % CommandFrame.MAX_FRAME_NUMBER
	CommandFrame.frame = CommandFrame.get_previous_frame(rand_frame)
	CommandFrame.execute()
	return rand_frame

static func register_input_and_execute_frame(frame : int, player, input_actions : InputActions) -> int:
	register_input_for_frame(frame, player.player_id, input_actions)
	CommandFrame.frame = frame
	CommandFrame.execute()
	SystemController.entity_frame_updates(frame, [player])
	return CommandFrame.get_next_frame(frame)

static func execute_frame_for_entity(frame : int, entity) -> int:
	SystemController.entity_frame_updates(frame, [entity])
	return CommandFrame.get_next_frame(frame)

static func create_random_move_input() -> InputActions:
	var input_actions = InputActions.new()
	var move_action = ActionFromClient.new()
	move_action.action_data.input_vector = get_random_direction()
	input_actions.receive_action(move_action)
	return input_actions
