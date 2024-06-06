extends BaseWeapon
class_name BaseClientWeapon

var fx_history = FXHistory.new()
var is_in_misspredict : bool = false

@onready var node_interpolater = $NodeInterpolater as NodeInterpolater

func _ready():
	super._ready()
	visible = false

func set_attack_direction(direction : Vector2) -> void:
	super.set_attack_direction(direction)
	node_interpolater.global_rotation = 0

func decompress(frame : int, bit_packer : OutputMemoryBitStream) -> void:
	Logging.log_line("Received data for:")
	log_component(frame)
	if not is_lag_comp:
		var server_hist = netcode.state_compresser.decompress(bit_packer, netcode)
		server_hist.frame = frame
		var matches = history.server_matches_history(server_hist)
		if not matches:
			emit_signal("frame_to_reset_to", frame)
			MissPredictFrameTracker.add_reset_frame(frame)
			#Logging.log_line("Missprediction for below component:")
	else:
		var server_hist = netcode.state_compresser.decompress(bit_packer, netcode)
		server_hist.frame = frame
		history.add_data(frame, server_hist)
		call_deferred("reset_to_frame", frame)
		#reset_to_frame(frame)

func reset_to_frame(frame : int) -> void:
	var hist = history.retrieve_data(frame)
	if not hist == BaseModularHistory.NO_DATA_FOR_FRAME:
		var was_executing = weapon_data.is_executing == true
		hist.set_obj_with_data(weapon_data)
		if was_executing and not weapon_data.is_executing:
			end_execution(frame)
		if weapon_data.is_executing == false and weapon_data.animation_frame == 0:
			animation_tree.reset_state_machine()
		else:
			animation_tree.reset_to_weapon_data()
		interpolate_sprites(global_position)

func reset_to(data) -> void:
	data.set_obj_with_data(weapon_data)
	if weapon_data.is_executing == false and weapon_data.animation_frame == 0:
		animation_tree.reset_state_machine()
	else:
		#set_attack_direction(weapon_data.attack_direction)
		animation_tree.reset_to_weapon_data()

func interpolate_sprites(global_pos : Vector2):
	node_interpolater.ready_next_frame(global_pos)

func set_is_in_misspredict(frame : int):
	is_in_misspredict = CommandFrame.frame != frame

func get_attack_animation() -> String:
	return animation_tree.attack_sequence_to_animation[weapon_data.attack_sequence]

func save_history(frame : int) -> void:
	history.add_data(frame, weapon_data)

func log_component(frame : int) -> void:
	Logging.log_line("Log data not set up for %s" % [netcode.class_id])
