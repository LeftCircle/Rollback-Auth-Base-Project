#################################################
######   SHARED BETWEEN CLIENT AND SERVER   #####
#################################################
extends BaseWeaponRollbackAnimationTree
class_name WeaponRollbackAnimationTreeStateMachine

const FRAMES_HELD_BEFORE_CHARGE = 12
enum STATES{RESET, ANTICIPATION, ATTACK, PREFINISHER, FINISHER, CHARGING, CHARGE_ATTACK, COMBO}

@export var to_log: bool = false

var state = STATES.RESET

var attack_sequence_map = {}

func _ready():
	super._ready()
	reset_state_machine()

func init(new_weapon) -> void:
	super.init(new_weapon)
	_init_attack_sequence_map()
	_init_sequence_to_animation_map()

func execute(frame : int, input_actions : InputActions) -> void:
	var stamina = weapon.entity.get_component("Stamina")
	input_queue = weapon.entity.get_component("InputQueue")
	input_queue.execute(frame, input_actions)
	weapon_data.attack_end = WeaponData.ATTACK_END.NONE
	var current_state = attack_sequence_map[weapon_data.attack_sequence]
	if not weapon_data.is_executing:
		_on_attack_start(frame, input_actions, stamina)
	#if current_state != STATES.ANTICIPATION:
	_attack_logic(frame, current_state, input_actions, stamina)
	advance_state(frame)
	move_with_speed_mod(frame)
	if weapon_data.attack_end != WeaponData.ATTACK_END.NONE:
		_on_attack_end(frame, stamina)

func _on_attack_start(frame : int, input_actions : InputActions, stamina) -> void:
	stamina.reset_and_stop_timers(frame)
	weapon_data.is_executing = true
	_start_anticipation(frame, input_actions)

func _attack_logic(frame : int, current_state : int, input_actions : InputActions, stamina) -> void:
	if current_state == STATES.ANTICIPATION:
		_anticipation(frame, input_actions, stamina)
	elif current_state == STATES.ATTACK:
		_attack(frame, input_actions, stamina)
	elif current_state == STATES.PREFINISHER:
		_prefinisher(frame, input_actions, stamina)
	elif current_state == STATES.FINISHER:
		_finisher(frame, input_actions)
	elif current_state == STATES.CHARGING:
		_charging(frame, input_actions)
	elif current_state == STATES.CHARGE_ATTACK:
		_charge_attack(frame, input_actions)
	elif current_state == STATES.COMBO:
		_combo(frame, input_actions)
	else:
		assert(false) #,"Invalid state")

func _anticipation(frame : int, input_actions : InputActions, stamina, soft_reset = false) -> void:
	#if not weapon_data.animation_frame == 0:
	#	input_queue.execute(frame, input_actions)
	var has_advanced = _update_anticipation_advance_conditions(frame, input_actions, stamina)

func _update_anticipation_advance_conditions(frame : int, input_actions : InputActions, stamina) -> bool:
	if weapon_data.combo_to_occur:
		return _update_anticipation_combo_advance_conditions(frame, input_actions, stamina)
	else:
		return _update_attack_advance_conditions(frame, input_actions, stamina)

func _update_anticipation_combo_advance_conditions(frame : int, input_actions : InputActions, stamina) -> bool:
	if not input_queue.queued_input_is(weapon_data.input_to_check):
		advance_to_combo(frame, input_actions, stamina)
		return true
	else:
		return _update_anticipation_combo_advance_conditions_with_input(frame, input_actions, stamina)

func _update_anticipation_combo_advance_conditions_with_input(frame : int, input_actions : InputActions, stamina) -> bool:
	if input_queue.data_container.is_released:
		Logging.log_line("Advancing to combo after the input is released")
		advance_to_combo(frame, input_actions, stamina)
		return true
	elif input_queue.data_container.held_frames >= FRAMES_HELD_BEFORE_CHARGE:
		# perform the stamina check. If the stamina check fails advance
		weapon_data.combo_to_occur = false
		return _advance_to_charging_if_stamina(frame, input_actions, stamina)
	else:
		return false

