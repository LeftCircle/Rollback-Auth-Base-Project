#################################################
######   SHARED BETWEEN CLIENT AND SERVER   #####
#################################################
extends BaseAttackStateSystem

func _init_state_system_int():
	state_system_int = SystemController.STATES.ATTACK_SECONDARY

func _get_weapon(entity):
	return entity.get_secondary_weapon()

func check_for_exit(frame : int, entity, weapon, input_queue : InputQueueComponent) -> void:
	if entity.input_actions.is_action_just_pressed("dodge") or input_queue.queued_input_is("dodge"):
		switch_state_system(frame, entity, DodgeStateSystem)
		input_queue.reset(frame)
	elif weapon.weapon_data.attack_end == WeaponData.ATTACK_END.END:
		switch_state_system(frame, entity, MoveStateSystem)
		input_queue.reset(frame)
	elif weapon.weapon_data.attack_end == WeaponData.ATTACK_END.COMBO_PRIMARY:
		switch_state_system(frame, entity, AttackPrimaryStateSystem)
		# We aren't exiting the state, so we do not have to reset the input queue
		entity.primary_weapon.start_anticipation_for_combo(frame, entity.input_actions)
		# We execute to trigger the netcode send
		entity.primary_weapon.execute(frame, entity.input_actions)
	elif weapon.weapon_data.attack_end == WeaponData.ATTACK_END.PRIMARY:
		switch_state_system(frame, entity, AttackPrimaryStateSystem)
		entity.primary_weapon.start_anticipation(frame, entity.input_actions)
		entity.primary_weapon.execute(frame, entity.input_actions)
	elif weapon.weapon_data.attack_end == WeaponData.ATTACK_END.COMBO_SECONDARY:
		assert(false, "Should never reach this from secondary weapon")
	elif weapon.weapon_data.attack_end == WeaponData.ATTACK_END.SECONDARY:
		assert(false, "Should never reach this from secondary weapon")

func on_exit_state(frame : int, entity) -> void:
	var secondary_weapon = entity.get_secondary_weapon()
	secondary_weapon.end_execution(frame)
