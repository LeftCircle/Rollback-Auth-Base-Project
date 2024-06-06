extends AnimationPlayer
class_name PlayerAnimations

@export var sprite_container_path: NodePath

var previous_animation : String

@onready var player_sprites = get_node(sprite_container_path)

func get_current_animation_length_frames():
	return current_animation_length / CommandFrame.frame_length_sec

func advance_animations():
	#if previous_animation == animation_player.current_animation:
	advance(CommandFrame.frame_length_sec)
	#previous_animation = animation_player.current_animation

func animate(animation : String, flip_h : bool = false) -> void:
	var sprite = player_sprites.get_node(animation)
	if flip_h:
		sprite.scale.x = -abs(sprite.scale.x)
	else:
		sprite.scale.x = abs(sprite.scale.x)
	player_sprites.show_sprite_node(sprite)
	play(animation)
	advance(0)


func animation_on_frame_zero() -> bool:
	var frame = current_animation_position / CommandFrame.frame_length_sec
	return frame < 1
