extends StarterShield
class_name C_StartShield

#onready var shield_sprite = $NodeInterpolater/Pivot2D/Shield
@onready var pivot = $NodeInterpolater/Pivot2D

func _init():
	super._init()
	history = ShieldHistory.new()

func execute(frame : int, input_actions : InputActions) -> int:
	#if not weapon_data.is_executing:
	#	interpolate_sprites(global_position)
	super.execute(frame, input_actions)
	#interpolate_sprites(global_position)
	netcode.on_client_update(frame)
	return weapon_data.attack_end

func end_execution(frame : int):
	super.end_execution(frame)
	netcode.on_client_update(frame)

func physics_process(frame : int, input_actions : InputActions):
	pass
	#.physics_process(frame, input_actions)
	#history.add_data(frame, weapon_data)

func reset_to_frame(frame : int) -> void:
	super.reset_to_frame(frame)
	_set_radius_from_radius_adjust()
	_set_position_from_radius()

func set_attack_direction(direction : Vector2):
	super.set_attack_direction(direction)
	pivot.rotate_radians(direction.rotated(-PI / 2.0).angle())

