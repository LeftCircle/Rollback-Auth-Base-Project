extends RefCounted
class_name AnimationAttackSystem

const FRAMES_HELD_BEFORE_CHARGE = 12

func execute_system(frame : int, input_actions : InputActions, animation_data : WeaponData) -> void:
	#animation_data.execution_frame = frame
	animation_data.attack_end = WeaponData.ATTACK_END.NONE
	if animation_data.attack_sequence == 0:
		_in_anticipation(frame, input_actions, animation_data)
	else:
		_on_attack(frame, input_actions, animation_data)

func _in_anticipation(frame : int, input_actions : InputActions, animation_data : WeaponData):
	if animation_data.animation_frame == 0:
		_execution_start_system(input_actions, animation_data)
		animation_data.animation = "Anticipation"
		animation_data.queued_input.input = animation_data.queued_input.input_to_check
		animation_data.queued_input.is_released = false
	else:
		if input_actions.is_action_released(animation_data.queued_input.input_to_check):
			animation_data.attack_sequence = 1
			animation_data.animation_frame = 0
			animation_data.queued_input.reset()
			_on_attack(frame, input_actions, animation_data)
			return
	if animation_data.animation_player.current_animation == "":
		_on_animation_end(frame, input_actions, animation_data)

func _on_attack(frame : int, input_actions : InputActions, animation_data : WeaponData):
	if animation_data.attack_sequence > animation_data.max_sequence:
		_on_special_attack(frame, input_actions, animation_data)
	else:
		animation_data.animation = "Attack_" + str(animation_data.attack_sequence)
		if animation_data.animation_frame != 0:
			_queue_input(input_actions, animation_data)
			if animation_data.main_animation_ended:
				_check_for_next_attack_or_combo(frame, input_actions, animation_data)
				if animation_data.attack_sequence == 0:
					_in_anticipation(frame, input_actions, animation_data)
					return
		#_play_animation(frame, animation_data)
		MoveOnAttack.move_entity(frame, animation_data.move, animation_data)
		if animation_data.animation_player.current_animation == "":
			_on_animation_end(frame, input_actions, animation_data)

func _check_for_next_attack_or_combo(frame : int, input_actions : InputActions, animation_data : WeaponData):
	if animation_data.queued_input.input != "":
		if animation_data.queued_input.is_released:
			if animation_data.queued_input.input == animation_data.queued_input.input_to_check:
				# advance to the next action!
				_on_advance_to_next_attack(frame, input_actions, animation_data)
			else:
				assert(false) #,"not yet implemented")

func _on_special_attack(frame : int, input_actions : InputActions, animation_data : WeaponData):
	if animation_data.attack_sequence == animation_data.get_charging_sequence():
		# In order to get here a stamina check must have already been met
		_on_charging(frame, input_actions, animation_data)
	elif animation_data.attack_sequence == animation_data.get_charge_attack_sequence():
		pass
	elif animation_data.attack_sequence == animation_data.get_combo_sequence():
		pass

func _on_charging(frame : int, input_actions : InputActions, animation_data : WeaponData):
	animation_data.animation = "Charging"
	if not input_actions.is_action_pressed(animation_data.queued_input.input_to_check):
		print("Charge attack should occur!!")
		animation_data.reset()
		animation_data.attack_sequence = 1
		_on_attack(frame, input_actions, animation_data)
	else:
		#_play_animation(frame, animation_data)
		pass

func _execution_start_system(input_actions : InputActions, animation_data : WeaponData) -> void:
	var direction = input_actions.get_looking_vector()
	animation_data.attack_direction = direction
	animation_data.is_executing = true

func _on_advance_to_next_attack(frame : int, input_actions : InputActions, animation_data : WeaponData) -> void:
	var to_advance = true
	if animation_data.attack_sequence == (animation_data.max_sequence - 1):
		if animation_data.queued_input.stamina_check_occured:
			to_advance = false
		# Check to see if we have stamina - only once per attack!!
		elif animation_data.stamina.execute(frame, animation_data.stamina_cost):
			animation_data.animation_frame = 0
			to_advance = true
		else:
			to_advance = false
			animation_data.queued_input.stamina_check_occured = true
			print("No stamina for finisher")
	if to_advance:
		animation_data.is_in_parry = false
		animation_data.is_executing = false
		animation_data.animation = "RESET"
		animation_data.animation_player.play("RESET")
		animation_data.stamina.reset_timers(frame)
		animation_data.attack_sequence = (animation_data.attack_sequence + 1) % (animation_data.max_sequence + 1)
		animation_data.reset(false)
		_execution_start_system(input_actions, animation_data)
		if animation_data.attack_sequence != 0:
			_on_attack(frame, input_actions, animation_data)
		else:
			_in_anticipation(frame, input_actions, animation_data)

