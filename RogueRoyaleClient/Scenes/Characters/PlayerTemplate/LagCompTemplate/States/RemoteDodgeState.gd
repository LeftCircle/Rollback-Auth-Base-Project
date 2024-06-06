extends BaseRemoteState
class_name RemoteDodgeState

#@export var dodge_module_path: NodePath
#
#@onready var dodge_module = get_node(dodge_module_path)
#
#func _ready():
#	state_enum = RemotePlayerStateManager.ROLL
#
#func physics_process():
#	#dodge_module.animations.advance(CommandFrame.frame_length_sec)
#	dodge_module.animations.play("Roll")
#	dodge_module.animations.advance(CommandFrame.frame_length_sec)
#	dodge_module.animations.advance(CommandFrame.frame_length_sec)
