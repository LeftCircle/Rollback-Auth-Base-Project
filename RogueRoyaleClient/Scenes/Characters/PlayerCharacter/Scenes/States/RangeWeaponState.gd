extends BasePlayerState
class_name RangeWeaponState

#var ranged_weapon
#
#func init(new_entity) -> void:
#	entity = new_entity
#
#func set_ranged_weapon(new_weapon) -> void:
#	ranged_weapon = new_weapon

#func _ready():
#	state_enum = PlayerStateManager.RANGE_WEAPON
#	set_physics_process(false)
#
#func physics_process(frame : int, input_actions : InputActions, args = {}):
#	var new_state = check_for_state_change(input_actions)
#	if new_state != PlayerStateManager.RANGE_WEAPON:
#		ranged_weapon.holster()
#		state_machine.switch_state(new_state, input_actions, args)
#		return
#	ranged_weapon.execute(input_actions)
#
#func check_for_state_change(input_actions : InputActions) -> int:
#	if input_actions.is_action_just_pressed("dodge"):
#		return PlayerStateManager.ROLL
#	elif input_actions.is_action_just_released("draw_ranged_weapon"):
#		return PlayerStateManager.IDLE
#	return PlayerStateManager.RANGE_WEAPON
#
##func check_for_state_change(input_actions : InputActions) -> int:
##	if _check_for_state_change(PlayerStateManager.ROLL, input_actions):
##		return PlayerStateManager.ROLL
##	elif input_actions.is_action_just_released("draw_ranged_weapon"):
##		return PlayerStateManager.IDLE
##	return PlayerStateManager.RANGE_WEAPON
#
##func _on_execution_finished(new_state : int, input_actions : InputActions):
##	entity.state = new_state
##	entity.set_physics_process(true)
##	set_physics_process(false)
##	ranged_weapon.execution_finished()
#
