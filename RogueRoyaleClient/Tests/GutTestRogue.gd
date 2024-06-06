extends GutTest
class_name GutTestRogue

const character_path = "res://Scenes/Characters/PlayerCharacter/ClientPlayerCharacter.tscn"
const remote_char_path = "res://Scenes/Characters/PlayerTemplate/PlayerTemplate.tscn"
const stamina_path = "res://Scenes/Characters/ModularSystems/Stamina/C_Stamina.tscn"
const dagger_path = "res://Scenes/Weapons/MeleeWeapons/Primary/Dagger/C_DaggerSimple.tscn"
const shield_path = "res://Scenes/Weapons/MeleeWeapons/Secondary/Shields/StarterShield/C_StarterShieldAnimationTree.tscn"
const system_component_path = "res://Scenes/Characters/ModularSystems/StateSystem/StateSystem.tscn"
const character_server_data = [128, 9, 16, 64, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 45, 0, 1]
const character_server_frame = 1
const move_server_data = [219, 159, 18, 96, 12, 0, 48, 1, 20, 0, 26, 83, 111, 76, 93, 233, 179, 0, 0, 128, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 186, 0, 1]
const server_character_instance_id = 10
const move_server_frame = 8
const server_move_instance_id = 99

func before_all():
	if not ObjectCreationRegistry.has_node("TestFunctions"):
		var test_functions = TestFunctions.new()
		test_functions.name = "TestFunctions"
		ObjectCreationRegistry.add_child(test_functions, true)

func before_each():
	_before_and_after()
	await get_tree().physics_frame

func after_each():
	_before_and_after()
	_free_scenes()
	await get_tree().physics_frame

func _before_and_after():
	DeferredDeleteComponent.before_gut_test()
	MissPredictFrameTracker.before_gut_test()
	SystemController.before_gut_test()
	ObjectCreationRegistry.before_gut_test()
	ServerComponentContainer.before_gut_test()
	InputProcessing.before_gut_test()
	PredictedCreationSystem.before_gut()

func testFunctions() -> TestFunctions:
	return ObjectCreationRegistry.get_node("TestFunctions")

func next_physics_step() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame

func _free_scenes() -> void:
	var children = Logging.get_children()
	for i in range(children.size() -1, -1, -1):
		free_children_of(children[i])

func free_children_of(node : Node) -> void:
	if node.get_child_count() > 0:
		var children = node.get_children()
		for i in range(children.size() - 1, -1, -1):
			free_children_of(children[i])
	node.queue_free()

func instance_scene(path_to_scene : String):
	var scene = load(path_to_scene).instantiate()
	Logging.add_child(scene)
	await get_tree().process_frame
	return scene

func instance_scene_by_id(class_id : String):
	var loaded_scene = ObjectCreationRegistry.int_id_to_loaded_scene[ObjectCreationRegistry.class_id_to_int_id[class_id]]
	var scene = loaded_scene.instantiate()
	Logging.add_child(scene)
	await get_tree().process_frame
	return scene

func random_frame():
	randomize()
	var rand_frame = randi() % CommandFrame.MAX_FRAME_NUMBER
	CommandFrame.frame = CommandFrame.get_previous_frame(rand_frame)
	CommandFrame.execute()
	return rand_frame

func init_player_character(player_id : int = randi_range(0, 10000000)) -> ClientPlayerCharacter:
	var character = load(character_path).instantiate()
	character.player_id = player_id
	add_all_components_to_player(character)
	Logging.add_child(character)
	_register_character_to_initial_systems(character)
	await get_tree().process_frame
	return character

func init_player_template(player_id : int = randi_range(0, 10000000)) -> PlayerTemplate:
	var character = load(remote_char_path).instantiate()
	character.player_id = player_id
	add_all_components_to_player(character)
	Logging.add_child(character)
	_register_character_to_initial_systems(character)
	await get_tree().process_frame
	return character

func add_all_components_to_player(character) -> void:
	var stamina = TestFunctions.instance_scene_by_id("STM")
	var dagger = TestFunctions.instance_scene_by_id("DGR")
	var shield = TestFunctions.instance_scene_by_id("SHD")
	var system_component = TestFunctions.instance_scene_by_id("SSS")
	var move = TestFunctions.instance_scene_by_id("MVE")
	var input_queue = TestFunctions.instance_scene_by_id("IQU")
	var dodge = TestFunctions.instance_scene_by_id("ADD")
	character.call_deferred("add_component", CommandFrame.execution_frame, input_queue)
	character.call_deferred("add_component", CommandFrame.execution_frame, stamina)
	character.call_deferred("add_component", CommandFrame.execution_frame, move)
	character.call_deferred("add_weapon", CommandFrame.execution_frame, dagger)
	character.call_deferred("add_weapon", CommandFrame.execution_frame, shield)
	character.call_deferred("add_component", CommandFrame.execution_frame, system_component)
	character.call_deferred("add_component", CommandFrame.execution_frame, dodge)

func _register_character_to_initial_systems(character) -> void:
	MoveStateSystem.queue_entity(0, character)
	InputProcessing._on_player_connected(character.player_id)
	InputProcessing.register_local_player(character.player_id)

func register_input_for_frame(frame : int, player_id : int, input_actions : InputActions) -> void:
	var previous_frame = CommandFrame.get_previous_frame(frame)
	InputProcessing.receive_action_for_player(previous_frame, player_id, input_actions.previous_actions)
	InputProcessing.receive_action_for_player(frame, player_id, input_actions.current_actions)
	PlayerInputSystem.execute(frame)

func register_input_and_execute_frame(frame : int, player, input_actions : InputActions) -> int:
	register_input_for_frame(frame, player.player_id, input_actions)
	CommandFrame.frame = frame
	CommandFrame.execute()
	SystemController.entity_frame_updates(frame, [player])
	return CommandFrame.get_next_frame(frame)

func execute_frame_for_entity(frame : int, entity) -> int:
	SystemController.entity_frame_updates(frame, [entity])
	return CommandFrame.get_next_frame(frame)

func get_random_direction() -> Vector2:
	randomize()
	var angle = randf() * 2 * PI
	return Vector2(cos(angle), sin(angle))

func create_random_move_input() -> InputActions:
	var input_actions = InputActions.new()
	var move_action = ActionFromClient.new()
	move_action.action_data.input_vector = get_random_direction()
	input_actions.receive_action(move_action)
	return input_actions

func create_held_input(action_string : StringName) -> InputActions:
	var input_actions = InputActions.new()
	var action : ActionFromClient = ActionFromClient.new()
	action.action_data.set(action_string, true)
	input_actions.receive_action(action)
	input_actions.receive_action(action)
	return input_actions
