extends Node

func vector_to_int_vector(in_vector : Vector2) -> Vector2:
	in_vector.x = round(in_vector.x)
	in_vector.y = round(in_vector.y)
	return in_vector

func get_x_and_y_as_ints(in_vector : Vector2) -> Array:
	var x_and_y = []
	var vec = vector_to_int_vector(in_vector)
	x_and_y.append(int(vec.x))
	x_and_y.append(int(vec.y))
	return x_and_y
