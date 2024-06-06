extends RefCounted
class_name ModularDataComparer

#static func data_matches(data_0, data_1) -> bool:
#	var properties = data_0.get_script().get_script_property_list()
#	for property in properties:
#		var var_0 = data_0.get(property.name)
#		var var_1 = data_1.get(property.name)
#		if _compare_values(var_0, var_1) != true:
#			return false
#	return true

static func compare_values(a, b) -> bool:
	if typeof(a) == TYPE_FLOAT:
		return _compare_floats(a, b, 2)
	elif typeof(a) == TYPE_VECTOR2:
		return _compare_vec(a, b, 2)
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
