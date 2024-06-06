#################################################
######   SHARED BETWEEN CLIENT AND SERVER   #####
#################################################
extends BaseAttackStateSystem

func _init_state_system_int():
	state_system_int = SystemController.STATES.ATTACK_PRIMARY

func _get_weapon(entity):
	return entity.get_primary_weapon()

func check_for_exit(frame : int, entity, weapon, input_queue : InputQueueComponent) -> void:
	# Check for combos and weapon switches based on the attack end and the current state of the player
	if entity.input_actions.is_action_just_pressed("dodge") or input_queue.queued_input_is("dodge"):
		switch_state_system(frame, entity, DodgeStateSystem)
		input_queue.reset(frame)
	elif weapon.weapon_data.attack_end == WeaponData.ATTACK_END.END:
		switch_state_system(frame, entity, MoveStateSystem)
		input_queue.reset(frame)
	elif weapon.weapon_data.attack_end == WeaponData.ATTACK_END.COMBO_PRIMARY:
		assert(false, "We should never reach this state from primary weapon")
	elif weapon.weapon_data.attack_end == WeaponData.ATTACK_END.COMBO_SECONDARY:
		switch_state_system(frame, entity, AttackSecondaryStateSystem)
		entity.secondary_weapon.start_anticipation_for_combo(frame, entity.input_actions)
		entity.secondary_weapon.execute(frame, entity.input_actions)
	elif weapon.weapon_data.attack_end == WeaponData.ATTACK_END.PRIMARY:
		assert(false, "Should never reach this state from primary weapon")
	elif weapon.weapon_data.attack_end == WeaponData.ATTACK_END.SECONDARY:
		switch_state_system(frame, entity, AttackSecondaryStateSystem)
		entity.secondary_weapon.start_anticipation(frame, entity.input_actions)
		entity.secondary_weapon.execute(frame, entity.input_actions)

func on_exit_state(frame : int, entity) -> void:
	var primary_weapon = entity.get_primary_weapon()
	primary_weapon.end_execution(frame)
