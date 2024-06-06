extends Node
class_name RemoteStateMachine

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

func switch_state(state : int) -> void:
	if states.has(state):
		states[current_state].exit()
		states[state].enter()
		current_state = state

func physics_process(state : int):
	# We only want to physics_process if it is a valid state
	if states.has(state):
		if state != current_state:
			switch_state(state)
		states[current_state].physics_process()

func set_current_state(state : int) -> void:
	current_state = state