func _on_animation_end(frame : int, input_actions : InputActions, animation_data : WeaponData):
	if animation_data.queued_input.input != "":
		# We need to start whatever thing there is
		if animation_data.queued_input.is_released == false:
			if animation_data.queued_input.input == animation_data.queued_input.input_to_check:
				# Start the charge attack if there is stamina!
				_check_for_charge_attack(frame, input_actions, animation_data)
			else:
				assert(false) #," Send a signal to the state machine to handle this")
			print("Charge attack to occur! Might have to change to other weapon or ability")
		else:
			_on_end_animation_queued_input(frame, input_actions, animation_data)
	else:
		animation_data.is_executing = false
		animation_data.reset()
		animation_data.is_in_parry = false
		animation_data.stamina.reset_timers(frame)
		animation_data.animation = "RESET"
		animation_data.animation_player.play("RESET")
		animation_data.attack_end = WeaponData.ATTACK_END.END

func _check_for_charge_attack(frame : int, input_actions : InputActions, animation_data : WeaponData):
	if animation_data.queued_input.held_frames >= FRAMES_HELD_BEFORE_CHARGE:
		if animation_data.stamina.execute(frame, animation_data.stamina_cost):
			animation_data.attack_sequence = animation_data.get_charging_sequence()
			_on_successfull_attack_change(animation_data)
			_on_charging(frame, input_actions, animation_data)
		else:
			print("No stamina for charge attack")
			animation_data.queued_input.stamina_check_occured = true
			_on_advance_to_next_attack(frame, input_actions, animation_data)

func _on_successfull_attack_change(animation_data : WeaponData):
	animation_data.is_in_parry = false
	animation_data.reset(false)

func _on_end_animation_queued_input(frame : int, input_actions : InputActions, animation_data : WeaponData):
	if animation_data.queued_input.input == animation_data.queued_input.input_to_check:
		if animation_data.queued_input.stamina_check_occured:
			if animation_data.attack_sequence == (animation_data.max_sequence - 1):
				animation_data.attack_sequence = 0
				animation_data.reset(false)
				_in_anticipation(frame, input_actions, animation_data)
			else:
				_on_advance_to_next_attack(frame, input_actions, animation_data)
	else:
		assert(false) #,"We should have already handed off this logic")

# Client version!! -> Should be its own system
# func _play_animation(frame : int, animation_data : WeaponData) -> void:
# 	# Advancing the frame MUST come first, otherwise it can be set after
# 	# the animation finishes
# 	animation_data.animation_frame += 1
# 	animation_data.animation_player.play(animation_data.animation)
# 	animation_data.animation_player.rollback_advance(frame)
# 	# This prevents us from adding frames to animations that shouldn't be looped
# 	animation_data.animation_frame -= 1 * int(animation_data.animation_player.current_animation == "")

func _queue_input(input_actions : InputActions, animation_data : WeaponData) -> void:
	if animation_data.queued_input.input == "":
		if input_actions.is_action_just_pressed("attack_primary"):
			animation_data.queued_input.input = "attack_primary"
		elif input_actions.is_action_just_pressed("attack_secondary"):
			animation_data.queued_input.input = "attack_secondary"
		elif input_actions.is_action_just_pressed("fire_ranged_weapon"):
			animation_data.queued_input.input = "fire_ranged_weapon"
		elif input_actions.is_action_just_pressed("health_flask"):
			animation_data.queued_input.input = "health_flask"
		elif input_actions.is_action_just_pressed("special_1"):
			animation_data.queued_input.input = "special_1"
		elif input_actions.is_action_just_pressed("special_2"):
			animation_data.queued_input.input = "special_2"
	else:
		if input_actions.is_action_released(animation_data.queued_input.input):
			animation_data.queued_input.is_released = true
		else:
			animation_data.queued_input.held_frames += 1
