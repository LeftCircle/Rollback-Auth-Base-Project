#################################################
######   ALL THE SAME EXCEPT EXTENDS        #####
#################################################
extends BaseStateSystem
class_name BaseAttackStateSystem

func _init_required_component_groups():
	required_component_groups = ["Move", "Weapon", "Stamina", "InputQueue", "StateSystem"]

func execute(frame : int) -> void:
	super.execute(frame)
	for entity in registered_entities:
		var input_queue : InputQueueComponent = entity.get_component("InputQueue")
		var weapon = _get_weapon(entity)
		_entity_attack(frame, entity, weapon)
		check_for_exit(frame, entity, weapon, input_queue)

func _get_weapon(entity):
	assert(false, "Must be overwritten")

func _entity_attack(frame : int, entity, weapon) -> void:
	weapon.execute(frame, entity.input_actions)

func check_for_exit(frame : int, entity, weapon, input_queue : InputQueueComponent) -> void:
	# Check for combos and weapon switches based on the attack end and the current state of the player
	var entity_state_component : StateSystemState = entity.get_component("StateSystem")
	if input_queue.queued_input_is("dodge"):
			switch_state_system(frame, entity, DodgeStateSystem)
			input_queue.reset(frame)
	elif weapon.weapon_data.attack_end == WeaponData.ATTACK_END.END:
		switch_state_system(frame, entity, MoveStateSystem)
		input_queue.reset(frame)
	elif weapon.weapon_data.attack_end == WeaponData.ATTACK_END.COMBO_PRIMARY:
		entity_state_component.set_state(frame, SystemController.STATES.ATTACK_PRIMARY)
		# We aren't exiting the state, so we do not have to reset the input queue
		entity.primary_weapon.start_anticipation_for_combo(frame, entity.input_actions)
		# We execute to trigger the netcode send
		entity.primary_weapon.execute(frame, entity.input_actions)
	elif weapon.weapon_data.attack_end == WeaponData.ATTACK_END.COMBO_SECONDARY:
		entity_state_component.set_state(frame, SystemController.STATES.ATTACK_SECONDARY)
		entity.secondary_weapon.start_anticipation_for_combo(frame, entity.input_actions)
		entity.secondary_weapon.execute(frame, entity.input_actions)
	elif weapon.weapon_data.attack_end == WeaponData.ATTACK_END.PRIMARY:
		entity_state_component.set_state(frame, SystemController.STATES.ATTACK_PRIMARY)
		entity.primary_weapon.start_anticipation(frame, entity.input_actions)
		entity.primary_weapon.execute(frame, entity.input_actions)
	elif weapon.weapon_data.attack_end == WeaponData.ATTACK_END.SECONDARY:
		entity_state_component.set_state(frame, SystemController.STATES.ATTACK_SECONDARY)
		entity.secondary_weapon.start_anticipation(frame, entity.input_actions)
		entity.secondary_weapon.execute(frame, entity.input_actions)

#func on_exit_state(frame : int, entity) -> void:
#	# disable the weapons!
#	var primary_weapon = entity.get_primary_weapon()
#	var secondary_weapon = entity.get_secondary_weapon()
#	primary_weapon.end_execution(frame)
#	secondary_weapon.end_execution(frame)
