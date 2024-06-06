extends GutTest

var rng = RandomNumberGenerator.new()

func test_value_averager():
	rng.randomize()
	var sliding_averager = SlidingValueAverager.new()
	var random_values = _add_random_values_to_sliding_value_averager(sliding_averager, 100)
	var sliding_average_values = random_values.slice(-SlidingValueAverager.AVERAGE_AFTER)
	var full_average = _average_array(random_values)
	var expected_average = _average_array(sliding_average_values)
	# Because the sliding value average only averages the last 10, we do not
	# expect the SlidingValueAverager average to be the average of all values
	assert_almost_ne(sliding_averager.average, full_average, 0.01)
	assert_almost_eq(sliding_averager.average, expected_average, 0.01)

func _add_random_values_to_sliding_value_averager(sliding_averager : SlidingValueAverager, n_values : int) -> Array:
	var all_values = []
	for _i in range(n_values):
		#var rand_f : float = rng.randf_range(0, 100)
		var rand_f = float(_i)
		sliding_averager.add_value(rand_f)
		all_values.append(rand_f)
	return all_values

func _average_array(arr : Array) -> float:
	var sum = 0.0
	for i in arr:
		sum += i
	return sum / float(arr.size())
