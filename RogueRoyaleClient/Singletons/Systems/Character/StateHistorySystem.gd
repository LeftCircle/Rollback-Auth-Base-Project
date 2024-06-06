extends Node
# StateHistorySystem

func execute(frame : int):
	var entities = get_tree().get_nodes_in_group("Players")
	for entity in entities:
#		if entity.components.has_group("StateSystem"):
#			var state_system : C_StateSystemState = entity.get_component("StateSystem")
#			state_system.history.add_data(frame, state_system.data_container)
		for component in entity.components.component_map:
			component.save_history(frame)
	var local_nodes = get_tree().get_nodes_in_group("LocalHistory")
	for node in local_nodes:
		node.save_history(frame)
