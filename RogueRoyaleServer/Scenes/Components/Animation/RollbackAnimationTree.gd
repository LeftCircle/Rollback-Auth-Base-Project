extends AnimationTree
class_name RollbackAnimationTree

@export var is_looping = false

var step_time = CommandFrame.frame_length_sec
var current_blend_position : Vector2

@onready var state_machine_playback : AnimationNodeStateMachinePlayback = get("parameters/playback")
@onready var animation_player : AnimationPlayer = get_node(anim_player)

func _ready() -> void:
	is_looping = false
	set_process_callback(AnimationTree.ANIMATION_PROCESS_MANUAL)
	add_to_group("RollbackAnimationTree")

func execute(_frame : int) -> void:
	if is_looping and is_node_finished():
		var active_node : String = get_active_node()
		var blend_pos : Vector2 = get_blend_position_for(active_node)
		start_playing_node_at_position(active_node, blend_pos, 0)
	else:
		super.advance(step_time)

func start_playing_node(node_name : String, blend_pos : Vector2) -> void:
	if get_active_node() == node_name and is_looping:
		_set_blend_positions(node_name, blend_pos)
		return
	else:
		_play_reset_then_start_node(node_name, blend_pos)

func start_playing_node_at_position(node_name : String, blend_pos : Vector2, seek_position : float = 0) -> void:
	_play_reset_then_start_node(node_name, blend_pos)
	super.advance(seek_position)

func _play_reset_then_start_node(node_name : String, blend_pos : Vector2) -> void:
	state_machine_playback.stop()
	state_machine_playback.start("RESET")
	super.advance(step_time)
	_set_blend_positions(node_name, blend_pos)
	state_machine_playback.start(node_name)
	super.advance(0)

func _set_blend_positions(node_name : String, blend_pos : Vector2) -> void:
	var blend_path : String = "parameters/%s/blend_position" % [node_name]
	set(blend_path, blend_pos)
	current_blend_position = blend_pos

func get_blend_position_for(node_name : String) -> Vector2:
	var blend_path : String = "parameters/%s/blend_position" % [node_name]
	var blend_pos = get(blend_path)
	if blend_pos == null:
		return Vector2.ZERO
	else:
		return blend_pos

func get_active_node() -> String:
	return state_machine_playback.get_current_node()

func is_playing() -> bool:
	return state_machine_playback.is_playing()

func get_animation_frame() -> int:
	var length = state_machine_playback.get_current_length()
	var current_animation_position = state_machine_playback.get_current_play_position()
	return int(round(current_animation_position / step_time))

func get_current_animation_length() -> int:
	var length = state_machine_playback.get_current_length()
	return int(round(length / step_time))

func is_node_finished() -> bool:
	var length = state_machine_playback.get_current_length()
	var current_animation_position = state_machine_playback.get_current_play_position()
	#print("Animation length is %s and position is %s" % [length, current_animation_position])
	return is_equal_approx(current_animation_position, length) or current_animation_position > length


