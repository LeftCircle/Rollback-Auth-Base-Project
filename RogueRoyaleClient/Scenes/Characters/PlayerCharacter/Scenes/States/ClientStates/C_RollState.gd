extends RollPlayerState
class_name ClientRollPlayerState

#func physics_process(frame : int, input_actions : InputActions, args = {}):
#	input_vector = input_actions.get_input_vector()
#	if not animations.current_animation == "Roll":
#		if not stamina.execute(frame, stamina_cost):
#			state_machine.switch_state(PlayerStateManager.IDLE, input_actions, args)
#			return
#	animations.play("Roll")
#	animations.rollback_advance(args[BasePlayerState.ARG_FLAGS.FRAME])
#	move.execute(frame, entity, input_vector)
