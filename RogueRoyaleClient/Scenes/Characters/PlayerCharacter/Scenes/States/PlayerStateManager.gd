extends BaseStateMachine
class_name PlayerStateManager

enum {IDLE, RUN, DASH, ROLL, ATTACK_PRIMARY, ATTACK_SECONDARY, RANGE_WEAPON, HEALING_FLASK,
	KNOCKBACK, NULL}

func _ready():
	state_group_name = "PlayerState"

func physics_process(frame : int, input_actions : InputActions, args = {}):
	states[current_state].physics_process(frame, input_actions, args)
