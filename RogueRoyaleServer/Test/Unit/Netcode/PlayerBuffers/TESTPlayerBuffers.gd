extends GutTest

# The purpose of this script is to ensure that players sync command frames around the highest ping player

var test_id_a = 1234111
var test_id_b = 5678111

func test_frame_latencies():
	var a_latencies = TestFunctions.get_array_of_random_values(100, 0, 3)
	var b_latencies = TestFunctions.get_array_of_random_values(100, 8, 15)
	_add_latencies(test_id_a, a_latencies)
	_add_latencies(test_id_b, b_latencies)
	var expected_a = TestFunctions.average_array(a_latencies.slice(-SlidingValueAverager.AVERAGE_AFTER))
	var expected_b = TestFunctions.average_array(b_latencies.slice(-SlidingValueAverager.AVERAGE_AFTER))
	var actual_a = LatencyTracker.get_frame_latency(test_id_a)
	var actual_b = LatencyTracker.get_frame_latency(test_id_b)
	assert_almost_eq(expected_a, actual_a, 0.1)
	assert_almost_eq(expected_b, actual_b, 0.1)

func test_sliding_average_is_60_seconds():
	var frame_latency_tracker = FrameLatencyTracker.new()
	assert_eq(frame_latency_tracker.get_average_after(), 60)

func test_stable_buffer_finder_player_connect_disconnect_from_PlayerSyncController():
	PlayerSyncController._on_player_connect(test_id_a)
	var buffer_finder = PlayerSyncController.stable_buffer_finder
	assert_true(buffer_finder.has_player(test_id_a))
	PlayerSyncController._on_player_disconnect(test_id_a)
	assert_false(buffer_finder.has_player(test_id_a))

func test_stable_buffer_accounts_for_max_latency():
	LatencyTracker.max_average_frame_latency = 0
	PlayerSyncController._on_player_connect(test_id_a)
	PlayerSyncController._on_player_connect(test_id_b)
	var a_latencies = []
	var b_latencies = []
	var a_latency = 1
	var b_latency = 10
	a_latencies.resize(60)
	a_latencies.fill(a_latency)
	b_latencies.resize(60)
	b_latencies.fill(b_latency)
	_add_latencies(test_id_a, a_latencies)
	_add_latencies(test_id_b, b_latencies)
	LatencyTracker.get_max_average_latency()
	var actual_buffer_a = PlayerSyncController.stable_buffer_finder.get_stable_buffer(test_id_a)
	var actual_buffer_b = PlayerSyncController.stable_buffer_finder.get_stable_buffer(test_id_b)
	var expected_b_buffer = StableBufferFinder.STABLE_BUFFER_SIZE
	var expected_a_buffer = b_latency - a_latency + StableBufferFinder.STABLE_BUFFER_SIZE
	assert_eq(actual_buffer_a, expected_a_buffer)
	assert_eq(actual_buffer_b, expected_b_buffer)

func _add_latencies(player_id : int, latencies : Array) -> void:
	for i in range(latencies.size()):
		LatencyTracker.receive_frame_latency(player_id, latencies[i])