func _start_anticipation(frame : int, input_actions : InputActions, soft_reset = false) -> void:
	reset_data(frame, soft_reset)
	reset_state_machine()
	_start_animation("Anticipation")
	set("parameters/Seek/seek_position", 0.0)
	#super.advance(step_time)
	_set_attack_direction(weapon_data, input_actions.get_looking_vector())
	#advance_state(frame)
	if not soft_reset:
		input_queue.set_queued_input(frame, weapon_data.input_to_check)
		input_queue.execute(frame, input_actions)

func _attack(frame : int, input_actions : InputActions, stamina) -> void:
	var has_advanced = _update_attack_advance_conditions(frame, input_actions, stamina)
	if not has_advanced and weapon_data.main_animation_ended:
		_to_end_attack(frame)

func _update_attack_advance_conditions(frame : int, input_actions : InputActions, stamina) -> bool:
	if weapon_data.main_animation_ended and input_queue.queued_input_is(weapon_data.input_to_check):
		return _on_same_attack_input_queued(frame, input_actions, stamina)
	elif weapon_data.main_animation_ended and input_queue.is_input_queued():
		_set_end_animation_result()
		return true
	return false

func _on_same_attack_input_queued(frame : int, input_actions : InputActions, stamina) -> bool:
	if input_queue.data_container.is_released:
		return _advance_to_next_attack(frame, input_actions)
	elif input_queue.data_container.held_frames >= FRAMES_HELD_BEFORE_CHARGE and not weapon_data.stamina_check_occured:
		# perform the stamina check. If the stamina check fails advance
		return _advance_to_charging_if_stamina(frame, input_actions, stamina)
	return false

func _advance_to_next_attack(frame : int, input_actions : InputActions) -> bool:
	var next_attack_sequence = weapon_data.attack_sequence + 1
	if next_attack_sequence != weapon_data.max_sequence:
		_advance_to_attack(frame, input_actions, next_attack_sequence)
		return true
	else:
		assert(false) #,"not sure how we got here")
		return false

func _advance_to_charging_if_stamina(frame : int, input_actions : InputActions, stamina, next_attack_on_fail = true) -> bool:
	weapon_data.stamina_check_occured = true
	if stamina.execute(frame, weapon_data.charge_stamina_cost, false) :
		_advance_to_charging(frame, input_actions)
		return true
	elif next_attack_on_fail:
		var next_attack_sequence = weapon_data.attack_sequence + 1
		_advance_to_attack(frame, input_actions, next_attack_sequence)
		return true
	return false

func _advance_to_attack(frame : int, input_actions : InputActions, attack_n : int, seek_pos : float = 0.0) -> void:
	reset_data(frame)
	_start_animation("Attack_" + str(attack_n), seek_pos)
	weapon_data.attack_sequence = attack_n
	_set_attack_direction(weapon_data, input_actions.get_looking_vector())

func _advance_to_charging(frame : int, input_actions : InputActions, seek_pos : float = 0.0) -> void:
	weapon_data.soft_reset()
	_start_animation("Charging", seek_pos)
	weapon_data.attack_sequence = weapon_data.max_sequence + 1
	_set_attack_direction(weapon_data, input_actions.get_looking_vector())

func _to_end_attack(frame : int) -> void:
	if !input_queue.queued_input_is(weapon_data.input_to_check) and input_queue.is_input_queued():
		_set_end_animation_result()
	elif input_queue.queued_input_is(weapon_data.input_to_check):
		# do nothing
		pass
	elif check_for_attack_end():
		_set_end_animation_result()

# This one has a special end condition, because if we have failed the stamina check for either charge or finisher,
# then we wait until the end of the attack to go back to anticipation
func _prefinisher(frame : int, input_actions : InputActions, stamina) -> void:
	var has_advanced = _update_prefinisher_advance_conditions(frame, input_actions, stamina)
	if not has_advanced:
		_to_end_prefinisher(frame, input_actions)

