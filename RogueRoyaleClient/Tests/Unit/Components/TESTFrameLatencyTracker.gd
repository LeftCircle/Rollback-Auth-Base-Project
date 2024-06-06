extends GutTestRogue


func test_registered_on_startup_with_class_instance_0():
	var str_id = FrameLatencyTrackerSingleton.netcode.class_id
	assert_eq(FrameLatencyTrackerSingleton.netcode.class_instance_id, 0)
