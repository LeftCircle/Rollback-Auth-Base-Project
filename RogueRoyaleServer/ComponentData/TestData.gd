extends RefCounted
class_name TestData

var test_array : Array
var test_vec : Vector2

func set_data_with_obj(other_obj):
	test_array = other_obj.test_array.duplicate(true)
	test_vec = other_obj.test_vec

func set_obj_with_data(other_obj):
	other_obj.test_array = test_array.duplicate(true)
	other_obj.test_vec = test_vec

func matches(other_obj) -> bool:
	return (
	(ModularDataComparer.compare_values(test_vec, other_obj.test_vec) == true)
	)
