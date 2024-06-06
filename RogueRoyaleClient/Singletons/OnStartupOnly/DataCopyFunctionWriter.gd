extends Node

@export var file_lister: Resource
@export var generate_new_code: bool = false

func _ready():
	if generate_new_code:
		add_copy_function_to_all_data_containers()
		print("DONE ADDING COPY FUNCTIONS!!")
	queue_free()

func add_copy_function_to_all_data_containers():
	file_lister.load_resources()
	var paths = file_lister.get_file_paths()
	for path in paths:
		var data_container = load(path).new()
		_generate_new_code(data_container, path)

func _generate_new_code(res, path):
	var source_code = _get_script_base(res)
	source_code = _add_functions_to_source_code(res, source_code)
	#print("\n\n", source_code)
	_save_new_file(path, source_code)

func _get_script_base(res) -> String:
	var source_code = res.get_script().get_source_code()
	var extends_and_class = get_extends_and_class_from_script(source_code)
	var vaiables = get_variables_from_script(source_code)
	return extends_and_class + vaiables

func _add_functions_to_source_code(object, new_source_code : String) -> String:
	new_source_code += add_copy_function(object)
	new_source_code += add_equal_function(object)
	return new_source_code

func _save_new_file(path : String, source_code : String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE_READ)
	file.store_string(source_code)
	file.close()

func get_extends_and_class_from_script(source_code : String) -> String:
	# Read through the start of the script. If the script is "extends Node/n class_name TestClass/n ...."
	# We should return "extends Node/n class_name TestClass/n
	var lines = source_code.split("\n", false, 3)
	return lines[0] + "\n" + lines[1] + "\n\n"

func get_variables_from_script(source_code : String) -> String:
	# Read through the start of the script. If the script is "extends Node/n class_name TestClass/n ...."
	# We should return "extends Node/n class_name TestClass/n
	var lines = source_code.split("\n", false)
	var variables = ""
	for line in lines:
		if line.left(4) == "var ":
			variables += line + "\n"
	variables += "\n"
	return variables

func add_copy_function(obj : Object) -> String:
	var script = obj.get_script()
	var script_variables = get_variables(script)
	#print(script_variables)
	var set_data_with_obj = "func set_data_with_obj(other_obj): \n"
	for variable in script_variables:
		var obj_var = obj.get(variable.name)
		if typeof(obj_var) == TYPE_OBJECT:
			set_data_with_obj = _add_sub_variable_lines(variable.name, obj_var, set_data_with_obj)
		elif typeof(obj_var) == TYPE_ARRAY:
			set_data_with_obj += "	" + variable.name + " = other_obj." + variable.name + ".duplicate(true)\n"
		else:
			set_data_with_obj += "	" + variable.name + " = other_obj." + variable.name + "\n"
	var set_obj_with_data = "func set_obj_with_data(other_obj): \n"
	for variable in script_variables:
		var obj_var = obj.get(variable.name)
		if typeof(obj_var) == TYPE_OBJECT:
			set_obj_with_data = _add_sub_variable_lines(variable.name, obj_var, set_obj_with_data, true)
		elif typeof(obj_var) == TYPE_ARRAY:
			set_obj_with_data += "	other_obj." + variable.name + " = " + variable.name + ".duplicate(true)\n"
		else:
			set_obj_with_data += "	other_obj." + variable.name + " = " + variable.name + "\n"
	return set_data_with_obj + "\n" + set_obj_with_data + "\n"

func get_variables(script : Script):
	var script_properties = script.get_script_property_list()
	var script_vars = []
	for property in script_properties:
		if property.hint_string == "":
			script_vars.append(property)
	return script_vars

func _add_sub_variable_lines(starting_string : String, new_obj : Object, source_code : String, set_obj = false):
	var script = new_obj.get_script()
	var obj_variables = get_variables(script)
	for variable in obj_variables:
		var obj_var = new_obj.get(variable.name)
		if typeof(obj_var) == TYPE_OBJECT:
			var new_string = starting_string + "." + variable.name
			return _add_sub_variable_lines(new_string, obj_var, source_code, set_obj)
		elif typeof(obj_var) == TYPE_ARRAY:
			if set_obj:
				source_code += "	other_obj." + starting_string + "." + variable.name + " = " + starting_string + "." + variable.name + ".duplicate(true)\n"
			else:
				source_code += "	" + starting_string + "." + variable.name + " = other_obj." + starting_string + "." + variable.name + ".duplicate(true)\n"
		else:
			if set_obj:
				source_code += "	other_obj." + starting_string + "." + variable.name + " = " + starting_string + "." + variable.name + "\n"
			else:
				source_code += "	" + starting_string + "." + variable.name + " = other_obj." + starting_string + "." + variable.name + "\n"
	return source_code

func add_equal_function(obj : Object) -> String:
	var script = obj.get_script()
	var script_variables = get_variables(script)
	var matches_func = "func matches(other_obj) -> bool: \n"
	matches_func += "	return (\n"
	for variable in script_variables:
		var obj_var = obj.get(variable.name)
		if typeof(obj_var) == TYPE_OBJECT:
			matches_func = _add_sub_variable_lines_eq(variable.name, obj_var, matches_func)
		elif typeof(obj_var) == TYPE_ARRAY:
			# Nothing to write here
			pass
			#assert(false) #,"Arrays not supported. Too expensive match checks")
		elif typeof(obj_var) == TYPE_DICTIONARY:
			assert(false) #," Dictionaries not supported. Too expensive match checks")
		else:
			matches_func += "	(ModularDataComparer.compare_values(" + variable.name + ", " + "other_obj." + variable.name + ") == true) and\n"
	matches_func = matches_func.left(matches_func.length() - 5)
	matches_func += "\n	)"
	return matches_func

func _add_sub_variable_lines_eq(starting_string : String, new_obj : Object, source_code : String, set_obj = false):
	var script = new_obj.get_script()
	var obj_variables = get_variables(script)
	for variable in obj_variables:
		var obj_var = new_obj.get(variable.name)
		if typeof(obj_var) == TYPE_OBJECT:
			var new_string = starting_string + "." + variable.name
			return _add_sub_variable_lines_eq(new_string, obj_var, source_code, set_obj)
		else:
			source_code += "	(ModularDataComparer.compare_values(" + starting_string + "." + variable.name + ", other_obj." + starting_string + "." + variable.name + ") == true) and\n"
	return source_code
