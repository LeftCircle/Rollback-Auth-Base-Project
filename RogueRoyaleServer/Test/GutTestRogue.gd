extends GutTest
class_name GutTestRogue

const character_path = "res://Scenes/Characters/PlayerCharacter/ServerPlayerCharacter.tscn"

func before_each():
	SystemController.before_gut_test()
	_before_and_after()
	await get_tree().process_frame

func after_each():
	_before_and_after()
	_free_scenes()
	await get_tree().process_frame

func random_frame():
	randomize()
	var rand_frame = randi() % CommandFrame.MAX_FRAME_NUMBER
	CommandFrame.frame = CommandFrame.get_previous_frame(rand_frame)
	CommandFrame.execute()
	return rand_frame

func _before_and_after():
	SystemController.before_gut_test()

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
	node.free()

func instance_scene(path_to_scene : String):
	var scene = load(path_to_scene).instantiate()
	Logging.add_child(scene)
	await get_tree().process_frame
	return scene

func next_physics_step() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame

func instance_scene_by_id(class_id : String):
	var loaded_scene = ObjectCreationRegistry.int_id_to_loaded_scene[ObjectCreationRegistry.class_id_to_int_id[class_id]]
	var scene = loaded_scene.instantiate()
	ObjectCreationRegistry.add_child(scene)
	await get_tree().process_frame
	return scene

func init_player_character(player_id : int = 0):
	var character = load(character_path).instantiate()
	character.player_id = player_id
	ObjectCreationRegistry.add_child(character)
	await get_tree().process_frame
	MoveStateSystem.queue_entity(0, character)
	return character

func register_input_for_frame(frame : int, player_id : int, input_actions : InputActions, advance_input_system = true) -> void:
	var previous_frame = CommandFrame.get_previous_frame(frame)
	InputProcessing.receive_action_for_player(previous_frame, player_id, input_actions.previous_actions)
	InputProcessing.receive_action_for_player(frame, player_id, input_actions.current_actions)
	if advance_input_system:
		PlayerInputSystem.execute(frame)

func register_input_and_execute_frame(frame : int, player, input_actions : InputActions) -> int:
	register_input_for_frame(frame, player.player_id, input_actions, false)
	CommandFrame.frame = frame
	CommandFrame.execute()
	SystemController.entity_frame_updates(frame, [player])
	return CommandFrame.get_next_frame(frame)

func create_held_input(action_string : StringName) -> InputActions:
	var input_actions = InputActions.new()
	var action : ActionFromClient = ActionFromClient.new()
	action.action_data.set(action_string, true)
	input_actions.receive_action(action)
	input_actions.receive_action(action)
	return input_actions


func init_character_with_dagger():
	var character = TestFunctions.init_player_character()
	await get_tree().physics_frame
	var dagger = character.get_primary_weapon()
	return character
