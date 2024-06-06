extends Node
class_name BasePlayerState

enum ARG_FLAGS{FRAME}

var state_enum

# These are set by the state machine manager
var entity
var state_machine

func _init():
	add_to_group("PlayerState")

func enter(frame : int, input_actions : InputActions, args = {}):
	physics_process(frame, input_actions, args)

func exit(frame : int):
	pass

func physics_process(frame : int, input_actions : InputActions, args = {}):
	assert(false) #,"must be overridden by child class")

func check_for_state_change(input_actions : InputActions) -> int:
	if input_actions.is_action_just_pressed("dodge"):
		return PlayerStateManager.ROLL
	return PlayerStateManager.NULL

func _on_execution_finished(frame : int, new_state : int = PlayerStateManager.IDLE):
	state_machine.set_current_state(frame, new_state)
