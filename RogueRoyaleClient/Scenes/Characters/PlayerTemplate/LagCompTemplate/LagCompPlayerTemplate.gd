extends ClientBaseCharacter
class_name LagCompPlayerTemplate

var frame_to_execute : int

@onready var sprite_container = $NodeInterpolater/SpriteContainer
@onready var health_gui = $NodeInterpolater/TemplateGUI/OverwatchHealth

func _ready():
	_connect_signals()

func _kinematic_entity_physics_process(delta):
	pass
	# Set the player state and all modular abilities this frame
#	#var server_player_state = state_history.retrieve_data(frame_to_execute)
#	server_player_state.set_obj_with_data(self)
#	states.physics_process(state)
#	sprite_container.set_direction(looking_vector)
#	#animations.advance(delta)
#	Logging.log_line("Remote animations: *************")
#	animations.log_animations()
#	node_interp.ready_next_frame(global_position)
#	Logging.log_line("Global position for " + str(player_id) + " for frame " + str(frame_to_execute) + " = " + str(global_position))

func _state_resets(reset_frame : int) -> void:
	#component_map.reset_components_to_frame(reset_frame)
	#_reset_to_frame(reset_frame)
	pass

func decompress(frame : int, bit_packer : OutputMemoryBitStream) -> void:
	frame_to_execute = frame
	var server_player_state = netcode.state_compresser.decompress(frame, bit_packer)
	#state_history.add_data(frame, server_player_state)
	_decompress_modular_abilities(frame, server_player_state.modular_abilties_this_frame, bit_packer)
	Logging.log_line("Decompressed player state for frame " + str(frame))
	server_player_state.log_state()

func _decompress_modular_abilities(frame : int, n_abilities : int, bit_packer : OutputMemoryBitStream) -> void:
	for _i in range(n_abilities):
		var int_id = bit_packer.decompress_int(BaseCompression.n_class_id_bits)
		var class_id = ObjectCreationRegistry.int_id_to_str_id[int_id]
		#component_map.receive_data_for(frame, class_id, bit_packer)

func _reset_to_frame(frame) -> void:
	#var state_to_reset_to = state_history.retrieve_data(frame)
#	if not state_to_reset_to == BaseModularHistory.NO_DATA_FOR_FRAME:
#		#Logging.log_line("Resetting player state to ")
#		#Logging.log_object_vars(state_to_reset_to)
#		# TO DO -> Do we even have to track the looking vector??
#		global_position = state_to_reset_to.position
#		states.set_current_state(state_to_reset_to.state)
	pass

func _connect_signals():
	health.connect("health_changed",Callable(health_gui,"_on_health_changed"))
