extends RefCounted
class_name DataSetter

static func set_obj_with_data(object, data) -> void:
	if is_instance_valid(object):
		var properties = data.get_script().get_script_property_list()
		for prop in properties:
			var data_var = data.get(prop.name)
			if typeof(data_var) == TYPE_OBJECT:
				#if data_var.get_class() == "TimerData":
				set_obj_with_data(object.get(prop.name), data_var)
			else:
				object.set(prop.name, data.get(prop.name))

static func set_data_with_obj(data, object) -> void:
	if is_instance_valid(object):
		var properties = data.get_script().get_script_property_list()
		for prop in properties:
			var data_var = data.get(prop.name)
			if typeof(data_var) == TYPE_OBJECT:
				#if data_var.get_class() == "TimerData":
				set_data_with_obj(data_var, object.get(prop.name))
			else:
				data.set(prop.name, object.get(prop.name))
