extends BaseRemoteState
class_name RemoteIdlePlayerState

#@export var animation_path: NodePath
#
#@onready var animations = get_node(animation_path) as AnimationPlayer
#
#func _ready():
#	state_enum = RemotePlayerStateManager.IDLE
#
#func physics_process():
#	on_idle()
#
#func on_idle():
#	animations.play("Idle")
#	animations.advance(CommandFrame.frame_length_sec)
