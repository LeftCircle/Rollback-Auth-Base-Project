extends PlayerAttackState
class_name C_AttackState

#onready var sprite_container = get_node("%SpriteContainer")
#
#func physics_process(frame : int, input_actions : InputActions, args = {}):
#	super.physics_process(frame, input_actions, args)
#	#sprite_container.visible = false
#
#func reset_exit(frame : int) -> void:
#	#sprite_container.visible = true
#	weapon.reset(frame)
#
#func exit(frame : int):
#	#sprite_container.visible = true
#	weapon.end_execution(frame)
