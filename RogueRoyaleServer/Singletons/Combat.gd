extends Node

func get_skill_damage(skill_name : String, player_id : int):
	print("Skill name sent to get damage = ", skill_name)
	var damage = 0
	if skill_name == "Fireball":
		var intelligence_mod = 0.1 * Map.get_player_node(player_id).player_stats.Intelligence
		damage = ServerData.skill_data[skill_name].Damage * intelligence_mod
	elif skill_name == "Sword":
		damage = 25
	return damage
