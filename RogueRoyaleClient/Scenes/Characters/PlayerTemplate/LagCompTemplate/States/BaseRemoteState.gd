extends Node
class_name BaseRemoteState

#enum ARG_FLAGS{}
#
## These are set by the state machine manager
#var entity
#var state_machine
#var state_enum
#
#func _init():
#	add_to_group("RemoteState")
#
## Called when the state is entered. Any starting parameters or initializations should be set here
#func enter():
#	pass
#
## Called when the state changes. Allows a state to end any animations that could be stuck
#func exit():
#	pass
#
#func physics_process():
#	assert(false) #,"must be overridden by child class")
#
#func _on_execution_finished(frame : int, new_state : int = PlayerStateManager.IDLE):
#	state_machine.set_current_state(frame, new_state)