func _update_prefinisher_advance_conditions(frame : int, input_actions : InputActions, stamina) -> bool:
	if weapon_data.main_animation_ended and not weapon_data.stamina_check_occured and input_queue.queued_input_is(weapon_data.input_to_check):
		return _advance_to_finisher_or_charging_if_stamina(frame, input_actions, stamina)
	return false

func _advance_to_finisher_or_charging_if_stamina(frame : int, input_actions : InputActions, stamina) -> bool:
	if input_queue.data_container.is_released:
		weapon_data.stamina_check_occured = true
		if stamina.execute(frame, weapon_data.stamina_cost, false):
			_advance_to_finisher(frame, input_actions)
			return true
	elif input_queue.data_container.held_frames >= FRAMES_HELD_BEFORE_CHARGE:
		return _advance_to_charging_if_stamina(frame, input_actions, stamina, false)
	return false

func _advance_to_finisher(frame : int, input_actions : InputActions, seek_pos : float = 0.0) -> void:
	reset_data(frame)
	_start_animation("Finisher", seek_pos)
	weapon_data.attack_sequence = weapon_data.max_sequence
	_set_attack_direction(weapon_data, input_actions.get_looking_vector())

func _to_end_prefinisher(frame : int, input_actions : InputActions) -> void:
	var attack_ended = check_for_attack_end()
	if attack_ended and not input_queue.queued_input_is(weapon_data.input_to_check):
		_set_end_animation_result()
	elif attack_ended and input_queue.queued_input_is(weapon_data.input_to_check) and weapon_data.stamina_check_occured:
		advance_to_anticipation(frame, input_actions)

func _finisher(frame : int, input_actions : InputActions) -> void:
	var has_advanced = _update_finisher_advance_conditions(frame, input_actions)
	if not has_advanced and weapon_data.main_animation_ended:
		_to_end_finisher(frame, input_actions)

func _update_finisher_advance_conditions(frame : int, input_actions : InputActions) -> bool:
	if weapon_data.main_animation_ended and input_queue.is_input_queued():
		return _finisher_advance_conditions_with_input(frame, input_actions)
	return false

func _finisher_advance_conditions_with_input(frame : int, input_actions : InputActions) -> bool:
	if input_queue.queued_input_is(weapon_data.input_to_check):
		# Save the inputs and hand it off to anticipation
		advance_to_anticipation(frame, input_actions, 0, false)
		#_advance_to_attack(frame, input_actions, 1)
		return true
	else:
		_set_end_animation_result(WeaponData.ATTACK_END.END, true)
		return true

func _to_end_finisher(frame : int, input_actions : InputActions) -> void:
	if check_for_attack_end():
		_set_end_animation_result(WeaponData.ATTACK_END.END, true)

func advance_to_anticipation(frame : int, input_actions : InputActions, seek_pos : float = 0.0, combo_to_occur : bool = false) -> void:#, set_input_to_weapon_input = true) -> void:
	_start_animation("Anticipation", seek_pos)
	weapon_data.reset(true)
	_set_attack_direction(weapon_data, input_actions.get_looking_vector())
	weapon_data.is_executing = true
	if combo_to_occur:
		weapon_data.combo_to_occur = true
	#if set_input_to_weapon_input:
	#	input_queue.set_queued_input(frame, weapon_data.input_to_check)

func _charging(frame : int, input_actions : InputActions) -> void:
	_set_attack_direction(weapon_data, input_actions.get_looking_vector())
	_update_charging_advance_conditions(frame, input_actions)

func _update_charging_advance_conditions(frame : int, input_actions : InputActions):
	if weapon_data.main_animation_ended and input_queue.data_container.is_released:
		_advance_to_charge_attack(frame, input_actions)

func _advance_to_charge_attack(frame : int, input_actions : InputActions, seek_pos : float = 0.0)-> void:
	_start_animation("ChargeAttack", seek_pos)
	reset_data(frame)
	weapon_data.attack_sequence = weapon_data.max_sequence + 2
	_set_attack_direction(weapon_data, input_actions.get_looking_vector())

