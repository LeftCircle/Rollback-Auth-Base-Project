extends ServerNetcodeModule
class_name DashModular

signal dash_finished(frame)
signal failed_to_execute(frame)

@export var animation_player_path: NodePath
@export var stamina_path: NodePath
@export var move_path: NodePath

@export var dash_speed = 1500 # (int, 0, 10000)
@export var dash_seconds = 0.5 # (float, 0, 1)
@export var stamina_cost = 1 # (int, 0, 10)

# dash_frames are easier to send over netcode than seconds
var dash_frames : int = 0
var dash_direction : Vector2
var current_dash_frames = 0
var is_dashing = false
var velocity : Vector2 = Vector2.ZERO

@onready var animation_player = get_node(animation_player_path)
@onready var stamina = get_node(stamina_path)
@onready var move = get_node(move_path)

func _netcode_init():
	netcode.init(self, "DSH", DashModuleData.new(), DashModuleCompression.new())

func _ready():
	dash_frames = float(int(dash_seconds / CommandFrame.frame_length_sec))
	set_physics_process(false)

func reset():
	is_dashing = false
	current_dash_frames = 0
	dash_direction = Vector2.ZERO

func is_dash_over() -> bool:
	return current_dash_frames >= dash_frames

func execute(frame : int, entity, input_actions: InputActions):
	if not is_dashing:
		dash_direction = input_actions.get_looking_vector()
		if stamina.execute(frame, stamina_cost):
			_perform_dash(frame, entity)
			is_dashing = true
		else:
			reset()
			emit_signal("failed_to_execute", frame)
	else:
		_perform_dash(frame, entity)

func _perform_dash(frame, entity):
	velocity = dash_speed * dash_direction
	current_dash_frames += 1
	if is_dash_over():
		reset()
		emit_signal("dash_finished", frame)
		move.execute_fixed_velocity(frame, entity, Vector2.ZERO)
	else:
		is_dashing = true
		move.execute_fixed_velocity(frame, entity, velocity)

# Needs to be set up for if the dash is interrupted
func end_execution(frame : int):
	reset()
