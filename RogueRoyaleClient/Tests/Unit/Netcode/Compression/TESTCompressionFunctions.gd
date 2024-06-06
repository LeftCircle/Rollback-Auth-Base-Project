extends GutTestRogue

func test_compress_quantized_vector():
	var up_vec = Vector2.UP
	var down_vec = Vector2.DOWN
	var quantized_up = InputVecQuantizer.quantize_vec(up_vec)
	var quantized_down = InputVecQuantizer.quantize_vec(down_vec)
	assert_almost_eq(quantized_up.distance_squared_to(up_vec), 0, 0.001)
	assert_almost_eq(quantized_down.distance_squared_to(down_vec), 0, 0.001)
	var quantized_up_angle = InputVecQuantizer.get_quantized_angle(up_vec)
	var quantized_down_angle = InputVecQuantizer.get_quantized_angle(down_vec)
	var quantized_up_len = InputVecQuantizer.get_quantized_length(up_vec)
	assert_true(quantized_up_len == 4)
	assert_true(quantized_up_angle >= 0)
	assert_true(quantized_down_angle >= 0)
	assert_true(quantized_up_angle < InputVecQuantizer.N_MOVEMENT_DIRECTIONS)
	assert_true(quantized_down_angle < InputVecQuantizer.N_MOVEMENT_DIRECTIONS)
