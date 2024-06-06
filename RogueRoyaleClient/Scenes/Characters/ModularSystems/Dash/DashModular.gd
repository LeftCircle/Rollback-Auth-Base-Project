extends ClientNetcodeModule
class_name DashModular

signal dash_finished(frame)
signal failed_to_execute(frame)

@export var animation_player_path: NodePath
@export var stamina_path: NodePath
@export var move_path: NodePath

@onready var animation_player = get_node(animation_player_path)
@onready var stamina = get_node(stamina_path) as BaseStamina
@onready var move = get_node(move_path) as Move

func _netcode_init():
	netcode.init(self, "DSH", DashModuleData.new(), DashModuleCompression.new())

func _ready():
	set_physics_process(false)

func reset(set_data : DashModuleData):
	set_data.is_dashing = false
	set_data.current_dash_frames = 0
	set_data.dash_direction = Vector2.ZERO

func _is_dash_over(set_data : DashModuleData) -> bool:
	return set_data.current_dash_frames >= set_data.dash_frames

func execute_system(frame : int, entity, input_actions: InputActions, data : DashModuleData):
	if not data.is_dashing:
		data.dash_direction = input_actions.get_looking_vector()
		data.current_dash_frames = 0
		if stamina.execute(frame, data.stamina_cost):
			_perform_dash(frame, entity, data)
			data.is_dashing = true
		else:
			reset(data)
			emit_signal("failed_to_execute", frame)
	else:
		_perform_dash(frame, entity, data)

func _perform_dash(frame, entity, data : DashModuleData):
	var velocity = data.dash_speed * data.dash_direction
	data.current_dash_frames += 1
	if _is_dash_over(data):
		reset(data)
		emit_signal("dash_finished", frame)
		move.execute_fixed_velocity(frame, entity, Vector2.ZERO)
	else:
		data.is_dashing = true
		move.execute_fixed_velocity(frame, entity, velocity)
