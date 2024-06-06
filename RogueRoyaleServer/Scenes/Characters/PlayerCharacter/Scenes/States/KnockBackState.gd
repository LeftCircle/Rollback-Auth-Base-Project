extends BasePlayerState
class_name KnockBackPlayerState

@export var knockbapck_component_path: NodePath

@onready var knockback_component = get_node(knockbapck_component_path)

func _ready():
	state_enum = PlayerStateManager.KNOCKBACK

func physics_process(frame : int, input_actions : InputActions, args = {}):
	if not knockback_component.execute(frame, entity):
		state_machine.switch_state(frame, PlayerStateManager.IDLE, input_actions, args)