func _charge_attack(frame : int, input_actions : InputActions) -> void:
	var has_advanced = _update_charge_attack_advance_conditions(frame, input_actions)
	if not has_advanced and weapon_data.main_animation_ended:
		_to_end_finisher(frame, input_actions)

func _update_charge_attack_advance_conditions(frame : int, input_actions : InputActions) -> bool:
	if weapon_data.main_animation_ended and input_queue.queued_input_is(weapon_data.input_to_check):
		advance_to_anticipation(frame, input_actions)
		return true
	return false

func advance_to_combo(frame : int, input_actions : InputActions, stamina, seek_pos : float = 0.0) -> void:
	weapon_data.combo_to_occur = false
	if stamina.execute(frame, weapon_data.combo_stamina_cost, false):
		_advance_to_combo(frame, input_actions, seek_pos)
	else:
		#advance_to_anticipation(frame, input_actions)
		_advance_to_attack(frame, input_actions, 1)
	weapon_data.is_executing = true

func _advance_to_combo(frame : int, input_actions : InputActions, seek_pos : float = 0.0) -> void:
	Logging.log_line("Combo is starting and input queue is to be reset")
	_start_animation("Combo", seek_pos)
	reset_data(frame)
	weapon_data.attack_sequence = weapon_data.get_combo_sequence()
	_set_attack_direction(weapon_data, input_actions.get_looking_vector())

func _combo(frame : int, input_actions : InputActions) -> void:
	var has_advanced = _update_finisher_advance_conditions(frame, input_actions)
	if not has_advanced and weapon_data.main_animation_ended:
		_to_end_finisher(frame, input_actions)

func move_with_speed_mod(frame : int):
	var move_component = weapon.entity.get_component("Move")
	var vel = move_component.max_speed * weapon_data.attack_direction * weapon_data.speed_mod
	move_component.execute_fixed_velocity(frame, weapon.entity, vel)

func _on_attack_end(frame : int, stamina) -> void:
	stamina.reset_timers(frame)
	weapon_data.hard_reset()
	reset_state_machine()

func reset_to_weapon_data() -> void:
	# TO DO -> Do we need to reset the weapon data here? Won't the weapon handle this?
	var seek_position = weapon_data.animation_frame * step_time
	var reset_state = attack_sequence_map[weapon_data.attack_sequence]
	_set_attack_direction(weapon_data, weapon_data.attack_direction)
	if reset_state == STATES.ANTICIPATION:
		_start_animation("Anticipation", seek_position)
	elif reset_state == STATES.ATTACK or reset_state == STATES.PREFINISHER:
		_start_animation("Attack_" + str(weapon_data.attack_sequence), seek_position)
	elif reset_state == STATES.FINISHER:
		_start_animation("Finisher", seek_position)
	elif reset_state == STATES.CHARGING:
		_start_animation("Charging", seek_position)
	elif reset_state == STATES.CHARGE_ATTACK:
		_start_animation("ChargeAttack", seek_position)
	elif reset_state == STATES.COMBO:
		_start_animation("Combo", seek_position)
	else:
		assert(false) #,"Debug, this should never happen")

func _init_attack_sequence_map():
	attack_sequence_map[0] = STATES.ANTICIPATION
	for i in range(1, weapon_data.max_sequence - 1):
		attack_sequence_map[i] = STATES.ATTACK
	attack_sequence_map[weapon_data.max_sequence - 1] = STATES.PREFINISHER
	attack_sequence_map[weapon_data.max_sequence] = STATES.FINISHER
	attack_sequence_map[weapon_data.max_sequence + 1] = STATES.CHARGING
	attack_sequence_map[weapon_data.max_sequence + 2] = STATES.CHARGE_ATTACK
	attack_sequence_map[weapon_data.max_sequence + 3] = STATES.COMBO
