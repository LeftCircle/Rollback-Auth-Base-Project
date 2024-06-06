extends BasePlayerState
class_name DashPlayerState

@export var dash_module_path: NodePath

@onready var dash = get_node(dash_module_path)

func _ready():
	state_enum = PlayerStateManager.DASH
	dash.connect("dash_finished",Callable(self,"_on_execution_finished"))
	dash.connect("failed_to_execute",Callable(self,"_on_execution_finished"))

func physics_process(frame : int, input_actions : InputActions, args = {}):
	check_for_state_change(input_actions)
	dash.execute(frame, entity, input_actions)

