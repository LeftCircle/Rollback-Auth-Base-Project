extends BasePlayerState
class_name RunPlayerState

@export var move_module_path: NodePath
@export var animation_path: NodePath

var input_vector : Vector2

@onready var move_module = get_node(move_module_path)# as Move
@onready var animations = get_node(animation_path) as AnimationPlayer

#func _ready():
#	state_enum = PlayerStateManager.RUN
#
#func physics_process(frame : int, input_actions : InputActions, args = {}):
#	input_vector = input_actions.get_input_vector()
#	var new_state = check_for_state_change(input_actions)
#	if new_state != PlayerStateManager.RUN:
#		state_machine.switch_state(frame, new_state, input_actions, args)
#		return
#	on_run(frame)
#
#func on_run(frame : int):
#	animations.play_rollback("Run")
#	animations.rollback_advance(frame)
#	move_module.execute(frame, entity, input_vector)
#	Logging.log_line("Running on frame " + str(frame) + " end position = " + str(entity.global_position))
#
#func check_for_state_change(input_actions : InputActions):
#	if input_actions.is_action_just_pressed("dodge"):
#		return PlayerStateManager.ROLL
#	elif input_actions.is_action_just_pressed("attack_primary"):
#		return PlayerStateManager.ATTACK_PRIMARY
#	elif input_actions.is_action_just_pressed("attack_secondary"):
#		return PlayerStateManager.ATTACK_SECONDARY
#	elif input_actions.is_action_just_pressed("dash"):
#		return PlayerStateManager.DASH
#	elif input_actions.is_action_just_pressed("draw_ranged_weapon"):
#		return PlayerStateManager.RANGE_WEAPON
#	elif input_actions.is_action_just_pressed("health_flask"):
#		return PlayerStateManager.HEALING_FLASK
#	elif input_vector == Vector2.ZERO:
#		return PlayerStateManager.IDLE
#	return PlayerStateManager.RUN
#
##func check_for_state_change(input_actions : InputActions):
##	if _check_for_state_change(PlayerStateManager.ROLL, input_actions):
##		return PlayerStateManager.ROLL
##	elif _check_for_state_change(PlayerStateManager.ATTACK_PRIMARY, input_actions):
##		return PlayerStateManager.ATTACK_PRIMARY
##	elif _check_for_state_change(PlayerStateManager.ATTACK_SECONDARY, input_actions):
##		return PlayerStateManager.ATTACK_SECONDARY
##	elif _check_for_state_change(PlayerStateManager.DASH, input_actions):
##		return PlayerStateManager.DASH
##	elif _check_for_state_change(PlayerStateManager.RANGE_WEAPON, input_actions):
##		return PlayerStateManager.RANGE_WEAPON
##	elif _check_for_state_change(PlayerStateManager.HEALING_FLASK, input_actions):
##		return PlayerStateManager.HEALING_FLASK
##	elif input_vector == Vector2.ZERO:
##		return PlayerStateManager.IDLE
##	return PlayerStateManager.RUN
