extends GutTest


func test_seconds_convert_to_frames():
	var new_timer = _instance_command_timer()
	assert_eq(new_timer.wait_time_sec, 1)
	assert_eq(new_timer.wait_frames, 1.0 / CommandFrame.frame_length_sec)
	new_timer.queue_free()



func _instance_command_timer():
	var new_timer = CommandTimer.new()
	ObjectCreationRegistry.add_child(new_timer)
	return new_timer
