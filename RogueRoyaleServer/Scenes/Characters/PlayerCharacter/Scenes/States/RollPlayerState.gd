extends BasePlayerState
class_name RollPlayerState

@export var dodge_module_path: NodePath

@onready var dodge_module = get_node(dodge_module_path)

func _ready():
	state_enum = PlayerStateManager.ROLL
	dodge_module.connect("finished",Callable(self,"_on_execution_finished"))

func physics_process(frame : int, input_actions : InputActions, args = {}):
	if not dodge_module.execute(frame, entity, input_actions):
		state_machine.set_current_state(frame, PlayerStateManager.IDLE)
