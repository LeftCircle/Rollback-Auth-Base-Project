extends ClientNetcodeModule
class_name AnimationDrivenDodge

@export var is_invincible : bool = false
@export var animation_player : AnimationPlayer

#func _ready() -> void:
	#animation_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL 

func _init_history() -> void:
	history = DodgeHistory.new()

func _netcode_init() -> void:
	data_container = DodgeData.new()
	netcode.init(self, "ADD", data_container, DodgeCompresser.new())
	add_to_group("Dodge")

func reset_to_frame(frame : int) -> void:
	super.reset_to_frame(frame)
	var animations : LocalRollbackAnimationTree = entity.animation_tree
	var animation_time : float = data_container.animation_frame * CommandFrame.frame_length_sec
	animations.start_playing_node_at_position("Dodge", Vector2.ZERO, animation_time)



