extends RefCounted
class_name StaminaDataOld

var frame : int
var node_active_flags = []

# TO DO -> instead of dynamically resizing all these arrays, we could only resize arrays when
# the total stamina of the player changes.
func add_data(stamina : BaseStamina) -> void:
	node_active_flags.clear()
	for node in stamina.stamina_nodes:
		node = node as BaseStaminaNode
		if node.is_empty():
			node_active_flags.append(0)
		else:
			node_active_flags.append(1)


