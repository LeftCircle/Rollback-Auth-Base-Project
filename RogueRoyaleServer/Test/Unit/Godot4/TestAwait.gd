extends GutTest


var test_frame = 0

func _physics_process(delta):
	test_frame += 1

func test_await():
	var frame = test_frame
	await get_tree().process_frame
	var after_idle_frame = test_frame
	assert_ne(frame, after_idle_frame)
	await get_tree().physics_frame
	var after_physics_frame = test_frame
	assert_eq(after_idle_frame, after_physics_frame)
	await get_tree().process_frame
	var after_second_process = test_frame
	assert_ne(after_idle_frame, after_second_process)
