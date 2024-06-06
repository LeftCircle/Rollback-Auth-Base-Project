extends AnimationPlayer
class_name RollbackAnimationPlayer

@export var to_log: bool = false

var step_time = CommandFrame.frame_length_sec
var history = RollbackAnimationLoopingArray.new()

func _ready():
	set_process_callback(AnimationPlayer.ANIMATION_PROCESS_MANUAL)
	add_to_group("RollbackAnimationPlayers")
	#method_call_mode = AnimationPlayer.ANIMATION_METHOD_CALL_IMMEDIATE
#	if get_parent().name == "StarterShield":
#		to_log = true

func play_rollback(anim : String =  "", custom_blend : float = -1.0, custom_speed : float = 1.0, from_end : bool = false) -> void:
	if current_animation == "":
		var animation = get_animation(anim)
		if not animation.loop_mode:
			var last_anim = get_assigned_animation()
			if last_anim == anim:
				# Do not loop animations that shouldn't!
				return
	super.play(anim, custom_blend, custom_speed, from_end)

func rollback_advance(frame : int, time : float = step_time) -> void:
	super.advance(time)
	if to_log:
		Logging.log_line("rollback animation = " + current_animation + " pos " + str(current_animation_position))
	if current_animation == "":
		Logging.log_line("CURRENT ANIMATION IS NONE")
	history.add_data(frame, self)

func rollback_to_start_of_frame(frame : int) -> void:
	reset()
	var frame_to_go_to = CommandFrame.get_previous_frame(frame)
	var data = history.retrieve_data(frame_to_go_to)
	_set_to_rollback_data(data)

func rollback_to_end_of_frame(frame : int) -> void:
#	if to_log:
#		Logging.log_line("Resetting to end of frame " + str(frame))
	reset()
	var data = history.retrieve_data(frame)
	_set_to_rollback_data(data)

func reset_to(animation : String, anim_frame : int) -> void:
#	play(animation)
#	var anim_pos = anim_frame * step_time
#	seek(0, true)
#	advance(0)
	get_parent().hide()
	play_rollback(animation)
	stop()
	var anim_pos = anim_frame * step_time
	seek(0)
	advance(0)
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

func reset():
	play_rollback("RESET")
	advance(0)

func _set_to_rollback_data(data : RollbackAnimationData) -> void:
	reset_to(data.current_animation, data.current_animation_frame)

func get_animation_frame_length() -> int:
	return int(round(current_animation_length / CommandFrame.frame_length_sec))

func _on_rollback(frame : int) -> void:
	rollback_to_end_of_frame(frame)

func log_animations():
	Logging.log_line("Animations: ")
	Logging.log_line("Current animation = " + current_animation + " position = " + str(current_animation_position))
