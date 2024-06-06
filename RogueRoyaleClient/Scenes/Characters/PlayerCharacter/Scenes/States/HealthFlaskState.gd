extends BasePlayerState
class_name HealthFlaskState

#@export var health_path: NodePath
#@export var healing_path: NodePath
#
#@onready var health = get_node(health_path) as BaseHealth
#@onready var healing_component = get_node(healing_path) as BaseHealing
#
#func _ready():
#	state_enum = PlayerStateManager.HEALING_FLASK
#	#healing_component.connect("healing_finished",Callable(self,"_on_execution_finished"))
#
#func physics_process(frame : int, input_actions : InputActions, args = {}):
#	var new_state = check_for_state_change(input_actions)
#	if new_state != PlayerStateManager.HEALING_FLASK:
#		healing_component.end_execution()
#		state_machine.switch_state(frame, new_state, input_actions, args)
#	else:
#		if not healing_component.execute(frame):
#			state_machine.switch_state(frame, PlayerStateManager.IDLE, input_actions, args)
#
#func check_for_state_change(input_actions : InputActions):
#	if input_actions.is_action_just_pressed("dodge"):
#		return PlayerStateManager.ROLL
#	if input_actions.is_action_just_released("health_flask"):
#		return PlayerStateManager.IDLE
#	return PlayerStateManager.HEALING_FLASK
