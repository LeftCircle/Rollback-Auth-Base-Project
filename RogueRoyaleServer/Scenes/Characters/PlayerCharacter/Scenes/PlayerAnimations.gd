extends AnimationPlayer
class_name PlayerAnimations

var active_animation : String

func _ready():
	pass

func _physics_process(delta):
	pass

func advance_animations():
	advance(CommandFrame.frame_length_sec)

func animate(animation : String, flip_h : bool = false) -> void:
	play(animation)

func animation_on_frame_zero() -> bool:
	var frame = current_animation_position / CommandFrame.frame_length_sec
	return frame < 1
