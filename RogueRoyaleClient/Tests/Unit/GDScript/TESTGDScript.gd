extends GutTestRogue

var timer_finished = false

func test_await():
	await wait_for_x_seconds(0.05)
	assert_true(timer_finished)

func wait_for_x_seconds(seconds):
	await get_tree().create_timer(seconds).timeout
	timer_finished = true
