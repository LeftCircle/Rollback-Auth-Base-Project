extends GutTestRogue
#
#
#
# AC 1:
# When a client presses the dodge button, they are queued to the dodge
# system unless they are locked into their current state.
func test_entities_queue_register_to_dodge_from_move() -> void:
	# Spawn a character in the move system. Then queue a dodge input for
	# the character, and assert they are queued to enter the dodge system.
	var frame = random_frame()
	var character = await init_player_character()
	var dodge_input : InputActions = _build_dodge_input()
	register_input_and_execute_frame(frame, character, dodge_input)
	assert_true(DodgeStateSystem.is_entity_queued(character))
	var system_component : S_StateSystemState = character.get_component("StateSystem")
	assert_eq(system_component.data_container.queued_state, DodgeStateSystem.get_system_id())

func _build_dodge_input() -> InputActions:
	var dodge_action : ActionFromClient = ActionFromClient.new()
	dodge_action.action_data.dodge = true
	var dodge_input : InputActions = InputActions.new()
	dodge_input.receive_action(dodge_action)
	return dodge_input

func test_entities_queue_register_to_dodge_from_attack() -> void:
	# Spawn a character in the attack system. Then queue a dodge input for
	# the character, and assert they are queued to enter the dodge system.
	var frame = random_frame()
	var character = await init_player_character()
	var attack_action : ActionFromClient = ActionFromClient.new()
	attack_action.action_data.attack_primary = true
	var attack_input : InputActions = InputActions.new()
	attack_input.receive_action(attack_action)
	frame = register_input_and_execute_frame(frame, character, attack_input)
	assert_true(AttackPrimaryStateSystem.is_entity_queued(character))
	var dodge_input : InputActions = _build_dodge_input()
	frame = register_input_and_execute_frame(frame, character, dodge_input)
	assert_true(DodgeStateSystem.is_entity_queued(character))
	var system_component : S_StateSystemState = character.get_component("StateSystem")
	assert_eq(system_component.data_container.queued_state, DodgeStateSystem.get_system_id())

func test_entities_queue_register_to_move_if_no_stamina() -> void:
	# spawn a character in the move system, take all of their stamina, then try to get them to enter the dodge system
	# and assert they are queued to enter the move system.
	var frame = random_frame()
	var character = await init_player_character()
	#frame = register_input_and_execute_frame(frame, character, InputActions.new())
	var stamina_component : S_Stamina = character.get_component("Stamina")
	stamina_component.reset_stamina_to_x_active_nodes(0)
	var dodge_input : InputActions = _build_dodge_input()
	frame = register_input_and_execute_frame(frame, character, dodge_input)
	assert_true(MoveStateSystem.is_entity_queued(character))
	assert_false(DodgeStateSystem.is_entity_queued(character))
	assert_false(DodgeStateSystem.is_entity_queued_to_unregister(character), "We don't want to trigger any unregister effects")
	var system_component : S_StateSystemState = character.get_component("StateSystem")
	assert_eq(system_component.data_container.queued_state, MoveStateSystem.get_system_id())
	assert_eq(system_component.data_container.queued_unregister, MoveStateSystem.get_system_id())

	# Step things forward once more and confirm we are still in the move system
	frame = register_input_and_execute_frame(frame, character, InputActions.new())
	assert_true(MoveStateSystem.is_entity_registered(character))
	assert_false(DodgeStateSystem.is_entity_registered(character))
	assert_eq(system_component.data_container.state, MoveStateSystem.get_system_id())
	assert_eq(system_component.data_container.queued_state, SystemController.STATES.NULL)
	assert_eq(system_component.data_container.queued_unregister, SystemController.STATES.NULL)

func test_stamina_is_used_on_system_entry() -> void:
	# Spawn a character in the move system, then queue a dodge input for the character, and assert that the
	# character's stamina is reduced by the dodge cost.
	var frame = random_frame()
	var character = await init_player_character()
	var stamina_component : S_Stamina = character.get_component("Stamina")
	var initial_stamina = stamina_component.get_stamina()
	var dodge_input : InputActions = _build_dodge_input()
	frame = register_input_and_execute_frame(frame, character, dodge_input)
	assert_eq(stamina_component.get_stamina(), initial_stamina - 1)

func test_dodge_animation_frame_is_zero_when_entering_system() -> void:
	# spawn a character, then set their dodge animation frame to 1
	# have the character enter the system, and assert that the dodge animation frame is 0
	var frame = random_frame()
	var character = await init_player_character()
	var dodge_component : AnimationDrivenDodge = character.get_component("Dodge")
	dodge_component.data_container.animation_frame = 3
	var dodge_input : InputActions = _build_dodge_input()
	frame = register_input_and_execute_frame(frame, character, dodge_input)
	DodgeStateSystem.move_queued_entities_to_registered(frame)
	assert_eq(dodge_component.data_container.animation_frame, 0)

func test_dodge_component_queued_to_go_to_clients() -> void:
	var frame = random_frame()
	var character = await init_player_character()
	var dodge_component : AnimationDrivenDodge = character.get_component("Dodge")
	var dodge_input : InputActions = _build_dodge_input()
	var next_frame = register_input_and_execute_frame(frame, character, dodge_input)
	PlayerStateSync.set_physics_process(true)
	var next_next_frame = register_input_and_execute_frame(next_frame, character, InputActions.new())
	PlayerStateSync.set_physics_process(false)
	assert_true(PlayerStateSync.has_component(dodge_component))

