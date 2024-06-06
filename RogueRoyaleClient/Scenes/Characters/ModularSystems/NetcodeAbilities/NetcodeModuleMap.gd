extends RefCounted
class_name NetcodeModuleMap

# {module : null}
var module_map = {}

func add_component(module):
	if module.get("netcode") != null:
		module_map[module] = null

func has(module) -> bool:
	return module_map.has(module)

func remove_module(module) -> void:
	module_map.erase(module)

func reset_modules_to_frame(frame : int) -> void:
	for module in module_map.keys():
		module.reset_to_frame(frame)
