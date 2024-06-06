extends GutTest

var shield_path = "res://Scenes/Weapons/MeleeWeapons/Secondary/Shields/StarterShield/S_StarterShieldAnimationTree.tscn"
var character_path = "res://Scenes/Characters/PlayerCharacter/ServerPlayerCharacter.tscn"


func test_shield_advances_to_attack_1():
	var shield_and_char = _init_shield_and_character()
	await get_tree().process_frame
	var shield = shield_and_char[0]
	_execute_shield_for_10_frames(shield)
	var expected = _get_expected_data_after_10_frames()
	assert_true(expected.matches(shield.weapon_data))
	_queue_free_shield_and_char(shield_and_char)

func test_shield_enters_charging_from_anticipation():
	var shield_and_char = _init_shield_and_character()
	await get_tree().process_frame
	var shield = shield_and_char[0]
	_start_shield_anticipation(shield)
	_hold_attack_for_frames_held_before_charge(shield)
	assert_true(_is_shield_in_state(shield, WeaponRollbackAnimationTreeStateMachine.STATES.CHARGING))
	_queue_free_shield_and_char(shield_and_char)

func test_shield_goes_to_charge_attack():
	var shield_and_char = _init_shield_and_character()
	await get_tree().process_frame
	var shield = shield_and_char[0]
	_start_shield_anticipation(shield)
	_hold_attack_for_frames_held_before_charge(shield)
	# This should cause the main animation to be ended and for the shield to
	# advance to charge attack
	_release_attack_for_x_frames(shield, 30)
	assert_true(_is_shield_in_state(shield, WeaponRollbackAnimationTreeStateMachine.STATES.CHARGE_ATTACK))
	_queue_free_shield_and_char(shield_and_char)

func test_shield_stays_in_charging_state():
	var shield_and_char = _init_shield_and_character()
	await get_tree().process_frame
	var shield = shield_and_char[0]
	_start_shield_anticipation(shield)
	_hold_attack_for_frames_held_before_charge(shield)
	_hold_attack_for_x_frames(shield, 100)
	assert_true(_is_shield_in_state(shield, WeaponRollbackAnimationTreeStateMachine.STATES.CHARGING))
	_queue_free_shield_and_char(shield_and_char)

func _start_shield_anticipation(shield):
	var attack_input = _create_attack_pressed_action()
	shield.execute(0, attack_input)

func _hold_attack_for_frames_held_before_charge(shield):
	var attack_input = _create_attack_pressed_action()
	for i in range(WeaponRollbackAnimationTreeStateMachine.FRAMES_HELD_BEFORE_CHARGE):
		shield.execute(0, attack_input)

func _release_attack_for_x_frames(shield, frames : int) -> void:
	var attack_input = _create_attack_released_actions()
	for i in range(frames):
		shield.execute(0, attack_input)

func _hold_attack_for_x_frames(shield, frames : int) -> void:
	var attack_input = _create_attack_pressed_action()
	for i in range(frames):
		shield.execute(0, attack_input)

func _is_shield_in_state(shield, state_to_check : int) -> bool:
	var state = shield.animation_tree.attack_sequence_map[shield.weapon_data.attack_sequence]
	return state == state_to_check

func _init_shield_and_character():
	var character = load(character_path).instantiate()
	var shield = load(shield_path).instantiate()
	ObjectCreationRegistry.add_child(character)
	ObjectCreationRegistry.add_child(shield)
	character.add_weapon(0, shield)
	return [shield, character]

func _queue_free_shield_and_char(array : Array) -> void:
	array[0].queue_free()
	array[1].queue_free()

func _execute_shield_for_10_frames(shield) -> void:
	var attack_action = _create_attack_pressed_action()
	var release_action = _create_attack_released_actions()
	shield.execute(0, attack_action)
	for _i in range(9):
		shield.execute(0, release_action)

func _get_expected_data_after_10_frames() -> MeleeWeaponData:
	var data = MeleeWeaponData.new()
	data.attack_sequence = 1
	data.is_executing = true
	data.animation_frame = 9
	data.is_in_parry = false
	data.stamina_check_occured = false
	return data

func _create_attack_pressed_action() -> InputActions:
	var input_actions = InputActions.new()
	var attack_action = ActionFromClient.new()
	attack_action.action_data.attack_secondary = true
	input_actions.receive_action(attack_action)
	return input_actions

func _create_attack_released_actions() -> InputActions:
	var input_actions = InputActions.new()
	var attack_action = ActionFromClient.new()
	attack_action.action_data.attack_secondary = true
	input_actions.previous_actions.duplicate(attack_action)
	return input_actions
