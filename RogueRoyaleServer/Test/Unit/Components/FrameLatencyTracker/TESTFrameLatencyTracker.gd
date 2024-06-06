extends GutTest


func test_instance_id_is_always_zero():
	var trackers = _init_two_trackers()
	assert_true(trackers[0].netcode.class_instance_id == 0)
	assert_true(trackers[1].netcode.class_instance_id == 0)
	TestFunctions.queue_scenes_free(trackers)

#func test_compressed_frame():
#	var bit_packer = OutputMemoryBitStream.new()
#	var tracker = _init_single_tracker()
#	var test_value = 99.234
#	_compress_data_into_bit_packer(test_value, tracker, bit_packer)
#	var decompressed_data = tracker.netcode.state_compresser.decompress(bit_packer)
#	assert_true(decompressed_data.server_frame_latency == test_value)
#	tracker.queue_free()

func test_average_frame_latency():
	var tracker = _init_single_tracker()
	var avg = _get_average_of_random_values(tracker)
	assert_true(is_equal_approx(avg, tracker.get_frame_latency()))
	tracker.queue_free()

func _init_two_trackers() -> Array:
	var tracker_0 = FrameLatencyTracker.new()
	var tracker_1 = FrameLatencyTracker.new()
	add_child(tracker_0)
	add_child(tracker_1)
	return [tracker_0, tracker_1]

func _get_average_of_random_values(tracker : FrameLatencyTracker) -> float:
	var sum = 0
	randomize()
	for i in range(int(tracker.get_average_after())):
		var rand = randf()
		sum += rand
		tracker.add_frame_latency(rand)
	var avg = sum / int(tracker.get_average_after())
	return avg

func _compress_data_into_bit_packer(test_value, tracker : FrameLatencyTracker, bit_packer : OutputMemoryBitStream) -> void:
	tracker.data_container.server_frame_latency = test_value
	tracker.netcode.state_compresser.compress(bit_packer, tracker.data_container)
	var byte_array = bit_packer.get_array_to_send()
	bit_packer.init_read(byte_array)

func _init_single_tracker() -> FrameLatencyTracker:
	var tracker_0 = FrameLatencyTracker.new()
	add_child(tracker_0)
	return tracker_0
