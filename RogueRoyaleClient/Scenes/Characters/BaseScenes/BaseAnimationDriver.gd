extends AnimationPlayer
class_name BaseAnimationDriver

func _ready():
	pass

func _physics_process(delta):
	pass

func advance_animations():
	advance(CommandFrame.frame_length_sec)

func animate(animation : String, flip_h : bool = false) -> void:
	play(animation)

func is_animation_on_frame_zero() -> bool:
	var frame = current_animation_position / CommandFrame.frame_length_sec
	return frame < 1
