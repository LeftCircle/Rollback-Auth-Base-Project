extends GutTest


func test_arrays_are_allowed():
	var test_data = TestData.new()
	var test_data_2 = TestData.new()
	test_data.test_array = [1, 2, 3]
	test_data_2.test_array = [4, 5, 6]
	test_data.test_vec = Vector2.ZERO
	test_data_2.test_vec = Vector2.ZERO
	assert_set_array_uses_duplicate(test_data, test_data_2)

	# test compression is able to compress/decompress array
	# Test arrays are deeply copied

func assert_set_array_uses_duplicate(data_a, data_b) -> void:
	data_a.set_data_with_obj(data_b)
	for i in range(data_a.test_array.size()):
		assert_eq(data_a.test_array[i], data_b.test_array[i])
	data_a.test_array[0] = data_b.test_array[0] + 1
	assert_ne(data_a.test_array[0], data_b.test_array[0])

func test_matches_does_not_check_arrays() -> void:
	var test_data = TestData.new()
	var test_data_2 = TestData.new()
	test_data.test_array = [1, 2, 3]
	test_data_2.test_array = [4, 5, 6]
	test_data.test_vec = Vector2.ZERO
	test_data_2.test_vec = Vector2.ZERO
	assert_true(test_data.matches(test_data_2))
