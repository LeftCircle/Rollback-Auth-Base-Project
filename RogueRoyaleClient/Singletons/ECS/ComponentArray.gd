extends RefCounted
class_name ComponentArray

var components : Array[RefCounted] = []
var next_component_index = 0
var entity_to_index = {}
var index_to_entity = {}
var signature = 0

func _init():
	components.resize(EntityManager.MAX_ENTITIES)

func add_data(entity : int, component : RefCounted) -> void:
	assert(!entity_to_index.has(entity), "Entity already has a component")
	components[next_component_index] = component
	entity_to_index[entity] = next_component_index
	index_to_entity[next_component_index] = entity
	next_component_index += 1

func remove_data(entity : int) -> void:
	# Replace the data with the last element
	assert(entity_to_index.has(entity), "Entity does not have a component")
	# Get the last component and entity and the index of the entity to remove
	var index = entity_to_index[entity]
	var last_used_index : int = next_component_index - 1
	var entity_at_end = index_to_entity[last_used_index]
	
	# Replace the data for the entity to remove with the data at the end
	components[index] = components[last_used_index]
	entity_to_index[entity_at_end] = index
	index_to_entity[index] = entity_at_end
	
	# Remove the data for the erased entity
	entity_to_index.erase(entity)
	index_to_entity.erase(last_used_index)
	next_component_index -= 1

func get_data(entity : int) -> RefCounted:
	assert(entity_to_index.has(entity), "Entity does not have a component")
	return components[entity_to_index[entity]]

func has_entity(entity : int) -> bool:
	return entity_to_index.has(entity)

func entity_destroyed(entity : int) -> void:
	if entity_to_index.has(entity):
		remove_data(entity)
