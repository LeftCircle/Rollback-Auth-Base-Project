extends Resource
class_name RegionDataSender

var data = {
	"Nodes" : {},
	"Springs" : [],
	"MapRNGSeed" : null
}

func prep_data_to_send(grammar_data : GRuleInfoReader) -> void:
#	for node in grammar_data.LHS_nodes:
#		var node_n = node.node_info.node_number
#		data["Nodes"][node_n] = node.get_data_to_send()
#	for spring in grammar_data.LHS_springs:
#		data["Springs"].append(spring.get_data_to_send())
#	data["MapRNGSeed"] = Map.map_rng.seed
#	Server.send_map_data(data)
	for node in grammar_data.LHS_nodes:
		var room = node.room_scene.prep_data_to_send()

