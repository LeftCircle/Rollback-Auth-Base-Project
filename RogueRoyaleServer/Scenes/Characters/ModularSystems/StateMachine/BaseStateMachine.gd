extends Node
class_name BaseStateMachine

@export var entity_path: NodePath
@export var animation_path: NodePath
@export var state_group_name: String

var states = {}
var current_state = 0

@onready var entity = get_node(entity_path)

func _ready():
	for child in get_children():
		if child.is_in_group(state_group_name):
			child.entity = entity
			child.state_machine = self
			states[child.state_enum] = child

func switch_state(frame : int, state : int, input_actions : InputActions, args = {}) -> void:
	states[current_state].exit(0)
	states[state].enter(frame, input_actions, args)
	current_state = state
	Logging.log_line("Switching state to " + str(state) + str(" on frame ") + str(CommandFrame.frame))

func physics_process(frame : int, input_actions : InputActions, args = {}):
	states[current_state].physics_process(input_actions, frame, args)

func set_current_state(frame : int, state : int, init_args = []) -> void:
	Logging.log_line("Setting current state to " + str(state) + " on frame " + str(CommandFrame.frame))
	states[current_state].exit(frame)
	current_state = state
	if not init_args.is_empty():
		states[current_state].init(init_args)
