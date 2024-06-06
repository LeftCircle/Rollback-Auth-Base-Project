extends Node

const MAX_BUFFER = 5
const BUFFER = 1
const FRAMES_BETWEEN_DOUBLE_BUFFER = 5

var last_world_frame = 0
var map_path = "/root/SceneHandler/Map"
var map_rng = null
var ARRAY_SIZE = 60

var world_state_buffer = []
var buffer_size : int = 0
var buffered_frame : int = 0
var previous_buffered_frame : int = 0
var _frame_to_buffer : int = 0
var decompressing_world_states = false
var frames_to_double_decompress = 0

var most_recently_received_world_frame : int
var second_most_recent_world_frame : int


var client_serialization = ClientSerialization.new()
var world_state_decompresser = WorldStateDecompression.new()

# These nodes get set from Map.gd
#var WorldMap
#var PlayerYSort
#var MobYSort
var current_time = {"T": 0}
var double_buffer_frame_counter = 0
var n_double_buffers_to_execute = 0

var mutex = Mutex.new()
#@onready var world_state_function_queue = $WorldStateFunctionQueue as WorldStateFunctionQueue


func _ready():
	process_priority = 0
	for i in range(ARRAY_SIZE):
		world_state_buffer.append(WorldStateData.new())

func execute():
#func _physics_process(delta):
	#print(buffer_size)
	if not decompressing_world_states:
		if buffer_size >= BUFFER:
			decompressing_world_states = true
			# We must set the buffered frame the first time around
			_set_first_frame_to_buffer()
			_decompress_buffered_world_state()
	else:
		Logging.log_line("World state buffer = " + str(buffer_size))
		_track_double_buffers()
		_decompress_buffered_world_state()

func _track_double_buffers():
	if n_double_buffers_to_execute > 0:
		double_buffer_frame_counter += 1
		if double_buffer_frame_counter >= FRAMES_BETWEEN_DOUBLE_BUFFER:
			_decompress_buffered_world_state()
			Logging.log_line("Double executing buffer")
			double_buffer_frame_counter = 0
			n_double_buffers_to_execute -= 1
	if buffer_size > MAX_BUFFER:
		print("GREATER THAN MAX BUFFER")
		Logging.log_line("Double executing buffer")
		#print("Double executing world state")
		_decompress_buffered_world_state()
		n_double_buffers_to_execute += 1

func _decompress_buffered_world_state() -> void:
	var buffered_world_state = get_world_state_for_frame_or_null(_frame_to_buffer)
	if buffered_world_state != null:
		previous_buffered_frame = buffered_frame
		buffered_frame = _frame_to_buffer
		assert(buffered_frame == buffered_world_state.frame) #,"gotta match")
		#var decomp_funcref = funcref(world_state_decompresser, "decompress_world_state")
		#world_state_function_queue.queue_funcref(decomp_funcref, [buffered_world_state])
		world_state_decompresser.decompress_world_state(buffered_world_state)
		#set_frame_to_buffer(CommandFrame.get_next_frame(_frame_to_buffer))
		_frame_to_buffer = CommandFrame.get_next_frame(_frame_to_buffer)
		buffer_size -= 1
	else:
		# A hack to prevent us from falling too far behind
		if buffer_size > 3 * MAX_BUFFER:
			_set_last_frame_to_buffer()
			print("First frame refound!!")
		Logging.log_line("No buffered data for frame " + str(_frame_to_buffer))
	#Logging.log_line("Command Frame - buffered_frame = " + str(CommandFrame.frame - buffered_frame))

func set_buffered_frame(to_frame : int) -> void:
	mutex.lock()
	buffered_frame = to_frame
	mutex.unlock()

func add_to_buffer(value : int) -> void:
	mutex.lock()
	buffer_size += value
	mutex.unlock()

func set_frame_to_buffer(to_frame : int) -> void:
	mutex.lock()
	_frame_to_buffer = to_frame
	mutex.unlock()

func set_most_recently_received_frame(frame : int) -> void:
	if CommandFrame.command_frame_greater_than_previous(frame, most_recently_received_world_frame):
		second_most_recent_world_frame = most_recently_received_world_frame
		most_recently_received_world_frame = frame

#func pass_node_variables(map : Map, player_y_sort : Node2D, mob_y_sort : Node2D) -> void:
#	WorldMap = map
#	PlayerYSort = player_y_sort
#	MobYSort = mob_y_sort

func receive_world_state(compressed_world_state : Array):
	var server_frame = world_state_decompresser.get_frame(compressed_world_state)
	set_most_recently_received_frame(server_frame)
	FrameAcker.ack_server_frame(server_frame)
	Logging.log_line("Received world state for frame " + str(server_frame))
	Logging.log_line(str(compressed_world_state))
	if not _has_world_state_for_frame(server_frame):
		world_state_buffer[server_frame % ARRAY_SIZE].frame = server_frame
		world_state_buffer[server_frame % ARRAY_SIZE].compressed_data = compressed_world_state
		add_to_buffer(1)
		CommandFrame.debug_world_states_received_last_frame += 1
	else:
		Logging.log_line("Already received this world state frame")

func _has_world_state_for_frame(frame : int) -> bool:
	var data = get_world_state_for_frame_or_null(frame)
	if data == null:
		return false
	return true

# The rng seed is acquired after the authentication results are received and are true
func set_map_rng(rng_seed):
	map_rng = RandomNumberGenerator.new()
	map_rng.seed = rng_seed

func get_world_state_for_frame_or_null(frame : int):
	var data = world_state_buffer[frame % ARRAY_SIZE]
	if data.frame != frame:
		return null
	return data

func _set_first_frame_to_buffer():
	var received_frames = []
	for i in range(ARRAY_SIZE):
		var data = world_state_buffer[i] as WorldStateData
		if data.frame > 0:
			print(data.frame)
			received_frames.append(data.frame)
	_frame_to_buffer = received_frames.min()

func _set_last_frame_to_buffer():
	var received_frames = []
	for i in range(ARRAY_SIZE):
		var data = world_state_buffer[i] as WorldStateData
		if data.frame > 0:
			print(data.frame)
			received_frames.append(data.frame)
	set_frame_to_buffer(received_frames.max())
