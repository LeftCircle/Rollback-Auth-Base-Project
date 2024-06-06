extends AnimationPlayer
class_name ManualAnimationPlayer

var to_log = false

func advance(time : float) -> void:
	if to_log:
		Logging.log_line("Shield current " + str(current_animation_position) + " vs length " + str(current_animation_length - time))
	if abs(current_animation_position - current_animation_length - time) < 0.001:
		return
	super.advance(time)
	if to_log:
		Logging.log_line("Shield animation = " + current_animation + " pos " + str(current_animation_position))
