extends RangeWeaponState
class_name C_RangeWeaponState

#func physics_process(frame : int, input_actions : InputActions, args = {}):
#	var new_state = check_for_state_change(input_actions)
#	if new_state != PlayerStateManager.RANGE_WEAPON:
#		ranged_weapon.holster()
#		state_machine.switch_state(frame, new_state, input_actions, args)
#		return
#	ranged_weapon.execute(frame, input_actions)
