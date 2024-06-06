extends RefCounted
class_name ModularDataComparer

static func data_matches(data_0, data_1) -> bool:
	var properties = data_0.get_script().get_script_property_list()
	for property in properties:
		var var_0 = data_0.get(property.name)
		var var_1 = data_1.get(property.name)
		if compare_values(var_0, var_1) != true:
			if typeof(var_1) == TYPE_OBJECT:
				for prop in var_0.get_script().get_script_property_list():
					Logging.log_line("Compare missmatch for " + str(prop.name) + " Client " + str(var_0.get(prop.name)) + " vs Server " + str(var_1.get(prop.name)))
			else:
				Logging.log_line("Compare missmatch for " + str(property.name) + " val_0 = " + str(var_0) + " val_1 = " + str(var_1))
			return false
	return true

static func compare_values(a, b) -> bool:
	if typeof(a) == TYPE_FLOAT:
		return is_equal_approx(a, b)
	elif typeof(a) == TYPE_VECTOR2:
		return (is_equal_approx(a.x, b.x) and is_equal_approx(a.y, b.y))
	elif typeof(a) == TYPE_OBJECT:
		assert(false)
		return false
		#return data_matches(a, b)
	else:
		return a == b

static func _compare_floats(a : float, b : float, threshold = 0.1) -> bool:
	return abs(a - b) < threshold

static func _compare_vec(a : Vector2, b : Vector2, threshold = 0.1) -> bool:
	return abs((a - b).length_squared()) < threshold
