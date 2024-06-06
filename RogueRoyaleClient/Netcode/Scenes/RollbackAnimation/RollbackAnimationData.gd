extends RefCounted
class_name RollbackAnimationData

var frame : int
var current_animation : String
var current_animation_position : float = 0.0
var current_animation_frame : int = 0

#func copy(data : RollbackAnimationData):
#	frame = data.frame
#	current_animation = [data.current_animation].duplicate(true)[0]
#	current_animation_position = data.current_animation_position

func set_data(new_frame : int, anim_player : AnimationPlayer) -> void:
	frame = new_frame
	current_animation = anim_player.current_animation
	if current_animation != "":
		current_animation_position = anim_player.current_animation_position
		Logging.log_line("Animation data: " + str(frame) + " " + anim_player.current_animation + " " + str(current_animation_position))
		current_animation_frame = int(round(anim_player.current_animation_position / CommandFrame.frame_length_sec))
	else:
		current_animation_frame = 0

func set_to_reset(new_frame : int) -> void:
	frame = new_frame
	current_animation = "RESET"
	current_animation_position = 0
	current_animation_frame = 0
