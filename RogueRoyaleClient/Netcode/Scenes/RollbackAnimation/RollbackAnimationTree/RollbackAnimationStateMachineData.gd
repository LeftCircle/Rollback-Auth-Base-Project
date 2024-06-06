extends RefCounted
class_name RollbackAnimationStateMachineData

var frame : int
var node_name : String
var current_animation_position : float = 0.0
var current_animation_frame : int = 0
var blend_position : Vector2

#func copy(data : RollbackAnimationData):
#	frame = data.frame
#	current_animation = [data.current_animation].duplicate(true)[0]
#	current_animation_position = data.current_animation_position

func set_data(new_frame : int, state_machine_playback : AnimationNodeStateMachinePlayback, blend_pos : Vector2) -> void:
	frame = new_frame
	node_name = state_machine_playback.get_current_node()
	blend_position = blend_pos
	if node_name != "":
		current_animation_position = state_machine_playback.get_current_play_position()
		#Logging.log_line("Animation data: " + str(frame) + " " + anim_player.current_animation + " " + str(current_animation_position))
		current_animation_frame = int(round(current_animation_position / CommandFrame.frame_length_sec))
	else:
		current_animation_frame = 0
		blend_position = Vector2.ZERO

func set_to_reset(new_frame : int) -> void:
	frame = new_frame
	node_name = "RESET"
	current_animation_position = 0
	current_animation_frame = 0
	blend_position = Vector2.ZERO
