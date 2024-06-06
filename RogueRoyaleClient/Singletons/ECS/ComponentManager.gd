extends RefCounted
class_name ComponentManager

var next_signature : int = 1
var component_arrays : Array[RefCounted] = []
var string_id_to_component_arrays : Dictionary = {}
var string_id_to_signature : Dictionary = {}
var signature_to_component_arrays : Dictionary = {}

func register_component(component : RefCounted, string_id : String) -> void:
    if string_id_to_component_arrays.has(string_id):
        print("ComponentManager: Component with string_id " + string_id + " already registered.")
        return
    var signature = next_signature
    var new_component_array = ComponentArray.new()
    # Signatures are bitmasks, so we can use them to check if a component has all the required component_arrays
    next_signature = next_signature << 1
    string_id_to_component_arrays[string_id] = component
    string_id_to_signature[string_id] = signature
    signature_to_component_arrays[signature] = component
    component_arrays.append(component)