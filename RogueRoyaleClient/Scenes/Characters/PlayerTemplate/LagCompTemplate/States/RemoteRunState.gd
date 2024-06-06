extends BaseRemoteState
class_name RemoteRunPlayerState

#@export var animation_path: NodePath
#
#@onready var animations = get_node(animation_path) as AnimationPlayer
#
#func _ready():
#	state_enum = RemotePlayerStateManager.RUN
#
#func physics_process():
#	on_run()
#
#func on_run():
#	animations.play("Run")
#	animations.advance(CommandFrame.frame_length_sec)