func test_animation_tree_updates_with_dodge_execution() -> void:
	# Run a few frames of the dodge system, and assert that the animation player
	# is updated with the dodge animation.
	var frame = random_frame()
	var character = await init_player_character()
	var dodge_input : InputActions = _build_dodge_input()
	frame = register_input_and_execute_frame(frame, character, dodge_input)
	var frames_to_execute = 5
	for i in range(frames_to_execute):
		frame = register_input_and_execute_frame(frame, character, InputActions.new())
	var animation_player : AnimationPlayer = character.animations
	var animation_tree : RollbackAnimationTree = character.animation_tree
	assert_eq(animation_tree.get_active_node(), "Dodge")
	assert_eq(animation_tree.get_animation_frame(), frames_to_execute)

func test_queued_input_is_none_after_entering_system() -> void:
	var frame = random_frame()
	var character = await init_player_character()
	var dodge_input : InputActions = _build_dodge_input()
	var input_queue = character.get_component("InputQueue")
	frame = register_input_and_execute_frame(frame, character, dodge_input)
	assert_eq(input_queue.data_container.input, InputQueueComponent.string_to_int["NONE"])
	frame = register_input_and_execute_frame(frame, character, InputActions.new())
	assert_eq(input_queue.data_container.input, InputQueueComponent.string_to_int["NONE"])

func test_dodge_input_is_not_queued_if_held_after_entering_dodge_system() -> void:
	var frame = random_frame()
	var character = await init_player_character()
	var dodge_just_pressed : InputActions = _build_dodge_input()
	var dodge_held_input : InputActions = _build_dodge_held_input()
	frame = register_input_and_execute_frame(frame, character, dodge_just_pressed)
	assert_true(DodgeStateSystem.is_entity_queued(character))
	var input_queue = character.get_component("InputQueue")
	assert_eq(input_queue.data_container.input, InputQueueComponent.string_to_int["NONE"])
	frame = register_input_and_execute_frame(frame, character, dodge_held_input)
	assert_eq(input_queue.data_container.input, InputQueueComponent.string_to_int["NONE"])

func _build_dodge_held_input() -> InputActions:
	var dodge_action : ActionFromClient = ActionFromClient.new()
	dodge_action.action_data.dodge = true
	var dodge_input : InputActions = InputActions.new()
	dodge_input.receive_action(dodge_action)
	dodge_input.receive_action(dodge_action)
	return dodge_input

func test_dodge_not_entered_if_held() -> void:
	# Have a character enter the dodge system and hold down the dodge button. 
	# Continue the animation until they enter the move system once the dodge is finished. 
	# assert that the character does not reinter the dodge system
	var frame = random_frame()
	var character = await init_player_character()
	var dodge_held_input : InputActions = _build_dodge_held_input()
	frame = _enter_character_into_dodge_system_with_input(frame, character, dodge_held_input)
	frame = _finish_dodge_animation_with_input(frame, character, dodge_held_input)

	assert_true(MoveStateSystem.is_entity_registered(character))
	assert_false(DodgeStateSystem.is_entity_registered(character))
	assert_false(DodgeStateSystem.is_entity_queued(character))
	# Assert that the queued input is not dodge
	var input_queue = character.get_component("InputQueue")
	assert_eq(input_queue.data_container.input, InputQueueComponent.string_to_int["NONE"])

func _enter_character_into_dodge_system_with_input(frame : int, character, inputs : InputActions) -> int:
	var dodge_input : InputActions = _build_dodge_input()
	frame = register_input_and_execute_frame(frame, character, dodge_input)
	assert_true(DodgeStateSystem.is_entity_queued(character), "Player should be queued into dodge")
	frame = register_input_and_execute_frame(frame, character, inputs)
	assert_true(DodgeStateSystem.is_entity_registered(character), "Should be registered into dodge")
	var system_component : S_StateSystemState = character.get_component("StateSystem")
	assert_eq(system_component.data_container.state, DodgeStateSystem.get_system_id())
	return frame

func _finish_dodge_animation_with_input(frame : int, character, inputs : InputActions) -> int:
	var stamina_component : S_Stamina = character.get_component("Stamina")
	var initial_stamina = stamina_component.get_stamina()
	var failsafe = 0
	var system_component : S_StateSystemState = character.get_component("StateSystem")
	while system_component.data_container.state == DodgeStateSystem.get_system_id():
		frame = register_input_and_execute_frame(frame, character, inputs)
		failsafe += 1
		if failsafe > 500:
			assert_true(false, "Failsafe triggered")
			break
		if stamina_component.get_stamina() < initial_stamina:
			assert_true(false, "Stamina was used probably because of dodge")
			break
	return frame

func test_input_queue_cleared_on_entry() -> void:
	var frame = random_frame()
	var character = await init_player_character()
	var dodge_input : InputActions = _build_dodge_input()
	var input_queue : S_InputQueue = character.get_component("InputQueue")
	register_input_for_frame(frame, character.player_id, dodge_input)
	input_queue.execute(frame, character.input_actions)
	assert_true(character.input_actions.is_action_just_pressed("dodge"))
	assert_eq(input_queue.data_container.input, InputQueueComponent.string_to_int["dodge"])
	DodgeStateSystem._on_entity_registered(frame, character)
	assert_eq(input_queue.data_container.input, InputQueueComponent.string_to_int["NONE"])
