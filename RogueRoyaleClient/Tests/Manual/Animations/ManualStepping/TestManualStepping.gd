extends Node2D

const FRAME_LENGTH : float = 1.0/60.0

var current_frame = 0
var test_counter = 0

@onready var animations : AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animations.deterministic = true
	animations.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	animations.animation_finished.connect(_on_animation_finished)

func _physics_process(delta : float) -> void:
	# manually play the test animation at frame current frame. 
	# if current frame is greater than the animation length, reset it to 0
	animations.play("Test")
	if current_frame <= 5 or current_frame >= 55:
		print("PRE ADVANCE Animation pos = %s" % [animations.current_animation_position])
		animations.advance(FRAME_LENGTH)
		print("POST ADVANCE Animation pos = %s" % [animations.current_animation_position])
	else:
		animations.advance(FRAME_LENGTH)
	current_frame += 1
	var anim_length_frames = round(animations.current_animation_length * 60)
	var anim_frame : int = round(animations.current_animation_position * 60)
	if current_frame >= 55 or current_frame <= 5:
		print("Animation pos = %s" % [animations.current_animation_position])
	if animations.current_animation_position >= animations.current_animation_length:
	#if anim_frame >= anim_length_frames:
		current_frame = 0
		print("Test counter = %s Current frame = %s animation_frame = %s animation_pos = %s" % [test_counter, current_frame, anim_frame, animations.current_animation_position])
		animations.seek(0.0)
	#print("Current animation position = %s Length = %s" % [animations.current_animation_position, animations.current_animation_length])
	#print("Current frame = %s Animation Frame = %s Frame Lenght = %s" % [current_frame, anim_frame, anim_length_frames])

func _print_animation_info() -> void:
	print("---- Animation info ----")
	print("Current animation position = %s Length = %s" % [animations.current_animation_position, animations.current_animation_length])
	print("Current frame = %s" % [current_frame])
	print("-------------------")

func _advance_test_counter() -> void:
	test_counter += 1
	print("Test counter advances")

func _on_animation_finished(anim : StringName) -> void:
	print("Animation finished %s" % [anim])
	_print_animation_info()
