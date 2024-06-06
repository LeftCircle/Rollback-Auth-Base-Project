#################################################
######   SHARED BETWEEN CLIENT AND SERVER   #####
#################################################
extends Node
class_name CommandTimer

signal timeout(frame)

@export var wait_time_sec : float = 1# setget set_wait_time_sec # (float, 0, 60)
@export var autostart: bool = false
# If the timer is self driven, it advances in the _physics_process function.
# Otherwise, the timer must be advanced elsewhere (like the _physics_process of
# a parent node)
@export var self_driven: bool = true
@export var path_to_node_to_connect_to: NodePath
@export var is_system: bool = false
@export var to_debug: bool = false

var wait_frames : int
var is_running = false
var current_frames = 0

@onready var node_to_connect_to = get_node(path_to_node_to_connect_to)

func set_wait_time_sec(new_time : float) -> void:
	wait_time_sec = new_time
	wait_frames = int(round(new_time / CommandFrame.frame_length_sec))

func _ready():
	add_to_group("Timer")
	set_wait_time_sec(wait_time_sec)
	is_running = autostart
	if not self_driven:
		set_physics_process(false)

func _physics_process(delta):
	advance(CommandFrame.frame)

func advance(frame : int):
	if is_running:
		if current_frames >= wait_frames:
			reset()
			_on_time_reached(frame)
			return
		current_frames += 1

func _on_time_reached(frame : int):
	emit_signal("timeout", frame)
	current_frames = 0

func start() -> void:
	is_running = true
	current_frames = 0

#func start_system(data_to_set : TimerData) -> void:
#	data_to_set.is_running = true
#
#func stop_system(data_to_set : TimerData) -> void:
#	data_to_set.is_running = false
#
#func reset_system(data_to_set : TimerData) -> void:
#	data_to_set.is_running = autostart
#	data_to_set.current_frames = 0

func stop() -> void:
	is_running = false
	#current_frames = 0

func reset() -> void:
	is_running = autostart
	current_frames = 0

func log_timer():
	Logging.log_line("is_running = " + str(is_running) + " current_frames = " + str(current_frames) + " vs wait_frames " + str(wait_frames))

