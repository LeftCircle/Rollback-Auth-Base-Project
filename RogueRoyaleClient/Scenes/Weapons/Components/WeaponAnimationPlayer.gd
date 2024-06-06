extends AnimationPlayer
class_name WeaponAnimationPlayer

var step_time = CommandFrame.frame_length_sec

func reset_to(animation : String, anim_frame : int) -> void:
#	stop()
#	play(animation)
#	var anim_pos = anim_frame * step_time
#	seek(anim_frame)
#	advance(0)
	get_parent().hide()
	play(animation)
	#current_animation = animation
	stop()
	var anim_pos = anim_frame * step_time
	seek(0)
	advance(0)
	#seek(0, true)
	#advance(0)
	var failsafe = 0
	while abs(current_animation_position - anim_pos) > 0.001 and current_animation_position < anim_pos:
		advance(step_time)
		if failsafe == 100:
			print("Animation failsafe for " + animation + " occurs. Resetting " + animation + " anim frame = " + str(anim_frame))
			print("Current animation position = " + str(current_animation_position) + " vs pos " + str(anim_pos), " vs anim length " + str(current_animation_length))
			reset()
			break
		failsafe += 1
	get_parent().show()

func rollback_advance(_frame : int):
	advance(step_time)

func reset():
	play("RESET")
	advance(0)
