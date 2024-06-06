extends BaseDagger
class_name ClientDagger

@export var to_log: bool = false
@export var sword_woosh: Resource

#var audio_wav = preload("res://Assets/SFX/Sword Sounds Pro/Sword Wooshes/Sword Woosh 12.wav")

@onready var strike = $NodeInterpolater/Strike
@onready var third_strike = $NodeInterpolater/ThirdStrike

func decompress(frame : int, bit_packer : OutputMemoryBitStream) -> void:
	Logging.log_line("Received data for:")
	log_component(frame)
	if not is_lag_comp:
		var server_hist = netcode.state_compresser.decompress(bit_packer, netcode)
		server_hist.frame = frame
		var matches = history.server_matches_history(server_hist)
		if not matches:
			#print(self.name, " does not match on frame ", frame)
			emit_signal("frame_to_reset_to", frame)
			MissPredictFrameTracker.add_reset_frame(frame)
	else:
		var server_hist = netcode.state_compresser.decompress(bit_packer, netcode)
		server_hist.frame = frame
		history.add_data(frame, server_hist)
		#reset_to_frame(frame)
		call_deferred("reset_to_frame", frame)

func _init():
	super._init()
	history = MeleeWeaponHistory.new()
	history.to_log = to_log

func execute(frame : int, input_actions : InputActions) -> int:
	super.execute_tree(frame, input_actions, weapon_data)
	#visible = weapon_data.attack_end == WeaponData.ATTACK_END.NONE
	interpolate_sprites(global_position)
	netcode.on_client_update(frame)
	Logging.log_line("Animation frame = " + str(weapon_data.animation_frame) + " frame = " + str(frame))
	return weapon_data.attack_end

func physics_process(frame : int, input_actions : InputActions) -> void:
	# TO DO -> We might not need this?
#	history.add_data(frame, weapon_data)
	interpolate_sprites(global_position)

func end_execution(frame : int):
	#hide()
	super.end_execution(frame)
	netcode.on_client_update(frame)

func set_attack_direction(direction : Vector2) -> void:
	super.set_attack_direction(direction)
	var radians = direction.angle()
	strike.global_rotation = radians
	third_strike.global_rotation = radians


func animation_logger(ani_frame : int):
	Logging.log_line("Animation is currently being played at pos " + str(animation_player.current_animation_position) + " Frame = " + str(ani_frame))

func debug_anim_frame(ani_frame : int) -> void:
	#print("Animation just played frame ", ani_frame)
	pass

func debug_animation_played(anim : String) -> void:
	#print("Just started " + anim)
	#print("WeaponData.speed_mod = ", weapon_data.speed_mod)
	pass

func save_history(frame : int) -> void:
	history.add_data(frame, weapon_data)
	Logging.log_line("Saving dagger history for frame " + str(frame) + " Animation frame = " + str(weapon_data.animation_frame))
